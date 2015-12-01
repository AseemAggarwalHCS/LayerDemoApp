//
//  UserViewController.swift
//  LayerDemoApp
//
//  Created by Aseem Aggarwal on 11/18/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import UIKit
import LayerKit
import SVProgressHUD
import Atlas

class UserViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var recipentId: UITextField!
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageRecievedLabel: UILabel!
    @IBAction func sendMessage(sender: AnyObject) {
        LayerManager.sharedInstance.sendMessage(messageTextField.text!, userId: recipentId.text!)
    }
    @IBAction func logout(sender: AnyObject) {
        SVProgressHUD.showSuccessWithStatus("Logout...")
        LayerManager.sharedInstance.deAuthenticateUser({ (success:Bool) -> Void in
            SVProgressHUD.dismiss()
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "", message: "Logout failed", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveLayerObjectsDidChangeNotification:"), name: LYRClientObjectsDidChangeNotification, object: nil)
    }
        
    func didReceiveLayerObjectsDidChangeNotification(notification:NSNotification) {
        
        let userInfo = notification.userInfo

        let changes = userInfo?[LYRClientObjectChangesUserInfoKey] as? [LYRObjectChange]

        if let unwrappedChanges = changes {
            
            for change in unwrappedChanges {
                let changeObject = change.object
                let updateKey = change.type
                if (changeObject .isKindOfClass(LYRConversation.self)) {
                    // Object is a conversation
//                    let message = changeObject as! LYRConversation
//                    
//                    switch(updateKey) {
//                        case .Create: break
//                        case .Update: break
//                        case .Delete: break
//                    }
                } else if (changeObject .isKindOfClass(LYRMessage.self)){
                    // Object is a message
                    let message = changeObject as! LYRMessage
                    if message.isUnread {
                        let messageParts = message.parts as! [LYRMessagePart]
                        if messageParts.count > 0 {
                            let messagePart = messageParts.last
                            if let unwrappedData = messagePart?.data {
                                let dataString = String(data: unwrappedData, encoding: NSUTF8StringEncoding)
                                messageRecievedLabel.text = dataString
                                senderLabel.text = message.sender.userID
                            }
                        }
                    }
                    switch(updateKey) {
                    case .Create: break
                    case .Update: break
                    case .Delete: break
                    }
                } else if (changeObject .isKindOfClass(LYRMessagePart.self)) {
//                    let message = changeObject as! LYRMessagePart
//                    switch(updateKey) {
//                    case .Create: break
//                    case .Update: break
//                    case .Delete: break
//                    }
                }
            }
        
        }
        
        
//        let query = LYRQuery(queryableClass: LYRConversation.self)
//        let value: [AnyObject] = [LayerManager.sharedInstance.currentUserID()]
//        
//        query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value:value)
//        
////        query.predicate = LYRCompoundPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: value)
//        
//        query.sortDescriptors =  [NSSortDescriptor(key: "createdAt", ascending: false)]
//        
//        LayerManager.sharedInstance.layerClient.executeQuery(query, completion: { (conversations:NSOrderedSet!, error:NSError!) -> Void in
//            if conversations != nil && conversations.count > 0 {
//                let conversation = conversations.lastObject as! LYRConversation
//                LayerManager.sharedInstance.getMessageForConsversation(conversation)
//                print(conversations)
//            }
//        })
    }

}
