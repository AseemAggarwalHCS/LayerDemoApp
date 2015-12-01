//
//  SampleConversationViewController.swift
//  LayerApp
//
//  Created by Aseem Aggarwal on 11/30/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import Atlas
import UIKit

class SampleConversationViewController: ATLConversationViewController, ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldDisplayAvatarItemForAuthenticatedUser = true
        self.shouldDisplayAvatarItemForOneOtherParticipant = true
    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        
        if ((participantIdentifier) != nil) {
            let user = ATLUser()
            user.participantIdentifier = participantIdentifier
            user.firstName = participantIdentifier
            return user
        }
        return nil;

    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.grayColor()]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        return NSAttributedString.init(string: dateFormatter.stringFromDate(date), attributes: attributes)
    }

    func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        if (recipientStatus.count == 0) {
            return nil
        }

        
        let mergedStatuses = NSMutableAttributedString()
        

        for (_, participant) in recipientStatus.keys.enumerate() {
            let status = recipientStatus[participant]?.unsignedIntValue
            if (participant == self.layerClient.authenticatedUserID) {
                break
            }
            
            let checmark = "✔︎"
            var textColor = UIColor.lightGrayColor()

            switch(Int(status!)) {
            case LYRRecipientStatus.Sent.rawValue:
                textColor = UIColor.lightGrayColor()
            case LYRRecipientStatus.Delivered.rawValue:
                textColor = UIColor.orangeColor()
            case LYRRecipientStatus.Read.rawValue:
                textColor = UIColor.greenColor()
            default: break
            }
            
            let statusString = NSAttributedString.init(string: checmark, attributes: [NSForegroundColorAttributeName: textColor])
            mergedStatuses.appendAttributedString(statusString)
        }

        return mergedStatuses
    }
    
    func conversationViewController(viewController: ATLConversationViewController!, didSendMessage message: LYRMessage!) {
        print("Message was sent")
    }
}
