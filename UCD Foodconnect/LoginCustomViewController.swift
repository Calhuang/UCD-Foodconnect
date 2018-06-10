//
//  LoginCustomViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/31/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class LoginCustomViewController: FUIAuthPickerViewController {
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "login")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFit
        
        view.insertSubview(imageViewBackground, at: 0)
    }
        
}
