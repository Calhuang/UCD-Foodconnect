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
import MapKit
import CoreLocation

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var downloadImage = "none"
    let locationManager = CLLocationManager()
    let datePicker = UIDatePicker()
    let datePickerTwo = UIDatePicker()
    var user_long = 0.0
    var user_lat = 0.0
   
    @IBOutlet weak var infoText: UITextField!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var timeTwoText: UITextField!
    @IBOutlet weak var timeThreeText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    
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
                    print(url)
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
            let combinedText = "\(titleText.text ?? "") \n\(locationText.text ?? "") \n\(timeText.text ?? "") \n\(timeTwoText.text ?? "") - \(timeThreeText.text ?? "") \n"
            print(user?.providerID ?? "nothing found")
            db.collection("users").whereField("user_id", isEqualTo: user?.uid ?? "none").getDocuments {(snapshot,error) in
                if error != nil {
                    print(error!)
                } else {
                    for document in (snapshot?.documents)! {
                        
                        if let pic_id = document.data()["photo_url"] as? String {
                            ref = db.collection("messages").addDocument(data: [
                                "name": user?.displayName ?? "no_name",
                                "text": combinedText,
                                "user_id": user?.uid ?? "no_id",
                                "timestamp": self.getDate(),
                                "photo_url": self.downloadImage,
                                "prof_img": pic_id,
                                "description": self.infoText.text ?? "",
                                "lat": self.user_lat,
                                "long": self.user_long,
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    } else {
                                        print("Document added with ID: \(ref!.documentID)")
                                    }
                            }
                        }
                    }
                    
                }
                
            }
            

        } else {
            // No user is signed in.
            print("user not signed in!?")
        }

    }
    
    @IBAction func setCoordinates(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func createDatePicker() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        timeText.inputAccessoryView = toolbar
        timeText.inputView = datePicker
        
        // format picker for date
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: datePicker.date)
        
        timeText.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    func createDatePickerTwo() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedTwo))
        toolbar.setItems([done], animated: false)
        
        timeTwoText.inputAccessoryView = toolbar
        timeTwoText.inputView = datePickerTwo
        
        // format picker for date
        datePickerTwo.datePickerMode = .time
    }
    
    @objc func donePressedTwo() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: datePickerTwo.date)
        
        timeTwoText.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    func createDatePickerThree() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedThree))
        toolbar.setItems([done], animated: false)
        
        timeThreeText.inputAccessoryView = toolbar
        timeThreeText.inputView = datePickerTwo
        
        // format picker for date
        datePickerTwo.datePickerMode = .time
    }
    
    @objc func donePressedThree() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: datePickerTwo.date)
        
        timeThreeText.text = "\(dateString)"
        self.view.endEditing(true)
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
        infoText.borderStyle = .none
        infoText.layer.cornerRadius = 5
        infoText.clipsToBounds = true
        infoText.textAlignment = .left
        infoText.contentVerticalAlignment = .top
        // Do any additional setup after loading the view.
        createDatePicker()
        createDatePickerTwo()
        createDatePickerThree()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        user_lat = locValue.latitude
        user_long = locValue.longitude
        locationManager.stopUpdatingLocation()
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
