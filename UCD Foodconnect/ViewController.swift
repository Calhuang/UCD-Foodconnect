//
//  ViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 4/30/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    @IBOutlet weak var messageBox: UILabel!
    @IBOutlet weak var textField: UITextField!


    @IBAction func startTyping(_ sender: Any) {
        self.textField.becomeFirstResponder()
    }
    @IBAction func stopTyping(_ sender: Any) {
        self.textField.resignFirstResponder()
    }
    @IBAction func sendMessage(_ sender: UIButton) {
        // send msg
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("messages").addDocument(data: [
            "name": "Calvin",
            "text": textField.text ?? "message error",
            "user_id": "calhuang"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // remove text
        
        // close keyboard
        self.textField.resignFirstResponder()
    }
    @IBAction func refreshMessages(_ sender: UIButton) {
            let db = Firestore.firestore()
        db.collection("messages").whereField("name", isEqualTo: "Calvin").getDocuments {(snapshot,error) in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    if let text = document.data()["text"] as? String {
                        self.messageBox.text = text
                        print(text)
                    }
                }
            }
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    

}

