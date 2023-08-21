//
//  ProfileViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-05.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var StepLabel: UILabel!
    @IBOutlet weak var DistLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    
    var cur_userid: String?
    
    var days:[String] = []
    var stepsTaken:[Int] = []

    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer();
    
    static var stepnum = "0"
    static var distance = "0"
    
    static var friendid = ""
    
    // url of the php page
    let URL_WRITE_STEPS = "http://192.168.0.149/writesteps.php"
    let defaultValues = UserDefaults.standard
    
    let URL_ADD_FRIEND = "http://192.168.0.149/addfriend.php"
    
    let URL_CHECK_LEVEL = "http://192.168.0.149/checklevel.php"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(cur_userid)
        if let unwrapped = cur_userid {
             TitleLabel.text = unwrapped+"'s Daily Record"
        } else {
            print("Missing name")
        }
       
        
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = TimeZone.current
        cal.timeZone = timeZone
        
        //print("hi")

        let midnightOfToday = cal.date(from: comps)!
        
        #if arch(i386) || arch(x86_64) && os(iOS)

            // Simulator

        #else

            // Run only in Physical Device, iOS
        if(CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable()){
                //print("available")
                pedoMeter.startUpdates(from: midnightOfToday) { (data: CMPedometerData?, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if(error == nil){
                            ProfileViewController.stepnum = "\(data!.numberOfSteps)"
                            ProfileViewController.distance = "\(data!.distance as! Double)"
                            
                            let doubledist = String(format: "%.2f", data!.distance as! Double)
                           
                            // try to write data into mysql when the screen is loaded
                            let parameters: Parameters=[
                                "stepcount":data!.numberOfSteps,
                                "distance":data!.distance as! Double
                            ]
                            
                            //making a post request
                            AF.request(self.URL_WRITE_STEPS, method: .post, parameters: ["stepcount":data!.numberOfSteps,
                                "distance":data!.distance as! Double]).responseJSON
                                {
                                    response in
                                    //print(response)
                                    
                                    switch response.result {
                                    case let .success(value):
                                        print(value)
                                        //print("profile success")
                                    case let .failure(error):
                                        print(error)
                                    }
                            }
                            // success: write into mysql
                            
                            // revise the label message
                            self.StepLabel.text = "Step:" + ProfileViewController.stepnum
                            self.DistLabel.text = "Distance:" + doubledist + " m"
                        }
                    })
                }
            }
        
        #endif
    }
    
    // function: add friends (add a pair into MySQL friend table)
    @IBAction func addFriend(sender: UIButton) {
        //switching the screen
        /*let FriendViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        self.navigationController?.pushViewController(FriendViewController, animated: true)
        self.dismiss(animated: false, completion: nil)*/
        self.performSegue(withIdentifier: "RecordVCToAddVC", sender: self)
    }
    
    // function: check recent records; go to Recent view controller
    @IBAction func checkRecent(sender: UIButton) {
        //switching the screen
        /*let RecentViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecentViewController") as! RecentViewController
        self.navigationController?.pushViewController(RecentViewController, animated: true)
        self.dismiss(animated: false, completion: nil)*/
        self.performSegue(withIdentifier: "RecordVCToRecentVC", sender: self)
    }
    
    // function: timer mode; go to Timer view controller
    @IBAction func getTimer(sender: UIButton) {
        //switching the screen
        let TimerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
        self.navigationController?.pushViewController(TimerViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    // function: check ranking; go to Rank view controller
    @IBAction func checkRank(sender: UIButton) {
        //switching the screen
        /*let RankViewController = self.storyboard?.instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        self.navigationController?.pushViewController(RankViewController, animated: true)
        self.dismiss(animated: false, completion: nil)*/
        self.performSegue(withIdentifier: "RecordVCToRankVC", sender: self)
    }
    
    // function: go to Setting
    @IBAction func goSetting(sender: UIButton) {
        //switching the screen
        /*let SettingViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(SettingViewController, animated: true)
        self.dismiss(animated: false, completion: nil)*/
        self.performSegue(withIdentifier: "RecordVCToSetVC", sender: self)
    }
    
    @IBAction func showLevel(sender: UIButton) {
        var id = ""
        if let unwrapped = cur_userid {
            id = unwrapped
        } else {
            print("Missing name")
        }
        //making a post request
        AF.request(self.URL_CHECK_LEVEL, method: .post, parameters: ["id": id]).responseJSON
            {
                response in
                //print(response)
                
                switch response.result {
                case let .success(value):
                    print(value)
                    let json = JSON(value)
                    let level = json["level"]
                    // display on the alert window
                    let alertController = UIAlertController(title: "Congratulations!", message: "Your current level is Level:" + "\(level)", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                case let .failure(error):
                    print(error)
                }
        }
        
        /*let alertController = UIAlertController(title: "Congratulations!", message: "Hello", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)*/
    }
    
    // function: go to Calendar
    @IBAction func goCalendar(sender: UIButton) {
        self.performSegue(withIdentifier: "RecordVCToCalendarVC", sender: self)
    }
    
    // function: go to History
    @IBAction func goHistory(sender: UIButton) {
        self.performSegue(withIdentifier: "RecordVCToHistoryVC", sender: self)
    }
    
    
    // already deleted, leave the codes for a record :)
    @IBAction func showSteps(sender: UIButton) {
        let alertController = UIAlertController(title: "Check your steps", message: "Today Steps:" + ProfileViewController.stepnum, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        let parameters: Parameters=[
            "stepcount":ProfileViewController.stepnum
        ]
        
        //making a post request
        AF.request(URL_WRITE_STEPS, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                switch response.result {
                case let .success(value):
                    print(value)
                case let .failure(error):
                    print(error)
                }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "RecordVCToRecentVC") {
            let recentVC = segue.destination as! RecentViewController
            recentVC.cur_userid = cur_userid
        }
        if(segue.identifier == "RecordVCToRankVC") {
            let rankVC = segue.destination as! RankViewController
            rankVC.cur_userid = cur_userid
        }
        if(segue.identifier == "RecordVCToAddVC") {
            let addVC = segue.destination as! FriendViewController
            addVC.cur_userid = cur_userid
        }
        if(segue.identifier == "RecordVCToSetVC") {
            let setVC = segue.destination as! SettingViewController
            setVC.cur_userid = cur_userid
        }
        if(segue.identifier == "RecordVCToCalendarVC") {
            let calVC = segue.destination as! CalendarViewController
            calVC.cur_userid = cur_userid
        }
        if(segue.identifier == "RecordVCToHistoryVC") {
            let hisVC = segue.destination as! HistoryViewController
            hisVC.cur_userid = cur_userid
        }
    }
    

}
