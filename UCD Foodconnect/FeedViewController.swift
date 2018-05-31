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
import MapKit
import CoreLocation

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

 
    @IBOutlet weak var profPic: UIButton!
    @IBOutlet weak var feedView: UICollectionView!
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
        textArray.removeAll()
        nameArray.removeAll()
        print("refreshed feed")
        fetchData()
    }
    @IBAction func refreshButton(_ sender: Any) {
        print("refreshed feed")
        fetchData()
    }
    @IBAction func showMaps(_ sender: Any) {
        let coordinate = CLLocationCoordinate2DMake(user_lat, user_long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = "Target location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    var textArray = [String]()
    var descArray = [String]()
    var nameArray = [String]()
    var picArray = [String]()
    var feedProfPic = [String]()
    var count = 0
    var pic = "none"
    var refreshControl:UIRefreshControl!
    var user_lat = 0.0
    var user_long = 0.0
    var currentDescription = ""

    
    func fetchData() {
        let db = Firestore.firestore()
        self.descArray = [String]()
        self.textArray = [String]()
        self.nameArray = [String]()
        self.picArray = [String]()
        self.feedProfPic = [String]()
        let user = Auth.auth().currentUser
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
                    if let profPic = document.data()["prof_img"] as? String {
                        self.feedProfPic.append(profPic)
                    }
                    if let desc = document.data()["description"] as? String {
                        self.descArray.append(desc)
                    }
                    if let lat = document.data()["lat"] as? Double {
                        self.user_lat = lat
                    }
                    if let long = document.data()["long"] as? Double {
                        self.user_long = long
                    }
                    
                }
                
                print(self.textArray)
                self.feedView.reloadData()
                
            }
        }
        
        db.collection("users").whereField("user_id", isEqualTo: user?.uid ?? "none").getDocuments {(snapshot,error) in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    
                    if let pic_id = document.data()["photo_url"] as? String {
                        self.pic = pic_id
                        print(self.pic)
                        let url = URL(string: self.pic)
                        if let data = try? Data(contentsOf: url!)
                        {
                            let image: UIImage = UIImage(data: data)!
                            self.profPic.setImage(image, for: .normal)
                        }
                    }
                }
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
        let url = URL(string: self.feedProfPic[indexPath.row])
//        if let data = try? Data(contentsOf: url!)
//        {
//            let image: UIImage = UIImage(data: data)!
//            cell.feedProfPic.image = image
//            cell2.feedProfPicTwo.image = image
//        }
        cell.feedProfPic.sd_setImage(with: URL(string: self.feedProfPic[indexPath.row]), placeholderImage: UIImage(named: "prof.png"))
            cell2.feedProfPicTwo.sd_setImage(with: URL(string: self.feedProfPic[indexPath.row]), placeholderImage: UIImage(named: "prof.png"))
        // create cell
        cell.userText.text = self.textArray[indexPath.row]
        cell.userName.text = self.nameArray[indexPath.row]
        cell.layer.borderColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1).cgColor
        cell.layer.borderWidth = 1

        if (self.picArray[indexPath.row] != "none") {
            cell2.userText.text = self.textArray[indexPath.row]
            cell2.userName.text = self.nameArray[indexPath.row]
            cell2.imagePost.sd_setImage(with: URL(string: self.picArray[indexPath.row]), placeholderImage: UIImage(named: "prof.png"))
            cell2.layer.borderColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1).cgColor
            cell2.layer.borderWidth = 1

            return cell2
        }
        print("picaray")
        print(self.picArray)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (self.picArray[indexPath.row] != "none") {
            return CGSize(width: self.view.frame.size.width-15, height: 180.0)
        }
        return CGSize(width: self.view.frame.size.width-15, height: 180.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentDescription = descArray[indexPath.row]
        self.performSegue(withIdentifier: "goToMoreInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToMoreInfo") {
            
            let nextVC = segue.destination as! ModalViewController;
            nextVC.passedText = currentDescription
            
        }
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        // get image from current user id
    }
    
    func getProf () {
        // look into database/users
        // get imange url from "user_pic"
        // load into imageview
        
    }
    @objc func refresh(sender:AnyObject)
    {
        self.fetchData()
    }
}
