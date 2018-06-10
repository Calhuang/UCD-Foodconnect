//
//  ModalViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/24/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    @IBOutlet weak var modalDesc: UILabel!
    var passedText = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN MODAL")
        print(passedText)
        modalDesc.text = passedText
        modalDesc.sizeToFit()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true) {
            print("go back to main feed")
        }
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
