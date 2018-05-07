//
//  FeedViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/6/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuthUI

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var feedView: UICollectionView!
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
        textArray.removeAll()
        nameArray.removeAll()
        print("refreshed feed")
        fetchData()
    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("auth logout error")
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    var textArray = [String]()
    var nameArray = [String]()
    
    func fetchData() {
        let db = Firestore.firestore()
        // Configure the cell...
        db.collection("messages").order(by: "timestamp", descending: true).getDocuments {(snapshot,error) in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    if let text = document.data()["text"] as? String {
                        self.textArray.append(text)
                    }
                    if let userID = document.data()["name"] as? String {
                        self.nameArray.append(userID)
                    }
                }
                
                print(self.textArray)

                self.feedView.reloadData()
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.textArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedCollectionViewCell
        
        // create cell
        cell.userText.text = self.textArray[indexPath.row]
        cell.userName.text = self.nameArray[indexPath.row]
        return cell
    }
    
}
