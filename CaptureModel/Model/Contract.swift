//
//  Contract.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

extension Contract: KeyCodable {
    public enum Keys: String {
        case Event              = "event"
        case Acquired           = "acquired"
        case Resolution         = "resolution"
        case Started            = "started"
        case PaymentState       = "paymentState"
        case PaymentDate        = "paymentDate"
    }
}

extension Contract.PaymentStatus {
    public var localizedString:String {
        switch self {
        case .Pending:
            return NSLocalizedString("PENDING", comment: "Contract.PaymentStatus : Pending")
        case .Disputed:
            return NSLocalizedString("IN REVIEW", comment: "Contract.PaymentStatus : Disputed")
        case .Rejected:
            return NSLocalizedString("DENIED", comment: "Contract.PaymentStatus : Rejected")
        case .Approved:
            return NSLocalizedString("APPROVED", comment: "Contract.PaymentStatus : Approved")
        case .Paid:
            return NSLocalizedString("PAID", comment: "Contract.PaymentStatus : Paid")
        }
    }
}
extension Contract.ResolutionStatus {
    public var isCancelled:Bool {
        switch self {
        case .PublisherCanceled, .UserCanceled:
            return true
        default:
            return false
        }
    }
}

public final class Contract: ManagedObject {
    
    public enum ResolutionStatus : String {
        case Open               = "open"
        case PublisherCanceled  = "publisher_canceled"
        case UserCanceled       = "user_canceled"
        case Completed          = "completed"
    }
    
    
    public enum PaymentStatus : String {
        case Pending            = "pending"
        case Disputed           = "disputed"
        case Rejected           = "rejected"
        case Paid               = "paid"
        case Approved           = "approved"
    }
    
    @NSManaged public var totalAttachmentFileBytes: UInt64
    @NSManaged public var uploadedAttachmentFileBytes:UInt64
    @NSManaged public var hasStartedUpload: Bool
    @NSManaged public var started: Bool
    @NSManaged public private(set) var acquired:Bool
    @NSManaged public private(set) var eventUrlHash: String
    @NSManaged public private(set) var arrivalRadius:Double
    @NSManaged public private(set) var streamApplication: String
    @NSManaged public private(set) var streamHost:String
    @NSManaged public private(set) var streamName:String
    @NSManaged public private(set) var streamPort:UInt16
    @NSManaged public private(set) var streamProtocol: String
    @NSManaged public private(set) var hasSeenAcquiredFlag: Bool
    @NSManaged public private(set) var resolution:String
    @NSManaged public private(set) var paymentState:String
    @NSManaged public private(set) var paymentDate:NSDate
    @NSManaged public private(set) var event: Event
    @NSManaged public private(set) var publisher: Publisher?
    @NSManaged public private(set) var team: Team?
    @NSManaged public var attachments: Set<Attachment>?
 
    public var selectedAttachments:[Attachment] = []

    public var resolutionStatus:Contract.ResolutionStatus {
        get {
            guard let rs = ResolutionStatus(rawValue: self.resolution) else {
                fatalError("The is no resolution status of : \(self.resolution)")
            }
            return rs
        }
        set {
            resolution = newValue.rawValue
            markForNeedsRemoteVerification()
        }
    }
    
    public var paymentStatus:Contract.PaymentStatus {
        get {
            guard let rs = PaymentStatus(rawValue: self.paymentState) else {
                fatalError("The is no payment status of : \(self.paymentState)")
            }
            return rs
        }
        set {
            paymentState = newValue.rawValue
        }
    }

    public var numberOfUnuploadedAttachments:UInt {
        return UInt(uploadableAttachments.count)
    }
    
    public var numberOfUploadedAttachments:UInt {
        return UInt(uploadedAttachments.count)
    }
    
    public override func willSave() {
        super.willSave()
        
        if inNeedForRemoteCompletion()
            && Contract.notMarkedForRemoteCompletionPredicate.evaluateWithObject(self)
        {
            markForNeedsRemoteCompletion()
        }
    }
  
