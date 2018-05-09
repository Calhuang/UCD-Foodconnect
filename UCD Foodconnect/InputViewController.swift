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
import FirebaseStorage

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var downloadImage = "none"
    @IBOutlet weak var inputText: UITextView!
    @IBAction func photoSelct(_ sender: Any) {
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
    }
    @IBOutlet weak var imageView: UIImageView!
    
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

        imageView.image = image
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true

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
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidCancel (_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
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
                "timestamp": getDate(),
                "photo_url": downloadImage,
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
