//
//  RootViewController.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 5/1/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
        
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        self.view.bringSubviewToFront(self.registerButton)
        self.view.bringSubviewToFront(self.loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        self.view.bringSubviewToFront(self.registerButton)
        self.view.bringSubviewToFront(self.loginButton)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