    public func start() {
        started                 = true
        markForNeedsRemoteVerification()
    }
    
    public func compare(contract:Contract)->NSComparisonResult {
        return event.startTime.compare(contract.event.startTime)
    }

    public static var userName:String {
        return "publisher"
    }
    
    public static var password:String {
        return "password"
    }
    
    public var URL:String {
        return "\(streamProtocol)://\(streamHost):\(streamPort)/\(streamApplication)/\(streamName)"
    }

    static var isOpenPredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", Keys.Resolution.rawValue, ResolutionStatus.Open.rawValue)
    }
   
    static var isAcquired:NSPredicate {
        return NSPredicate(format: "%K == true", Keys.Acquired.rawValue)
    }
    
    public static var eventHasStartedPredicate:NSPredicate {
        let fifteenMins                     = NSTimeInterval((15.0 * 60.0))
        let paddedDate                      = NSDate().dateByAddingTimeInterval(fifteenMins)
        return NSPredicate(format: "%K.%K <= %@", Keys.Event.rawValue, Event.Keys.StartTime.rawValue, paddedDate)
    }
    
    public static var isNotOpenPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate:isOpenPredicate)
    }
    
    public static var isOpenAndAcquiredPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [isOpenPredicate, isAcquired])
    }
    
    public static var isTheActiveContractPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [isOpenPredicate, isAcquired, eventHasStartedPredicate])
    }
   
    public static var paidContractPredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", Keys.PaymentState.rawValue, PaymentStatus.Paid.rawValue)
    }
    
    public static func fetchActiveContract(moc:NSManagedObjectContext)->Contract? {
        return fetchInContext(moc) { request in
            request.fetchBatchSize          = 1
            request.predicate               = isTheActiveContractPredicate
            request.returnsObjectsAsFaults  = false
            request.sortDescriptors         = [NSSortDescriptor(key:Keys.Started.rawValue, ascending:false)]
        }.first
    }
   
    public static func fetchPaidContracts(moc:NSManagedObjectContext)->[Contract] {
        return fetchInContext(moc) { request in
            request.fetchBatchSize          = 100
            request.predicate               = Contract.paidContractPredicate
            request.returnsObjectsAsFaults  = false
            request.sortDescriptors         = [NSSortDescriptor(key:Keys.PaymentDate.rawValue, ascending:false)]
        }
    }
    
    public static func fetchTotalPaymentsMade(moc:NSManagedObjectContext)->Double {
        let expression                  = NSExpressionDescription()
        expression.expression           = NSExpression(forFunction: "sum:", arguments:[NSExpression(forKeyPath:Event.Keys.PaymentAmount.rawValue)])
        expression.name                 = "totalPayments"
        expression.expressionResultType = .DoubleAttributeType
        
        let request                     = NSFetchRequest()
        request.entity                  = NSEntityDescription.entityForName(Event.entityName, inManagedObjectContext: moc)
        request.predicate               = NSPredicate(format: "%K.%K == %@", Event.Keys.Contract.rawValue, Keys.PaymentState.rawValue, PaymentStatus.Paid.rawValue)
        request.propertiesToFetch       = [expression]
        request.resultType              = NSFetchRequestResultType.DictionaryResultType
       
        var totalPayments : Double      = 0
        
        do {
            let result                  = try moc.executeFetchRequest(request)
            guard let map = result[0] as? [String:Double] else {
                fatalError("resultMap has wrong type")
            }
            guard let tp = map["totalPayments"] else {
                fatalError("totalPayments has wrong type")
            }
            totalPayments               = Double(tp)
        } catch let error as NSError {
            NSLog("Error when summing amounts: \(error.localizedDescription)")
        }

        return totalPayments
    }
    
}

extension Contract {
    
    public var uploadedAttachmentsTotalDuration:UInt64 {
        return uploadedAttachments.reduce(0) { $0 + $1.duration }
    }

