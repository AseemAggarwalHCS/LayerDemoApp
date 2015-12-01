//
//  ViewController.swift
//  LayerDemoApp
//
//  Created by Aseem Aggarwal on 11/18/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import UIKit
import LayerKit
import SVProgressHUD
import Atlas

class ViewController: UIViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    
    @IBOutlet var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.showSuccessWithStatus("Connecting...")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("isConnected:"), name: "Connected", object: nil)
        
    }
    
    func isConnected(notification: NSNotification) {
        if (LayerManager.sharedInstance.isConnected()) {
            if LayerManager.sharedInstance.isAuthenticated() {
                let controller = SampleConversationListViewController.init(layerClient: LayerManager.sharedInstance.layerClient)
                controller.delegate = controller
                controller.dataSource = controller
                controller.allowsEditing = false
                controller.shouldDisplaySearchController = false
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let alertController = UIAlertController(title: "", message: "Network established successfully.Login in to send message", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "", message: "Network Not establish.Try again", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction func authenticateUser(sender: AnyObject) {
        if (LayerManager.sharedInstance.isAuthenticated()) {
            let controller = SampleConversationListViewController.init(layerClient: LayerManager.sharedInstance.layerClient)
            controller.delegate = controller
            controller.dataSource = controller
            controller.allowsEditing = false
            controller.shouldDisplaySearchController = false
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            SVProgressHUD.showSuccessWithStatus("Authenticating...")
            LayerManager.sharedInstance.authenticateUser(userIdTextField.text!) { (success:Bool, error:NSError!) -> Void in
                SVProgressHUD.dismiss()
                if error == nil && success {
                    let controller = SampleConversationListViewController.init(layerClient: LayerManager.sharedInstance.layerClient)
                    controller.delegate = controller
                    controller.dataSource = controller
                    controller.allowsEditing = false
                    controller.shouldDisplaySearchController = false
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    let alertController = UIAlertController(title: "", message: "Not Authenticated due to error:\(error.debugDescription)", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

