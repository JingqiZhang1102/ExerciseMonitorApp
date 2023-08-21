//
//  ViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-05.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    
    let URL_USER_LOGIN = "http://192.168.0.149/userlogin.php"
    
    let defaultValues = UserDefaults.standard
    
    
    @IBOutlet weak var UsernameTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    // login button action function
    @IBAction func buttonLogin(sender: UIButton){
        // get the username and password
        let parameters: Parameters=[
            "username":UsernameTextField.text!,
            "password":PasswordTextField.text!
        ]
        print(parameters)
        
        //making a post request
        AF.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                let result = response.value
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)) {
                    switch response.result {
                    case let .success(value):
                        print("hi")
                        //switching the screen
                        /*let ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                        self.navigationController?.pushViewController(ProfileViewController, animated: true)
                        
                        self.dismiss(animated: false, completion: nil)*/
                        self.performSegue(withIdentifier: "LoginVCToRecordVC", sender: self)
                    case let .failure(error):
                        print(error)
                    }
                } else {
                    self.labelMessage.text = "INVALID username or password"
                }
        }
        
        //self.performSegue(withIdentifier: "LoginVCToRecordVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LoginVCToRecordVC") {
            let ProfileVC = segue.destination as! ProfileViewController
            ProfileVC.cur_userid = UsernameTextField.text
        }
    }
    
    // signup button action function (redirect to signup page)
    @IBAction func buttonSignup(sender: UIButton){
        // redirect to signup page
        let SignupViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(SignupViewController, animated: true)
        
        self.dismiss(animated: false, completion: nil)
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


}