    public func configureSelectedAttachments()->UInt64 {
        selectedAttachments         = uploadableAttachments
        totalAttachmentFileBytes = selectedAttachments.reduce(0) {
            return $0 + $1.totalFileBytes
        }
        return totalAttachmentFileBytes
    }
    
    public func configureUploadedBytes()->UInt64 {
        uploadedAttachmentFileBytes = selectedAttachments.reduce(0) {
            return $0 + $1.uploadedFileBytes
        }
        return uploadedAttachmentFileBytes
    }
    
    public var nextAttachmentToUpload:Attachment? {
        return selectedAttachments.filter { !$0.uploaded }.flatMap { $0 }.first
    }
    
    public var uploadableAttachments:[Attachment] {
        return attachmentsAscending.filter {
            return $0.uploaded == false
        }
    }
   
    public var uploadedAttachments:[Attachment] {
        return attachmentsAscending.filter { !uploadableAttachments.contains($0) }
    }

    public var attachmentsDescending:[Attachment] {
        guard let rf = attachments else { return [] }
        return rf.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
    }
    
    public var attachmentsAscending:[Attachment] {
        guard let rf = attachments else { return [] }
        return rf.sort({ $0.createdAt.compare($1.createdAt) == .OrderedAscending })
    }

}

extension Contract: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String

}

extension Contract: Notifiable {
    
    @NSManaged public var notifications: NSOrderedSet?
    @NSManaged public var notificationUpdateTime: NSDate
    
    internal func addNotification(notification:Notification) {
        notification.contractSource = self
        notifications               = mutableNotifications.orderedSet()
        event.addNotification(notification)
        notificationUpdateTime      = NSDate()
    }
    
}


extension Contract : ManagedObjectType {
    
