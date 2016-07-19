//
//  DirectionsModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class DirectionsModuleView: UIView {
    
    @IBOutlet weak var greenLabelHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var greenLabel:UILabel?
    
    @IBOutlet weak var youveArrivedView:YouveArrivedView?
    @IBOutlet weak var footageView:FootageView?

    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var collectionViewHeight:NSLayoutConstraint?
    
    private typealias Data = DefaultDataProvider<DirectionsModuleView>
    private var dataSource: CollectionViewDataSource<DirectionsModuleView, Data, AttachmentCollectionViewCell>!
    private var dataProvider: Data!
    
    func addAttachments(attachments:[AttachmentCollectionViewModel]) {
        dataProvider                        = DefaultDataProvider(items:attachments, delegate :self)
        dataSource                          = CollectionViewDataSource(collectionView:collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
    func pauseUploading() {
        footageView?.pauseUploading()
    }
    
    func resumeUploading() {
        footageView?.resumeUploading()
    }

    func showGetToLocation(milesAway:Double) {
        greenLabel?.text                    = NSLocalizedString("Almost time to start the job", comment: "OnTheJobView : showGetToLocation : greenLabel : text")
        youveArrivedView?.hidden            = false
        footageView?.hidden                 = true
        footageView?.progressContainerView?.hidden = true
        collectionView?.hidden              = true
        youveArrivedView?.showGetToTheLocaton(milesAway)
    }
    
    func showYouveArrived() {
        greenLabel?.text                    = NSLocalizedString("Tap the camera icon to begin streaming", comment: "OnTheJobView : showYouveArrived : greenLabel : text")
        youveArrivedView?.hidden            = false
        footageView?.hidden                 = true
        footageView?.progressContainerView?.hidden = true
        collectionView?.hidden              = true
        youveArrivedView?.showYouveArrivedAttributtedText()
    }
    
    func showDecision() {
        greenLabel?.text                    = NSLocalizedString("Tap ‘NO’ if you want to record more footage", comment: "OnTheJobView : showDecision : greenLabel : text")
        youveArrivedView?.hidden            = true
        footageView?.hidden                 = false
        collectionView?.hidden              = false
        footageView?.layoutIfNeeded()
        footageView?.progressContainerView?.hidden = false

        footageView?.showDecisionView()
    }
    
    func showUploading() {
        greenLabel?.text                    = NSLocalizedString("Uploading your footage will complete the job.", comment: "OnTheJobView : showUploading : greenLabel : text")
        youveArrivedView?.hidden            = true
        footageView?.hidden                 = false
        collectionView?.hidden              = false
        footageView?.layoutIfNeeded()
        footageView?.progressContainerView?.hidden = false
 
        footageView?.pauseUploading()
    }

    func showUploadingVideos(numVideosUploaded:Int, totalNumVideos:Int, progress:CGFloat) {
        footageView?.showUploadingVideos(numVideosUploaded, totalNumVideos:totalNumVideos, progress:progress)
    }

}

extension DirectionsModuleView : CMViewProtocol {
    
    func didLoad() {
        layer.shadowColor                   = UIColor.bistre().CGColor
        layer.shadowOpacity                 = 0.2
        layer.shadowOffset                  = CGSizeMake(0, 0.5)
        layer.shadowRadius                  = 4
        
        youveArrivedView?.didLoad()
        footageView?.didLoad()
        
        greenLabel?.backgroundColor         = UIColor.mountainMeadow()
        greenLabel?.textColor               = UIColor.whiteColor()
        greenLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s14)
       
        greenLabelHeightConstraint?.constant = ScreenSize.SCREEN_WIDTH * 0.125
        collectionViewHeight?.constant      = ScreenSize.SCREEN_HEIGHT * 0.28
        layoutIfNeeded()
        
        let layout                          = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                               = ScreenSize.SCREEN_WIDTH - 20
        let h                               = ScreenSize.SCREEN_HEIGHT * 0.28
        layout.itemSize                     = CGSizeMake(w,h)
        collectionView?.pagingEnabled       = true
        collectionView?.backgroundColor     = UIColor.whiteColor()
    }
    
}

extension DirectionsModuleView : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        nodes[indexPath.row].hasAgreedBool = !nodes[indexPath.row].hasAgreedBool
//        createDataProvider()
    }
}

extension DirectionsModuleView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<AttachmentCollectionViewModel>]?) {
        dataSource.processUpdates(updates)
    }
}

extension DirectionsModuleView : DataSourceDelegate {
    func cellIdentifierForObject(object:AttachmentCollectionViewModel) -> String {
        return AttachmentCollectionViewCellReuseIdentifier
    }
}