//
//  HelperFunctions.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 5/7/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import Foundation

// MARK: Persistance for userDetails
let userDetailsFileURL: URL = {
    
    let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // The filename for userDetails
    let filenameURL = docPath.appendingPathComponent("userDetails.txt")
    print("filenameURL: ", filenameURL)
    
    return filenameURL
}()

func openOrCreateUserDetailsObject() -> UserModel {
    
    let optionalData = try? Data(contentsOf: userDetailsFileURL)
    
    guard let data = optionalData else {
        return UserModel()
    }
    
    return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UserModel
}

func save(userDetails: UserModel) {
    
    let data = try! NSKeyedArchiver.archivedData(withRootObject: userDetails as Any, requiringSecureCoding: false)
    
    do {
        try data.write(to: userDetailsFileURL)
        print("Save successful")
    } catch {
        print("Couldn't write to save file: " + error.localizedDescription)
    }
}

func deleteDoc() {
    do {
        try FileManager.default.removeItem(at: userDetailsFileURL)
    } catch {
        print("Error deleting file: " + error.localizedDescription)
    }
}

func isValidEmail(testString: String) -> Bool {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    
    return emailTest.evaluate(with: testString)
}


func loginUser(email: String, password: String, completion: @escaping (UserModel) -> ())  {
    
    var userDetails: UserModel = UserModel(email: email, password: password)
    
    let parameters = [
        "username": email,
        "password": password,
        ]
    
    guard let url = URL(string: "https://text-message-api.herokuapp.com/auth_api/accounts/login/")
        //        guard let url = URL(string: "http://127.0.0.1:8000/auth_api/accounts/login/")
        else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        else { return }
    
    request.httpBody = httpBody
    
    let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let response = response as? HTTPURLResponse {
            if response.statusCode != 200 {
                DispatchQueue.main.async {
                    //                        self.showToast(controller: self, message: "Sorry, login credentials invalid", seconds: 2.0)
                    //                        self.errorLabel.text = "Invalid credentials, try again."
                    //                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    //                        self.networking = false
                }
                return
            }
        }
        
        if let data = data {
            do {
                let json_data = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print("\njson data after posting: \n", json_data)
                
                let token_response = json_data
                userDetails.accessToken = token_response["access"] as? String ?? ""
                userDetails.refreshToken = token_response["refresh"] as? String ?? ""
                
                let accessExpiresString = token_response["access_expires"] as? String ?? ""
                let refreshExpiresString = token_response["refresh_expires"] as? String ?? ""
                //                    print("time strings:")
                //                    print(accessExpiresString)
                //                    print(refreshExpiresString)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                //                    let aeExpires = dateFormatter.date(from: accessExpiresString)
                //                    print("aeExpires:", aeExpires as Any)
                
                userDetails.accessExpires = dateFormatter.date(from: accessExpiresString)
                userDetails.refreshExpires = dateFormatter.date(from: refreshExpiresString)
                
                //                    print("userDetails:", self.userDetails)
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.main.async {
        
            completion(userDetails)
        }
    }
    session.resume()
    
}
