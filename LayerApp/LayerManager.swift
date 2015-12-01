//
//  LayerManager.swift
//  LayerDemoApp
//
//  Created by Aseem Aggarwal on 11/18/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import Foundation
import LayerKit

class LayerManager: NSObject {
    static let sharedInstance = LayerManager() //layer:///apps/staging/74f4d0fe-8cf8-11e5-9a5d-afaa43003a92
    private let appId = NSURL(string: "layer:///apps/staging/b1725e12-8d1a-11e5-b230-a2724e00237a")
    lazy var layerClient: LYRClient = {
        var client = LYRClient(appID: self.appId)
        return client
    }()
    
    let  LQSPushMessageIdentifierKeyPath = "layer.message_identifier"
    
    
    private var conversation: LYRConversation?
    
    func establishConnection() {
        if (!self.layerClient.isConnected) {
            layerClient.connectWithCompletion({ (success: Bool, error: NSError!) -> Void in
                if (success) {
                    print("Client is Connected!")
                } else {
                    print("Client not Connected due to error: \(error.debugDescription)")
                }
                NSNotificationCenter.defaultCenter().postNotificationName("Connected", object: nil, userInfo: nil)
            })
        }
    }
    
    func isConnected() -> Bool {
        return layerClient.isConnected
    }
    
    func isAuthenticated() -> Bool {
        print("\(layerClient.authenticatedUserID)")
        return layerClient.authenticatedUserID != nil
    }
    
    func currentUserID() -> String {
        return layerClient.authenticatedUserID
    }
    
    func pushNotification(deviceToken: NSData) {
        do {
             try layerClient.updateRemoteNotificationDeviceToken(deviceToken)
        } catch let error {
            print("notification error:\(error)")
        }
    }
    
    func messageFromRemoteNotification(remoteNotification:[NSObject : AnyObject]) -> LYRMessage? {
        
        
        let stringUrl = remoteNotification[LQSPushMessageIdentifierKeyPath] as! String
        
        let messageUrl = NSURL(string: stringUrl)
        
            
        let query = LYRQuery(queryableClass: LYRMessage.self)
        var values: Set<NSURL> = Set()
        values.insert(messageUrl!)
        
        // The conversation property is equal to the supplied LYRConversation object.
        let conversationPredicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsIn, value: values)
        query.predicate = conversationPredicate
        
        let messages: NSOrderedSet?
        
        do {
            messages = try layerClient.executeQuery(query)
            print("Query contains %lu messages \(messages!.count)")
            let message = messages!.firstObject as! LYRMessage
            
            if message.parts.count > 0 {
                let messagePart = message.parts[0] as! LYRMessagePart
                print("Pushed Message Contents: \(String(data: messagePart.data, encoding: NSUTF8StringEncoding)))")
            }
            
            return message
            
        } catch let error {
            print("\(error)")
        }
        
