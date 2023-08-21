//
//  SettingViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-13.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire

class SettingViewController: UIViewController {
    
    var cur_userid: String?
    
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var StepgoalTextField: UITextField!
    
    let URL_USER_SETTING = "http://192.168.0.149/usersetting.php"
    let defaultValues = UserDefaults.standard
    
    // OK button action function
    @IBAction func buttonCreate(sender: UIButton){
        print(cur_userid)
        var username = ""
        if let unwrapped = cur_userid {
            username = unwrapped
            print(username)
        } else {
            print("Missing name")
        }
        
        // get the user id and new step goal
        let parameters: Parameters=[
            "id": username,
            "newgoal":StepgoalTextField.text!
        ]
        
        //making a post request
        //usersignup.php: create a new tuple in user table; create a new tuple in user_points table (default point and level: 0)
        AF.request(URL_USER_SETTING, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                
                let result = response.value
                let jsonData = result as! NSDictionary
                
                // check if sql is executed successfully
                if(!(jsonData.value(forKey: "error") as! Bool)) {
                    switch response.result {
                    case let .success(value):
                        //switching the screen
                        self.performSegue(withIdentifier: "SetVCToRecordVC", sender: self)
                    case let .failure(error):
                        print(error)
                    }
                } else {
                    print("failed")
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let unwrapped = cur_userid {
            UsernameLabel.text = "Current User: " + unwrapped
        } else {
            print("Missing name")
        }
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "SetVCToRecordVC") {
            let recordVC = segue.destination as! ProfileViewController
            recordVC.cur_userid = cur_userid
        }
    }
    

}
