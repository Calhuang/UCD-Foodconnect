//
//  UserInfoViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/9/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var downloadImage = "none"
    @IBOutlet weak var profButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var pic = "none"
    var name = "none"
    
    @IBAction func unwindToUserViewController(segue: UIStoryboardSegue) {
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
    
    func fetchData() {
        let db = Firestore.firestore()
        self.pic = "none"
        self.name = "none"
        let user = Auth.auth().currentUser
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
                            self.profButton.setImage(image, for: .normal)
                        }
                    }
                    if let name = document.data()["name"] as? String {
                        self.name = name
                    }
                }
                
                print("FETCHE STADA:")
                print(self.pic)
                print(self.name)
                self.nameLabel.text = self.name
            }
            
        }
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
    
    
    @IBAction func changePic(_ sender: Any) {
        let actionsheet = UIAlertController(title: "Photo Source", message: "Choose an image", preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("Camera not available!")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet, animated: true, completion: nil)
        // get id of current signed in
        // create user in database / modify pic url
        // update prof pic
        
    }
    @IBAction func changeName(_ sender: Any) {
        // get id of current signed in
        // create user in database / modify pic url
        // update name
    }
    
    func getDate() -> String{
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.string(from: date)
    }

    // PHOTO STUFF

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName = imageUrl.lastPathComponent
        var fileType = ""
        if let range = imageName?.range(of: ".") {
            let randName = imageName![range.upperBound...]
            fileType = String(randName).lowercased()
        }
        let storage = Storage.storage().reference()
        let imagesRef = storage.child("images/\(randomAlphaNumericString(length: 8)).\(fileType)")
        let image = info[UIImagePickerControllerOriginalImage]as! UIImage
        //obtaining saving path
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent("\(randomAlphaNumericString(length: 8)).\(fileType)")
        
        // extract image from the picker and save it
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            try! UIImageJPEGRepresentation(pickedImage, 0.0)?.write(to: imagePath!)
        }
        
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = imagesRef.putFile(from: imagePath!, metadata: nil) { metadata, error in
            // You can also access to download URL after upload.
            storage.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            self.downloadImage = snapshot.metadata?.downloadURL()?.absoluteString ?? "none"
            print("PIC HAS BEEN UPLOADED: \(self.downloadImage)")
            
            print("sending user info")
            print("URL: \(self.downloadImage)")
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            if Auth.auth().currentUser != nil {
                // User is signed in.
                let user = Auth.auth().currentUser
                print(user?.providerID ?? "nothing found")
                
                db.collection("users").document(user?.uid ?? "no_id").setData([
                    "name": user?.displayName ?? "no_name",
                    //                "text": inputText.text ?? "message error",
                    "user_id": user?.uid ?? "no_id",
                    "last_modified": self.getDate(),
                    "photo_url": self.downloadImage,
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            } else {
                // No user is signed in.
                print("user not signed in!?")
            }
            
            
            
            self.fetchData()

        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidCancel (_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // random string gen
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }


}
