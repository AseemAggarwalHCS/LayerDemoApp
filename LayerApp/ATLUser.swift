//
//  ATLUser.swift
//  LayerApp
//
//  Created by Aseem Aggarwal on 11/30/15.
//  Copyright © 2015 Aseem Aggarwal. All rights reserved.
//

import Atlas

class ATLUser: NSObject , ATLParticipant{
    var firstName: String!
    
    /**
     @abstract The last name of the participant as it should be presented in the user interface.
     */
    var lastName: String!
    
    /**
     @abstract The full name of the participant as it should be presented in the user interface.
     */
    var fullName: String!
    
    /**
     @abstract The unique identifier of the participant as it should be used for Layer addressing.
     @discussion This identifier is issued by the Layer identity provider backend.
     */
    var participantIdentifier: String!
    
    var avatarImageURL: NSURL!
    
    /**
     @abstract Returns the avatar image of the receiver.
     */
    var avatarImage: UIImage!
    
    /**
     @abstract Returns the avatar initials of the receiver.
     */
    var avatarInitials: String!

}
