//
//  UserModel.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 4/28/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import Foundation

class UserModel: NSObject, NSCoding {
    
    var username = ""
    var email = ""
    var password = ""
    var password_verify = ""
    var accessToken = ""
    var refreshToken = ""
    var accessExpires: Date?
    var refreshExpires: Date?
    
    func clean() {
        self.username = ""
        self.email = ""
        self.password = ""
        self.password_verify = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.accessExpires = Date.init()
        self.refreshExpires = Date.init()
    }
    
    enum Keys: String {
        case username = "username"
        case email = "email"
        case password = "password"
        case password_verify = "password_verify"
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case accessExpires = "accessExpires"
        case refreshExpires = "refreshExpires"
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(username, forKey: Keys.username.rawValue)
        aCoder.encode(email, forKey: Keys.email.rawValue)
        aCoder.encode(password, forKey: Keys.password.rawValue)
        aCoder.encode(password_verify, forKey: Keys.password_verify.rawValue)
        aCoder.encode(accessToken, forKey: Keys.accessToken.rawValue)
        aCoder.encode(refreshToken, forKey: Keys.refreshToken.rawValue)
        aCoder.encode(accessExpires, forKey: Keys.accessExpires.rawValue)
        aCoder.encode(refreshExpires, forKey: Keys.refreshExpires.rawValue)
    }
    
    override init() {
        super.init()
    }
    
    init(email: String, password: String) {
        super.init()
        self.email = email
        self.password = password
    }
    
    init(username: String,
         email: String,
         password: String,
         password_verify: String,
         accessToken: String,
         refreshToken: String,
         accessExpires: Date,
         refreshExpires: Date) {
        
        super.init()
        self.username = username
        self.email = email
        self.password = password
        self.password_verify = password_verify
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessExpires = accessExpires
        self.refreshExpires = refreshExpires
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let username = aDecoder.decodeObject(forKey: Keys.username.rawValue) as! String
        let email = aDecoder.decodeObject(forKey: Keys.email.rawValue) as! String
        let password = aDecoder.decodeObject(forKey: Keys.password.rawValue) as! String
        let password_verify = aDecoder.decodeObject(forKey: Keys.password_verify.rawValue) as! String
        let accessToken = aDecoder.decodeObject(forKey: Keys.accessToken.rawValue) as! String
        let refreshToken = aDecoder.decodeObject(forKey: Keys.refreshToken.rawValue) as! String
        let accessExpires = aDecoder.decodeObject(forKey: Keys.accessExpires.rawValue) as! Date
        let refreshExpires = aDecoder.decodeObject(forKey: Keys.refreshExpires.rawValue) as! Date

        self.init( username:            username,
                   email:               email,
                   password:            password,
                   password_verify:     password_verify,
                   accessToken:         accessToken,
                   refreshToken:        refreshToken,
                   accessExpires:       accessExpires,
                   refreshExpires:      refreshExpires
        )
    }
    
}
