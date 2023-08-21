//
//  FriendViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-11.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire

class FriendViewController: UIViewController {
    
    let URL_USER_ADD = "http://192.168.0.149/addfriend.php"
    let defaultValues = UserDefaults.standard
    
    @IBOutlet weak var FriendID: UITextField!
    
    var cur_userid: String?
    
    // add friend button action function
    @IBAction func buttonAdd(sender: UIButton){
        let parameters: Parameters=[
            "fid": String(FriendID.text!)
        ]
        //print(parameters)
        
        //making a post request
        /*AF.request(URL_USER_ADD, method: .post, parameters: parameters, headers: nil ).responseString
            {
                response in
                print(response)
                
                switch response.result {
                case .success( _):
                    //switching the screen
                    let ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    self.navigationController?.pushViewController(ProfileViewController, animated: true)
                    
                    self.dismiss(animated: false, completion: nil)
                    print("hi")
                case let .failure(error):
                    print(error)
                }
        }*/
        
        print(cur_userid)
        
        AF.request(URL_USER_ADD, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                let result = response.value
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)) {
                    switch response.result {
                    case let .success(value):
                        //switching the screen
                        /*let ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                        self.navigationController?.pushViewController(ProfileViewController, animated: true)
                        self.dismiss(animated: false, completion: nil)*/
                        self.performSegue(withIdentifier: "AddVCToRecordVC", sender: self)

                    case let .failure(error):
                        print(error)
                    }
                } else {
                    print("error:true")
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
               let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismisskb")

               //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
               //tap.cancelsTouchesInView = false

               view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismisskb() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "AddVCToRecordVC") {
            let recordVC = segue.destination as! ProfileViewController
            recordVC.cur_userid = cur_userid
        }
    }
    

}