        return nil
    }

    func getUnreadMessageCountForConversation() -> Int {
        var unreadMessages :Int = 0
        
        let query = LYRQuery(queryableClass: LYRMessage.self)
        // The conversation property is equal to the supplied LYRConversation object.
        let conversationPredicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.IsEqualTo, value: conversation)
        // Messages must be unread
        let unreadPredicate = LYRPredicate(property: "isUnread", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
        // Messages must not be sent by the authenticated user
        let userPredicate = LYRPredicate(property: "sender.userID", predicateOperator: LYRPredicateOperator.IsNotEqualTo, value: layerClient.authenticatedUserID)
        
        query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.And, subpredicates: [conversationPredicate, unreadPredicate, userPredicate])
        
        var error : NSError?
        unreadMessages = Int(layerClient.countForQuery(query, error: &error))
        print("Unread messages: \(unreadMessages)")
        
        if error == nil{
            return unreadMessages
        } else {
            print("Query failed with error: \(error?.localizedDescription)")
            return 0
        }
    }

    func getMessageForConsversation(newConservation:LYRConversation) {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        // The conversation property is equal to the supplied LYRConversation object.
        let conversationPredicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.IsEqualTo, value: newConservation)
        
        // Messages must be unread
        query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.And, subpredicates: [conversationPredicate])
        layerClient.executeQuery(query) { (messages:NSOrderedSet!, error:NSError!) -> Void in
            print("\(messages.lastObject)")
        }
    }
    
    func deAuthenticateUser(completion: (Bool) -> Void) {
        layerClient.deauthenticateWithCompletion { (success:Bool, error:NSError!) -> Void in
            if (!success) {
                print("Failed to deauthenticate user:  \(error.debugDescription)")
            } else {
                print("User was deauthenticated")
            }
            completion(success)
        }
    }
    
    func authenticateUser(userId: String,completion: ((Bool, NSError!) -> Void)!) {
        layerClient.requestAuthenticationNonceWithCompletion { (nonce: String!, error:NSError!) -> Void in
            if let _ = nonce {
                self.requestIdentityTokenForUserId(userId, nonce: nonce, completion: { (identityToken, error: NSError!) -> Void in
                    
                    if(error == nil) {
                        self.layerClient.authenticateWithIdentityToken(identityToken, completion: { (authenticateUseId: String!, error:NSError!) -> Void in
                            
                            if ((completion) != nil) {
                                if (error == nil) {
                                    print("Layer Authenticated as User: \(authenticateUseId)");
                                    completion(true, nil)
                                } else {
                                    completion(false, error);
                                }
                            }
                            
                        })
                    } else {
                        completion(false,error)
                    }
                })
            } else {
                if (completion != nil) {
                    completion(false,error)
                }
            }
        }
    }
    
    func sendMessage(message: String,userId: String) {
        let users = Set([userId])
        let MIMETypeTextPlain = "text/plain"
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        let messagePart = LYRMessagePart(MIMEType: MIMETypeTextPlain, data: messageData)
        let defaultConfiguration = LYRPushNotificationConfiguration()
        defaultConfiguration.alert = message
        defaultConfiguration.sound = "layerbell.caf"
        let pushOptions = [LYRMessageOptionsPushNotificationConfigurationKey: defaultConfiguration]
        let message =  try! layerClient.newMessageWithParts([messagePart], options: pushOptions)
    
        do {
            conversation = try layerClient.newConversationWithParticipants(users, options: [LYRConversationOptionsDistinctByParticipantsKey : "YES"])
            sendMessage(message)
        } catch let error {
          print("already exist\(error)")
            let query = LYRQuery(queryableClass: LYRConversation.self)
            let value: [AnyObject] = Array(users)
            
            query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value:value)
            
            LayerManager.sharedInstance.layerClient.executeQuery(query, completion: { (conversations:NSOrderedSet!, error:NSError!) -> Void in
                self.conversation = conversations.lastObject as? LYRConversation
                self.sendMessage(message)
            })
        }
    }
    
    func sendMessage(message: LYRMessage) {
        do {
            try self.conversation!.sendMessage(message)
        } catch let error {
            print("error:\(error)")
        }
    }
    
    func requestIdentityTokenForUserId(userId: String,nonce: String,completion: ((identityToken: String, error: NSError!) -> Void)!) {
        let identityTokenURL = NSURL(string: "https://layer-identity-provider.herokuapp.com/identity_tokens")!
        let request = NSMutableURLRequest(URL: identityTokenURL)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let parameters: [String: AnyObject]  = ["app_id": (self.appId?.absoluteString)!, "user_id": userId,"nonce": nonce]
        
        let requestBody = try! NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        request.HTTPBody = requestBody
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(identityToken: "", error: error)
                })
                return;
            }
            
            let responseObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.AllowFragments])
            
            if (responseObject["error"] != nil) {
                let identityToken = responseObject["identity_token"] as! String
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(identityToken: identityToken, error: nil)
                })

            } else {
                let domain = "layer-identity-provider.herokuapp.com"
                let code = responseObject["status"] as! Int
                let userInfo = [NSLocalizedDescriptionKey: "Layer Identity Provider Returned an Error.",NSLocalizedRecoverySuggestionErrorKey: "There may be a problem with your APPID."]
                let error = NSError(domain: domain, code: code, userInfo: userInfo)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(identityToken: "",error: error)
                })
            }
        }
        .resume()
    }
    
}