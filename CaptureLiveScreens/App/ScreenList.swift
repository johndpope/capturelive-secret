//
//  ScreenList.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/4/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

protocol StoryboardScreenable {
    var desiredStoryBoard:String { get }
    var desiredScreen:String { get }
}

var CaptureScreensDict = [
    
    [
         "storyboard"   : "LoggedIn"
        ,"section"      : "Job Screens"
        ,"screens"      : [
            "LiveStreamViewController"
            ,"EventsListViewController"
            ,"EventDetailViewController"
            ,"EventInfoModalViewController"
            ,"JobHistoryViewController"
            ,"CompletedJobViewController"
            ,"GetToJobViewController"
            ,"OnTheJobViewController"
            ,"JobReceiptViewController"
        ]
    ]
    ,
    [
         "storyboard"   : "LoggedIn"
        ,"section"      : "Modal Screens"
        ,"screens"      : [
             "ModalHiredViewController"
            ,"ModalReminder24HoursViewController"
            ,"ModalReminder1HourViewController"
            ,"ModalCancelledViewController"
        ]
    ]
    ,[
         "storyboard"   : "LoggedIn"
        ,"section"      : "Side Nav Screens"
        ,"screens"      : [
            "SideNavViewController"
            ,"PaypalViewController"
            ,"SupportViewController"
            ,"FAQsViewController"
            ,"HowItWorksViewController"
            ,"TermsConditionsViewController"
            ,"PrivacyPolicyViewController"
            ,"NotificationsViewController"
        ]
    ]
    ,
    [
         "storyboard"   : "LoggedOut"
        ,"section"      : "LoggedOut"
        ,"screens"      : [
            "Onboard1ViewController"
            ,"Onboard2ViewController"
            ,"Onboard3ViewController"
            ,"Onboard4ViewController"
            ,"PhoneLoginViewController"
            ,"AuthorizationCodeViewController"
            ,"FacebookAuthViewController"
            ,"CreateProfileViewController"
            ,"TermsOfServiceRegistrationViewController"
            ,"SubmittedViewController"
        ]
    ]

]