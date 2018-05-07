//
//  InputViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/4/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuthUI

class InputViewController: UIViewController {
    
    @IBOutlet weak var inputText: UITextView!
    
    @IBAction func sendData(_ sender: Any) {
        print("sending data")
        
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        if Auth.auth().currentUser != nil {
            // User is signed in.
            let user = Auth.auth().currentUser
            print(user?.providerID ?? "nothing found")
            
            ref = db.collection("messages").addDocument(data: [
                "name": user?.displayName ?? "no_name",
                "text": inputText.text ?? "message error",
                "user_id": user?.uid ?? "no_id",
                "timestamp": getDate()
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        } else {
            // No user is signed in.
            print("user not signed in!?")
        }

    }
    
    
    func getDate() -> String{

//        let year = Calendar.current.component(.year, from: Date())
//        let month = Calendar.current.component(.month, from: Date())
//        let day = Calendar.current.component(.day, from: Date())
//        let hour = Calendar.current.component(.hour, from: Date())
//        let minute = Calendar.current.component(.minute, from: Date())
//        let second = Calendar.current.component(.second, from: Date())
//
//        // now the components are available
//        let fullDate = "\(year)-\(month)-\(day)-\(hour)-\(minute)-\(second)"
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.string(from: date)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
