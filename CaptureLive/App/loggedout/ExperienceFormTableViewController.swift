//
//  EquipmentFormTableViewController.swift
//  Current
//
//  Created by Scott Jones on 4/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureModel

struct CheckBoxAndButton {
    let checkBox:CMCheckbox
    let button:UIButton
}

protocol ExperienceTableProtocol {
    func textFieldHasReturned()
    func checkBoxSelected()
}

private let ExperienceListTableIndex = 2
class ExperienceFormTableViewController: UITableViewController {

    private var experienceListTableHeight:CGFloat = 600
   
    @IBOutlet weak var bioLabel:UILabel?
    @IBOutlet weak var bioTextView:UITextView?
    @IBOutlet weak var howManyYearsLabel:UILabel?
    @IBOutlet weak var oneYearLabel:UILabel?
    @IBOutlet weak var fiveYearsLabel:UILabel?
    @IBOutlet weak var tenYearsLabel:UILabel?
    @IBOutlet weak var whatHaveYouShot:UILabel?
    @IBOutlet weak var oneYearCheckBox:CMCheckbox?
    @IBOutlet weak var fiveYearsCheckBox:CMCheckbox?
    @IBOutlet weak var tenYearsCheckBox:CMCheckbox?
    @IBOutlet weak var oneYearButton:UIButton?
    @IBOutlet weak var fiveYearsButton:UIButton?
    @IBOutlet weak var tenYearsButton:UIButton?
    @IBOutlet weak var typeEventTableView:UITableView?
    
    var checkBoxAndButtons:[CheckBoxAndButton]!
    var interactionDelegate:ExperienceTableProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkBoxAndButtons = [
             CheckBoxAndButton(checkBox: oneYearCheckBox!, button:oneYearButton!)
            ,CheckBoxAndButton(checkBox: fiveYearsCheckBox!, button:fiveYearsButton!)
            ,CheckBoxAndButton(checkBox: tenYearsCheckBox!, button:tenYearsButton!)
        ]
        
        tableView.allowsSelection           = false
        typeEventTableView?.scrollEnabled   = false
        
        let bioText                         = NSLocalizedString("Photography Bio", comment: "ExperienceFormTable : bioLabel : text")
        bioLabel?.text                      = bioText
        bioLabel?.font                      = UIFont.sourceSansPro(.Bold, size: 18)
        bioLabel?.textColor                 = UIColor.greyDarkCurrent()
        bioLabel?.adjustsFontSizeToFitWidth = true
        bioLabel?.numberOfLines             = 0
   
        bioTextView?.backgroundColor        = UIColor.whiteColor()
        bioTextView?.delegate               = self
        
        let howManyYearsText                = NSLocalizedString("How many years of experience do you have filming videos or shooting photography?", comment: "ExperienceFormTable : howManyYearsLabel : text")
        howManyYearsLabel?.text             = howManyYearsText
        howManyYearsLabel?.font             = UIFont.sourceSansPro(.Bold, size: 18)
        howManyYearsLabel?.textColor        = UIColor.greyDarkCurrent()
        howManyYearsLabel?.adjustsFontSizeToFitWidth = true
        howManyYearsLabel?.numberOfLines    = 0

        let whatHaveYouShotText             = NSLocalizedString("What have you shot in the past?", comment: "ExperienceFormTable : whatHaveYouShot : text")
        whatHaveYouShot?.text               = whatHaveYouShotText
        whatHaveYouShot?.font               = UIFont.sourceSansPro(.Bold, size: 18)
        whatHaveYouShot?.textColor          = UIColor.greyDarkCurrent()
        whatHaveYouShot?.adjustsFontSizeToFitWidth = true
        whatHaveYouShot?.numberOfLines      = 0

        let oneYearText                     = NSLocalizedString("0-1 yrs", comment: "ExperienceFormTable : oneYearLabel : text")
        oneYearLabel?.text                  = oneYearText
        oneYearLabel?.font                  = UIFont.sourceSansPro(.Bold, size: 18)
        oneYearLabel?.textColor             = UIColor.greenCurrent()
        oneYearLabel?.adjustsFontSizeToFitWidth = true
        oneYearLabel?.numberOfLines         = 0

        let fiveYearsText                   = NSLocalizedString("2-5 yrs", comment: "ExperienceFormTable : fiveYearsLabel : text")
        fiveYearsLabel?.text                = fiveYearsText
        fiveYearsLabel?.font                = UIFont.sourceSansPro(.Bold, size: 18)
        fiveYearsLabel?.textColor           = UIColor.greenCurrent()
        fiveYearsLabel?.adjustsFontSizeToFitWidth = true
        fiveYearsLabel?.numberOfLines       = 0

        let tenYearText                     = NSLocalizedString("5+ yrs", comment: "ExperienceFormTable : tenYearsLabel : text")
        tenYearsLabel?.text                 = tenYearText
        tenYearsLabel?.font                 = UIFont.sourceSansPro(.Bold, size: 18)
        tenYearsLabel?.textColor            = UIColor.greenCurrent()
        tenYearsLabel?.adjustsFontSizeToFitWidth = true
        tenYearsLabel?.numberOfLines        = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.oneYearButton?.addTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
        self.fiveYearsButton?.addTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
        self.tenYearsButton?.addTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.oneYearButton?.removeTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
        self.fiveYearsButton?.removeTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
        self.tenYearsButton?.removeTarget(self, action: #selector(yearsSelected(_:)), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == ExperienceListTableIndex {
            return experienceListTableHeight + 60
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
        }
    }
    
    func changeCategoryHeight(height:CGFloat) {
        experienceListTableHeight = height
        tableView.reloadData()
    }
    
    func selectLevel(level:Level) {
        clearCheckBoxes()
        switch level {
        case .TwoToFive:
            fiveYearsCheckBox?.selected = true
        case .FiveToTen:
            tenYearsCheckBox?.selected = true
        default:
            oneYearCheckBox?.selected = true
        }
    }
    
    func yearsSelected(sender:UIButton) {
        let cboxes = checkBoxAndButtons.filter{ $0.button == sender }.flatMap { $0 }
        guard let cb = cboxes.first else { return }
        clearCheckBoxes()
        cb.checkBox.selected = true
        interactionDelegate?.checkBoxSelected()
    }
    
    func clearCheckBoxes() {
        for cb in checkBoxAndButtons { cb.checkBox.selected = false }
    }
    
    var level:Level? {
        let cboxes = checkBoxAndButtons.filter{ $0.checkBox.selected }.flatMap { $0 }
        guard let cb = cboxes.first else { return nil }
        
        switch cb.checkBox {
        case fiveYearsCheckBox!:
            return .TwoToFive
        case tenYearsCheckBox!:
            return .FiveToTen
        default:
            return .LessThanOne
        }
    }

    var levelPicked:Bool {
        return level != nil
    }
    
    var bioPopulated:Bool {
        return bioTextView?.text.characters.count > 0
    }
    
}


extension ExperienceFormTableViewController : UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            interactionDelegate?.textFieldHasReturned()
            return false
        }
        return true
    }
    
}









