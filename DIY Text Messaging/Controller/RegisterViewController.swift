//
//  RegisterViewController.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 4/27/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    var registerStatus: RegisterScreen = .username
    var userDetails: UserModel = UserModel()
    
    func registerUser() {
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let parameters = [
            "username":         self.userDetails.username,
            "email":            self.userDetails.email,
            "password":         self.userDetails.password,
            "password_verify":  self.userDetails.password_verify
        ]
        print("parameters: ", parameters)
        
        guard let url = URL(string: "https://text-message-api.herokuapp.com/auth_api/accounts/register/")
//        guard let url = URL(string: "http://127.0.0.1:8000/auth_api/accounts/register/")
            else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 201 {
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Invalid registration, try again."
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                    return
                }
            }
            
            if let data = data {
                do {
                    let json_data = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print("\njson data after posting: \n", json_data)
                    
                    let token_response = json_data["token_response"] as! [String: Any]
                    self.userDetails.accessToken = token_response["access"] as? String ?? ""
                    self.userDetails.refreshToken = token_response["refresh"] as? String ?? ""
                    
                    let accessExpiresString = token_response["access_expires"] as? String ?? ""
                    let refreshExpiresString = token_response["refresh_expires"] as? String ?? ""
                    print("time strings:")
                    print(accessExpiresString)
                    print(refreshExpiresString)
                    
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
                
                let messagingVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagingViewController") as? MessagingViewController
                
                if let messagingVC = messagingVC {
                    messagingVC.userDetails = self.userDetails
                    print("userDetails:", self.userDetails)
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
        nextTapped()
        return true
    }
    
    @objc func nextTapped() {
        
        if registerStatus == .username {
            // go to email screen
            self.userDetails.username = inputTextField.text!
            
            let emailRegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
            
            if let emailRegisterVC = emailRegisterVC {
                emailRegisterVC.registerStatus = .email
                emailRegisterVC.userDetails = self.userDetails
                print("username: ", self.userDetails.username)
                self.navigationController?.pushViewController(emailRegisterVC, animated: true)
            }
            
        } else if registerStatus == .email {
            
            // test for valid email - if not valid, show error message
            if !isValidEmail(testString: inputTextField.text!) {
                errorLabel.text = "Invalid email, try again."
                return
            }
            
            // go to password screen
            self.userDetails.email = inputTextField.text!
            
            let passwordRegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
            
            if let passwordRegisterVC = passwordRegisterVC {
                passwordRegisterVC.registerStatus = .password
                passwordRegisterVC.userDetails = self.userDetails
                print("email: ", self.userDetails.email)
                self.navigationController?.pushViewController(passwordRegisterVC, animated: true)
            }
            
        } else if registerStatus == .password {
            // go to password verify screen
            self.userDetails.password = inputTextField.text!
            
            let verify_passwordRegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
            
            if let verify_passwordRegisterVC = verify_passwordRegisterVC {
                verify_passwordRegisterVC.registerStatus = .verify_password
                verify_passwordRegisterVC.userDetails = self.userDetails
                print("password: ", self.userDetails.password)
                self.navigationController?.pushViewController(verify_passwordRegisterVC, animated: true)
            }
            
        } else {
            // attempt to register new user with server
            self.userDetails.password_verify = inputTextField.text!
            print("verify_password: ", self.userDetails.password_verify)
            self.registerUser()            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.delegate = self
        self.inputTextField.returnKeyType = .next
        self.inputTextField.enablesReturnKeyAutomatically = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        switch registerStatus {
        case .username:         inputLabel.text = "username"
        case .email:            inputLabel.text = "email"
        case .password:         inputLabel.text = "password"
                                inputTextField.isSecureTextEntry = true
        case .verify_password:  inputLabel.text = "verify password"
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
