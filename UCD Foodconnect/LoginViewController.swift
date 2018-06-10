//
//  LoginViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/7/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class LoginViewController: UIViewController, FUIAuthDelegate, AuthUIDelegate {

    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    var backgroundImage : UIImageView!
    var customAuthPicker : FUIAuthPickerViewController!
    
    func authPickerViewController(forAuthUI: FUIAuth) -> FUIAuthPickerViewController {
        customAuthPicker = authPickerViewController(forAuthUI: authUI!)
        backgroundImage = UIImageView(image: UIImage.init(named: "icescream"))
        return customAuthPicker
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        self.present(nextViewController, animated:true, completion:nil)
        
        
        
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
            
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }

    }
    
    @IBAction func loginAction(sender: AnyObject) {
        // Present the default login view controller provided by authUI
        //let authViewController = authUI?.authViewController();
        let authViewController = LoginCustomViewController(authUI: authUI!)

        let navc = UINavigationController(rootViewController: authViewController)
        self.present(navc, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.auth = Auth.auth()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        self.authUI?.providers = [FUIGoogleAuth(),]
        
        
        self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
            
            guard user != nil else {
                self.loginAction(sender: self)
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.present(nextViewController, animated:true, completion:nil)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