    public static var entityName: String {
        return "Contract"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

extension Contract : RemoteUpdatable {
    
    @NSManaged public var needsRemoteVerification:Bool
    
    public func changedInNeedForRemoteVerification()->Bool {
        let keys:[Keys] = []
        return keys.reduce(false) { a, b in
            return a ? a : changedValues()[b.rawValue] != nil
        }
    }

}

extension Contract : RemoteCompletable {
    
    @NSManaged public var needsRemoteCompletion:Bool
    
    public func inNeedForRemoteCompletion()->Bool {
        if self.acquired {
            return (publisher == nil || team == nil)
        }
        return false
    }
    
}

extension Contract : JSONHashable {
    
    public func toJSON() -> [String : AnyObject] {
        let contractJSON:[String:AnyObject] = [
            "resolution"            : resolution
            ,"started"              : started
        ]
        return contractJSON
    }
    
}

public struct RemoteContract: RemoteRecordType {
   
    public var urlHash              : String
    public var createdAt            : NSDate
    public var updatedAt            : NSDate
    public var eventUrlHash         : String
    public var arrivalRadius        : Double
    public var streamApplication    : String
    public var streamHost           : String
    public var streamName           : String
    public var streamPort           : UInt16
    public var streamProtocol       : String
    public var acquired             : Bool
    public var started              : Bool
    public var resolution           : String
    public var paymentState         : String
    public var remoteEvent          : RemoteEvent?
    public var remotePublisher      : RemotePublisher?
    public var remoteTeam           : RemoteTeam?
    public var remoteAttachments    : [RemoteAttachment]?

    public init(contract:[String:AnyObject?]) {
        guard let uhash             = contract["url_hash"] as? String else { fatalError("contract json has no `url_hash`") }
        self.urlHash                = uhash
        guard let createdAt         = contract["unix_created_at"] as? NSTimeInterval else { fatalError("contract json has no `unix_created_at`") }
        self.createdAt              = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt         = contract["unix_updated_at"] as? NSTimeInterval else { fatalError("contract json has no `unix_updated_at`") }
        self.updatedAt              = NSDate(timeIntervalSince1970:updatedAt)
        guard let eUrlHash          = contract["event_url_hash"] as? String else { fatalError("contract json has no `event_url_hash`") }
        self.eventUrlHash           = eUrlHash
        guard let sApp              = contract["stream_application"] as? String else { fatalError("contract json has no `stream_application`") }
        self.streamApplication      = sApp
        guard let sHost             = contract["stream_host"] as? String else { fatalError("contract json has no `stream_host`") }
        self.streamHost             = sHost
        guard let sName             = contract["stream_name"] as? String else { fatalError("contract json has no `stream_name`") }
        self.streamName             = sName
        guard let sPort             = contract["stream_port"] as? String else { fatalError("contract json has no `stream_port`") }
        self.streamPort             = UInt16(sPort) ?? 1936
        guard let sProtocol         = contract["stream_protocol"] as? String else { fatalError("contract json has no `stream_protocol`") }
        self.streamProtocol         = sProtocol
        self.arrivalRadius          = contract["arrival_radius"] as? Double ?? 0.0
        self.acquired               = contract["acquired"] as? Bool ?? false
        self.started                = contract["started"] as? Bool ?? false
        self.resolution             = contract["resolution"] as? String ?? "open"
        self.paymentState           = contract["payment_status"] as? String ?? "pending"
       
        if let event = contract["event"] as? [String:AnyObject]  {
            self.remoteEvent        = RemoteEvent(event:event)
        }
        
        if let publisher = contract["publisher"] as? [String:AnyObject] {
            self.remotePublisher    = RemotePublisher(publisher:publisher)
        }
        
        if let team = contract["team"] as? [String:AnyObject] {
            self.remoteTeam         = RemoteTeam(team:team)
        }
       
        if let rAttachments = contract["attachments"] as? [[String:AnyObject]] {
            self.remoteAttachments  = rAttachments.map { RemoteAttachment(attachment:$0) }
        }
        
    }
   
}

extension RemoteContract : RemoteRecordMappable {

    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let contract = managedObject as? Contract else {
            fatalError("Object mapped is not a Contract")
        }
        
        contract.urlHash            = self.urlHash
        contract.createdAt          = self.createdAt
        contract.updatedAt          = self.updatedAt
        contract.eventUrlHash       = self.eventUrlHash
        contract.arrivalRadius      = self.arrivalRadius
        contract.streamApplication  = self.streamApplication
        contract.streamHost         = self.streamHost
        contract.streamName         = self.streamName
        contract.streamPort         = self.streamPort
        contract.streamProtocol     = self.streamProtocol
        contract.acquired           = self.acquired
        contract.started            = self.started
        contract.resolution         = self.resolution
        contract.paymentState       = self.paymentState
    }
    
}

extension RemoteContract {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->Contract {
        return Contract.insertOrUpdate(moc, urlHash:urlHash) { contract in
            if contract.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(contract)
            }
            self.updateRelationships(contract, moc:moc)
        }
    }
    
    public func forceMap(contract:Contract, moc:NSManagedObjectContext) {
        self.mapTo(contract)
        self.updateRelationships(contract, moc:moc)
    }
    
    func updateRelationships(contract:Contract, moc:NSManagedObjectContext) {
        if let rEvent = self.remoteEvent {
            contract.event          = rEvent.insertIntoContext(moc)
        }
        if self.remoteEvent == nil {
            contract.event          = Event.insertOrUpdate(moc, urlHash:self.eventUrlHash) { _ in }
        }
        
        if let rPublisher = self.remotePublisher {
            contract.publisher      = rPublisher.insertIntoContext(moc)
        }
        
        if let rTeam = self.remoteTeam {
            contract.team           = rTeam.insertIntoContext(moc)
        }
        
        if let rAttachments = self.remoteAttachments {
            let att                 = rAttachments.map { $0.insertIntoContext(moc) }
            contract.attachments    = Set(att)
            contract.uploadedAttachmentFileBytes = att.reduce(0) { $0 + $1.totalFileBytes }
        }
        
        var c                       = contract
        c.updateNotifications(moc)
        guard let notes = c.notifications else { return }
        c.event.notifications       = notes
    }

}
