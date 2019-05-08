//
//  QueryServer.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 5/7/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import Foundation

class QueryServer {
    
    typealias JSONData = [[String: Any]]
    typealias QueryResult = ([MessageBundle]?, String) -> ()
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
    var messagesData: [MessageBundle] = []
    var errorMessage = ""
    
    func getMessages(completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        
        guard let url = URL(string: "https://text-message-api.herokuapp.com/auth_api/messageapp")
            //        guard let url = URL(string: "http://127.0.0.1:8000/auth_api/messageapp")
            else {
                return
        }
        
        dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
            defer { self.dataTask = nil }
            
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.updateMessagesData(data)
                
                DispatchQueue.main.async {
                    completion(self.messagesData, self.errorMessage)
                }
            }
            
        }
        dataTask?.resume()
    } // end getMessages()
    
    func updateMessagesData(_ data: Data) {
        
        var jsonData: JSONData?
        self.messagesData.removeAll()
        
        do {
            jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? JSONData
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: " + "\(parseError.localizedDescription)" + "\n"
            return
        }
        
        let mArray = jsonData! as JSONData

        for object in mArray {
            let email = object["email"] as? String ?? ""
            let message = object["message"] as? String ?? ""
            self.messagesData.append(MessageBundle(email: email, message: message))
        }
    }
}
