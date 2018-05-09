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
import SDWebImage

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
    var picArray = [String]()
    var count = 0
    
    func fetchData() {
        let db = Firestore.firestore()
        self.textArray = [String]()
        self.nameArray = [String]()
        self.picArray = [String]()
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
                    if let pic = document.data()["photo_url"] as? String {
                        self.picArray.append(pic)
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
                let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCellImage", for: indexPath) as! FeedCollectionViewCell
        count = count + 1
        print(count)
        // create cell
        cell.userText.text = self.textArray[indexPath.row]
        cell.userName.text = self.nameArray[indexPath.row]
        if (self.picArray[indexPath.row] != "none") {
            cell2.userText.text = self.textArray[indexPath.row]
            cell2.userName.text = self.nameArray[indexPath.row]
            cell2.imagePost.sd_setImage(with: URL(string: self.picArray[indexPath.row]), placeholderImage: UIImage(named: "embarassed_emoji.png"))
            return cell2
        }
        print("picaray")
        print(self.picArray)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (self.picArray[indexPath.row] != "none") {
            return CGSize(width: self.view.frame.size.width, height: 501.0)
        }
        return CGSize(width: self.view.frame.size.width, height: 256.0)
    }
    
}
