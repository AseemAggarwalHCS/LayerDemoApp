//
//  SampleConversationListViewController.swift
//  LayerApp
//
//  Created by Aseem Aggarwal on 11/30/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import Atlas
import UIKit

class SampleConversationListViewController: ATLConversationListViewController, ATLConversationListViewControllerDataSource, ATLConversationListViewControllerDelegate {

    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, titleForConversation conversation: LYRConversation!) -> String! {
        var participants = conversation.participants
        participants.remove(layerClient.authenticatedUserID)
        
        if (participants.count > 0) {
            return participants.first as! String
        } else {
            return "Some"
        }
    }
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, didSelectConversation conversation: LYRConversation!) {
        let controller = SampleConversationViewController.init(layerClient: LayerManager.sharedInstance.layerClient)
        
        controller.conversation = conversation
        controller.displaysAddressBar = true
        controller.dataSource = controller
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
