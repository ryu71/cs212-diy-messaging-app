//
//  MessageModel.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 5/7/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import Foundation

struct MessageBundle {
    var email: String = ""
    var message: String = ""
    
    init() {
        self.email = ""
        self.message = ""
    }
    
    init(email: String, message: String) {
        self.email = email
        self.message = message
    }
}
