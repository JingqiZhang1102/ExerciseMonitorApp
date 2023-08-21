//
//  SignupViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-05.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire

class SignupViewController: UIViewController {
    
    let URL_USER_SIGNUP = "http://192.168.0.149/usersignup.php"
    
    let defaultValues = UserDefaults.standard
    
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var WarnLabel: UILabel!
    
    // create button action function
    @IBAction func buttonCreate(sender: UIButton){
        // get the username and password
        let parameters: Parameters=[
            "username":UsernameTextField.text!,
            "password":PasswordTextField.text!
        ]
        //print("hi")
        
        //making a post request
        //usersignup.php: create a new tuple in user table; create a new tuple in user_points table (default point and level: 0)
        AF.request(URL_USER_SIGNUP, method: .post, parameters: parameters).responseJSON
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
                        /*let ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                        self.navigationController?.pushViewController(ProfileViewController, animated: true)
                        
                        self.dismiss(animated: false, completion: nil)*/
                        self.performSegue(withIdentifier: "SignupVCToRecordVC", sender: self)
                        self.WarnLabel.text = " "
                    case let .failure(error):
                        print(error)
                    }
                } else {
                    //self.labelMessage.text = "INVALID username or password"
                    print("failed")
                    self.WarnLabel.text = "Username is already taken."
                }
                
                
                
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if(segue.identifier == "SignupVCToRecordVC") {
            let recordVC = segue.destination as! ProfileViewController
            recordVC.cur_userid = UsernameTextField.text
        }
    }
    

}
