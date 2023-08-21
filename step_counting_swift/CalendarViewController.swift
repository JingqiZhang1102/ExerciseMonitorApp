//
//  CalendarViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-17.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire
import SwiftyJSON

class CalendarViewController: UIViewController, FSCalendarDelegate {
    
    var cur_userid: String?
    var calendar = FSCalendar()
    
    let URL_USER_CALENDAR = "http://192.168.0.149/checkcalendar.php"
    let defaultValues = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(cur_userid)
        calendar.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: view.frame.size.width)
        view.addSubview(calendar)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let datestring = formatter.string(from: date)
        //print("\(string)")
        
        // set parameter: id and date
        var username = ""
        if let unwrapped = cur_userid {
            username = unwrapped
            print(username)
        } else {
            print("Missing name")
        }
        let parameters: Parameters=[
            "id": username,
            "check_date": datestring
        ]
        
        print(parameters)
        
        //making a post request
        AF.request(URL_USER_CALENDAR, method: .post, parameters: parameters).responseJSON
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
                        //self.performSegue(withIdentifier: "SetVCToRecordVC", sender: self)
                        let json = JSON(value)
                        let date_step = json["date_step"]
                        print(date_step)
                        var stepstring = ""
                        stepstring = "Step: " + String(date_step.description)
                        if (stepstring == "Step: 0") {
                            stepstring = "No Record for Today."
                        }
                        let alertController = UIAlertController(title: "Date: " + datestring, message: stepstring, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        //print("success!")
                    case let .failure(error):
                        print(error)
                    }
                } else {
                    print("failed")
                }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
