//
//  TableViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/3/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FruitTableViewCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userText: UILabel!
    
}

class TableViewController: UITableViewController {
    @IBOutlet var tableview: UITableView!
    @IBAction func submitPost(_ sender: Any) {
    
    }
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
    }
    var fruits = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
                  "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
                  "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
                  "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
                  "Pear", "Pineapple", "Raspberry", "Strawberry"]
    
    var msgArray =  [String]()
    var nameArray =  [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // get info from server
        
        
        //        db.collection("messages").whereField("name", isEqualTo: "Calvin").getDocuments {(snapshot,error) in
        //            if error != nil {
        //                print(error!)
        //            } else {
        //                for document in (snapshot?.documents)! {
        //                    if let text = document.data()["text"] as? String {
        //                        self.messageBox.text = text
        //                        print(text)
        //                    }
        //                }
        //            }
        //
        //        }
        
            getMessageArray()
//        print(msgArray)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("in NUMBERFO SECTION: \(self.msgArray.count)")
        return self.msgArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fruitCell", for: indexPath) as! FruitTableViewCell
        print(indexPath.row)

        print(msgArray[indexPath.row])
        cell.userText?.text = msgArray[indexPath.section]
        cell.userName?.text = nameArray[indexPath.section]
        return cell
    }
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
//    func getMessageCount() -> Int {
//        let db = Firestore.firestore()
//        var messageTemp = 0
//        db.collection("messages").whereField("name", isEqualTo: "Calvin").addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//
//            messageTemp = document.documents.count
//            print("Current count: \(messageTemp)")
//        }
//
//        return messageTemp
//    }
    
//    func getMessageCount() -> Int {
//        let db = Firestore.firestore()
//        var count = 0
//        // Configure the cell...
//        db.collection("messages").whereField("name", isEqualTo: "Calvin").getDocuments {(snapshot,error) in
//            if error != nil {
//                print(error!)
//            } else {
//                for document in (snapshot?.documents)! {
//                    count = document.data().count
//                    print(count)
//                }
//                self.rowCount = count
//            }
//
//        }
//        return count
//
//    }
    
    
    func getMessageArray() {
        let db = Firestore.firestore()
        var count = 0
        var array1 = [String]()
        var array2 = [String]()
        // Configure the cell...
        db.collection("messages").whereField("name", isEqualTo: "Calvin").getDocuments {(snapshot,error) in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    if let text = document.data()["text"] as? String {
                        array1.append(text)
                        print("added to messgae array")
                        count = count + 1
                        print(text)
                    }
                    if let userID = document.data()["user_id"] as? String {
                        array2.append(userID)
                        print(userID)
                    }
                }
                self.tableView.beginUpdates()
                print(self.msgArray)
                self.tableView.rowHeight = 250
                self.msgArray.append(contentsOf: array1)
                self.nameArray.append(contentsOf: array2)
                self.tableView.reloadData()
                //self.tableView.insertRows(at: [NSIndexPath(row: 10-1, section: 0) as IndexPath], with: .automatic)

                self.tableView.endUpdates()
                
                
            }
            
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
