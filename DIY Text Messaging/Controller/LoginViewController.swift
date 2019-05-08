//
//  LoginViewController.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 5/1/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var loginStatus: LoginScreen = .username
    var userDetails: UserModel!
    var networking: Bool = false
    
    func loginUser() {
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.networking = true
        
        let parameters = [
            "username": self.userDetails.email,
            "password": self.userDetails.password,
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
                        self.errorLabel.text = "Invalid credentials, try again."
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.networking = false
                    }
                    return
                }
            }
            
            if let data = data {
                do {
                    let json_data = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print("\njson data after posting: \n", json_data)
                    
                    let token_response = json_data
                    self.userDetails.accessToken = token_response["access"] as? String ?? ""
                    self.userDetails.refreshToken = token_response["refresh"] as? String ?? ""
                    
                    let accessExpiresString = token_response["access_expires"] as? String ?? ""
                    let refreshExpiresString = token_response["refresh_expires"] as? String ?? ""
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    self.userDetails.accessExpires = dateFormatter.date(from: accessExpiresString)
                    self.userDetails.refreshExpires = dateFormatter.date(from: refreshExpiresString)
                    
                } catch {
                    print(error)
                }
            }
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.networking = false
                
                let messagingVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagingViewController") as? MessagingViewController
                
                if let messagingVC = messagingVC {
                    messagingVC.userDetails = self.userDetails
                    self.navigationController?.pushViewController(messagingVC, animated: true)
                }
            }
        }
        session.resume()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = textField.text! as NSString // text existing in textField already
        let resultText = currentText.replacingCharacters(in: range, with: string) as NSString // resulting text after user changes
        if String(resultText) == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        return true // always allow user input
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if app is networking, don't allow repeated submissions
        if networking == true {
            return false
        } else {
            nextTapped()
            return true
        }
    }
    
    @objc func nextTapped() {
        
        if loginStatus == .username {
            
            // test for valid email - if not valid, show error message
            if !isValidEmail(testString: inputTextField.text!) {
                errorLabel.text = "Invalid email, try again."
                return
            }
            
            self.userDetails.email = inputTextField.text!
            
            let passwordLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            
            if let passwordloginVC = passwordLoginVC {
                passwordloginVC.loginStatus = .password
                passwordloginVC.userDetails = self.userDetails
                print("username: ", self.userDetails.username)
                self.navigationController?.pushViewController(passwordloginVC, animated: true)
            }
            
        } else if loginStatus == .password {
            // login user with server
            self.userDetails.password = inputTextField.text!
            
            loginUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if loginStatus == .username {
            userDetails = UserModel()
        }
        
        self.inputTextField.delegate = self
        self.inputTextField.returnKeyType = .next
        self.inputTextField.enablesReturnKeyAutomatically = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        switch loginStatus {
        case .username:     inputLabel.text = "email"
        case .password:     inputLabel.text = "password"
                            inputTextField.isSecureTextEntry = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputTextField.borderStyle = .none
        inputTextField.becomeFirstResponder()
        errorLabel.text = ""
        self.navigationController!.isNavigationBarHidden = false
    }

}
