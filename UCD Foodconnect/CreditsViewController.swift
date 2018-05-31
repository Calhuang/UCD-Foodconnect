//
//  CreditsViewController.swift
//  UCD Foodconnect
//
//  Created by Calvin on 5/25/18.
//  Copyright © 2018 Calvin Huang. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @IBOutlet weak var textBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBox.layer.cornerRadius = 5
        textBox.clipsToBounds = true
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
