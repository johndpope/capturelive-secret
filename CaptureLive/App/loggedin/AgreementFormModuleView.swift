//
//  AgreementFormModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

struct AgreementNode {
    let descriptionString:String
    var hasAgreedBool:Bool
}

class AgreementFormModuleView: UIView {
    
    @IBOutlet weak var submitButton:CMPrimaryButton?
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint?

    private typealias Data = DefaultDataProvider<AgreementFormModuleView>
    private var dataSource:CollectionViewDataSource<AgreementFormModuleView, Data, AgreementCollectionViewCell>!
    private var dataProvider: Data!
   
    var hiddenHeight:CGFloat = 0 {
        didSet {
            bottomConstraint?.constant          = -hiddenHeight
            layoutIfNeeded()
        }
    }
    var nodes = [
         AgreementNode(
            descriptionString: NSLocalizedString("To record video footage as described in the", comment:"AgreementNode : record : text"),
            hasAgreedBool: false
        )
        ,AgreementNode(
            descriptionString: NSLocalizedString("To record video footage as described in the", comment:"AgreementNode : record : text"),
            hasAgreedBool: false
        )
        ,AgreementNode(
            descriptionString: NSLocalizedString("To start the job promptly at time specified", comment:"AgreementNode : startOnTime : text"),
            hasAgreedBool: false
        )
        ,AgreementNode(
            descriptionString: NSLocalizedString("To be at the address at the designated area", comment:"AgreementNode : beAtAddress : text"),
            hasAgreedBool: false
        )
    ]
    
    func createDataProvider() {
        dataProvider                        = DefaultDataProvider(items:nodes, delegate :self)
        dataSource                          = CollectionViewDataSource(collectionView:collectionView!, dataProvider: dataProvider, delegate:self)
        
        submitButton?.enabled               = false
        let numRowsSelected = nodes.reduce(0) { $0 + Int($1.hasAgreedBool) }
        submitButton?.enabled               = (numRowsSelected == nodes.count)
        if (numRowsSelected == nodes.count) {
            superview?.backgroundColor          = UIColor.mountainMeadow()
        } else {
            superview?.backgroundColor          = UIColor.silver()
        }
    }

    func show() {
        hidden                              = false
        bottomConstraint?.constant          = 0
        layoutIfNeeded()
        bottomConstraint?.constant          = -hiddenHeight
        layoutIfNeeded()
        
        UIView.animateWithDuration(0.75,
                                   delay: 0.3,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                self?.bottomConstraint?.constant          = 0
                self?.layoutIfNeeded()
                                    
            }, completion: { finished in
                
        })
    }
    
    func hide() {
        let h = -hiddenHeight
        UIView.animateWithDuration(0.75,
                                   delay: 0.3,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                self?.bottomConstraint?.constant = h
                self?.layoutIfNeeded()
                                    
            }, completion: { [weak self] finished in
                self?.hidden                = true
 
        })
    }
    
}

extension AgreementFormModuleView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor                     = UIColor.isabelline()
        
        layer.masksToBounds                 = false
        layer.cornerRadius                  = 2
     
        collectionView?.backgroundColor     = UIColor.munsell()
        collectionView?.delegate            = self
        
        containerView?.layer.masksToBounds  = false
        containerView?.layer.cornerRadius   = 2
        containerView?.layer.shadowColor    = UIColor.bistre().CGColor
        containerView?.layer.shadowOpacity  = 0.5
        containerView?.layer.shadowOffset   = CGSizeMake(0, 0.5)
        containerView?.layer.shadowRadius   = 0.8

        let titleText                       = NSLocalizedString("In order for you to apply for this job, you must agree to the tasks below by tapping each one.", comment: "AgreementFormModuleView : titleLabel : text")
        titleLabel?.text                    = titleText
        titleLabel?.textColor               = UIColor.bistre()
        titleLabel?.numberOfLines           = 0
        titleLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s12)
        
        closeButton?.setImage(UIImage.iconCloseXBlack(), forState: .Normal)
        closeButton?.setTitle("", forState: .Normal)
        
        let submitText                      = NSLocalizedString("SUBMIT", comment: "AgreementFormModuleView : submitButton : text")
        submitButton?.setTitle(submitText, forState: .Normal)
        submitButton?.enabled               = false

        createDataProvider()
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout                          = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                               = collectionView!.frame.width * 0.5
        let h                               = collectionView!.frame.height * 0.5
        layout.itemSize                     = CGSizeMake(w,h)
    }
    
}

extension AgreementFormModuleView : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        nodes[indexPath.row].hasAgreedBool = !nodes[indexPath.row].hasAgreedBool
        createDataProvider()
    }
}

extension AgreementFormModuleView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<AgreementNode>]?) {
        dataSource.processUpdates(updates)
    }
}

extension AgreementFormModuleView : DataSourceDelegate {
    func cellIdentifierForObject(object:AgreementNode) -> String {
        return AgreementCollectionViewCell.Identifier
    }
}