//
//  ViewController.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 4/7/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import UIKit

class MessagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var userDetails: UserModel!
    var messagesData: [MessageBundle] = [MessageBundle()]
    var eventSource: EventSource?
    var keyboardHeight: CGFloat = 0
    let queryServer = QueryServer()
    let composeViewCollaspedHeight: CGFloat = 50
    
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet var messageComposeView: UIView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomMessageCell!
        
        if self.messagesData[indexPath.row].email == self.userDetails.email {
            cell = tableView.dequeueReusableCell(withIdentifier: "RightMessageCell", for: indexPath) as? CustomMessageCell
            cell.messageBackground.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell.messageBody.textColor = UIColor.white
            cell.messageBody.text = messagesData[indexPath.row].message
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "LeftMessageCell", for: indexPath) as? CustomMessageCell
            cell.messageBackground.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            cell.emailLabel.text = messagesData[indexPath.row].email
            cell.messageBody.text = messagesData[indexPath.row].message
        }

        return cell
    }
    
    func scrollToLastRow() {
        if self.messagesData.count > 0 {
            let indexPath = IndexPath(row: messagesData.count - 1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    // Height of keyboard in iPhone X+ is a little tricky b/c keyboard height starts above safe area
    // Adjust by subtracting view.safeAreaInsets.bottom
    @objc func adjustForKeyboard(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let bottomInset = self.view.safeAreaInsets.bottom
            self.keyboardHeight = keyboardRectangle.height - bottomInset

            
            UIView.animate(withDuration: 0.4) {
                self.heightConstraint.constant = CGFloat(self.composeViewCollaspedHeight + self.keyboardHeight)
                self.view.layoutIfNeeded()
            }
        }
        self.scrollToLastRow()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = textField.text! as NSString // text existing in textField already
        let resultText = currentText.replacingCharacters(in: range, with: string) as NSString // resulting text after user changes
        if String(resultText) == "" {
            self.sendButton.isEnabled = false
        } else {
            self.sendButton.isEnabled = true
        }
        
        return true // always allow user input
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendPressed()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = CGFloat(self.composeViewCollaspedHeight)
            self.view.layoutIfNeeded()
        }
    }
    
    func getMessages() {
        // see QueryServer.swift for networking details
        queryServer.getMessages { (results, errorMessage) in
            if let results = results {
                self.messagesData = results
                self.messageTableView.reloadData()
                self.scrollToLastRow()
            }
            if !errorMessage.isEmpty { print("Networking error: " + errorMessage) }
        }
    }
    
    @IBAction
    func sendPressed() {
        
//        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let currentText = self.messageTextField.text!
        let auth_parameters = ["email": self.userDetails.email, "message": currentText]
//        let parameters = ["user": "1", "email": "ryu71@mail.ccsf.edu", "message": currentText]

        guard let url = URL(string: "https://text-message-api.herokuapp.com/auth_api/messageapp/create/")
//        guard let url = URL(string: "http://127.0.0.1:8000/auth_api/messageapp/create/")

            else {
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + self.userDetails.accessToken, forHTTPHeaderField: "Authorization")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: auth_parameters, options: [])
            else {
                return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("\nhttp response: \n", response)
            }
            
            if let data = data {
                do {
                    let json_data = try JSONSerialization.jsonObject(with: data, options: [])
                    print("\njson data after posting: \n", json_data)
                } catch {
                    self.messageTextField.isEnabled = true
                    print(error)
                }
            }
            
            DispatchQueue.main.async {
//                self.messageTextField.isEnabled = true
                self.messageTextField.text = ""
            }
        }
        session.resume()
    }
    
    @objc func viewPinched(_ pinchRecognizer: UIPinchGestureRecognizer) {
        
        if pinchRecognizer.state == .began || pinchRecognizer.state == .changed {
            pinchRecognizer.view?.transform = CGAffineTransform(scaleX: pinchRecognizer.scale, y: pinchRecognizer.scale)
            if pinchRecognizer.scale < 0.15 {
                logoutPressed()
            }
        }
        
        if pinchRecognizer.state == .ended {
            print("pinchRecognizer state ended")
            UIView.animate(withDuration: 0.5) {
                pinchRecognizer.view?.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc func logoutPressed() {
        self.userDetails.clean()
        deleteDoc()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        self.logoutPressed()
    }
    
    // MARK: viewDidLoad() setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // Setup pinch recognizer
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(viewPinched))
        pinchRecognizer.delegate = self
        self.view.addGestureRecognizer(pinchRecognizer)
        
        // Setup tapGesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        // TableView setup
        self.messageTableView.dataSource = self
        self.messageTableView.delegate = self
        self.messageTableView.separatorStyle = .none
        self.messageTableView.allowsSelection = false
        messageTableView.register(UINib(nibName: "LeftMessageCell", bundle: nil), forCellReuseIdentifier: "LeftMessageCell")
        messageTableView.register(UINib(nibName: "RightMessageCell", bundle: nil), forCellReuseIdentifier: "RightMessageCell")
        
        // Message TextField Area Setup
        self.messageTextField.delegate = self
        self.messageTextField.returnKeyType = .send
        self.messageTextField.enablesReturnKeyAutomatically = true
        let purple = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.sendButton.setTitleColor(purple, for: .normal)
        self.sendButton.isEnabled = false
        
        // Setup keyboard adjustments
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Save user login details to local file
        save(userDetails: self.userDetails)
        
        // Setup networking and download initial messages
        self.getMessages()
        
        self.eventSource = EventSource(url: "https://text-message-api.herokuapp.com/events/", headers: [:])
//        self.eventSource = EventSource(url: "http://127.0.0.1:8000/events/", headers: [:])

        self.eventSource?.onOpen {
            print("eS onOpen")
        }

        self.eventSource?.addEventListener("message", handler: { (id, event, data) in
            // print("id: ", id!)
            print("\nevent: ", event!)
            print("data: ", data!)
            
            DispatchQueue.main.async {
                self.getMessages()
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
