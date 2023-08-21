//
//  RankViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-11.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// An attributed string extension to achieve colors on text.
extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

class RankViewController: UIViewController {
    
    @IBOutlet weak var RankLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    
    let URL_USER_RANK = "http://192.168.0.149/ranking.php"
    let defaultValues = UserDefaults.standard
    
    var cur_userid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(cur_userid)
        
        var unwrapped_id = ""
        
        if let unwrapped = cur_userid {
             TitleLabel.text = unwrapped+"'s Friends :D"
            unwrapped_id = unwrapped
        } else {
            print("Missing name")
        }
        //making a post request
        AF.request(URL_USER_RANK, method: .post, parameters: ["id":unwrapped_id]).responseJSON
            {
                response in
                //print(response)
                
                switch response.result {
                case let .success(value):
                    let json = JSON(value)
                    let id_step = json["id_step"]
                    //print(id_step)
                        
                    var str_str_id_step = [String:String]()
                    for (key,value) in id_step{
                        str_str_id_step[key] = String(value.description)
                    }
                    //print(str_str_id_step)
                    
                    var str_int_id_step = [String:Int]()
                    for (key, value) in str_str_id_step {
                        str_int_id_step[key] = Int(value)
                    }
                    print(str_int_id_step)
                    
                    let sortedarray = str_int_id_step.sorted{$0.value > $1.value}
                    print(sortedarray)
                    
                    var rankmsg:String = ""
                    for (key, value) in sortedarray {
                        rankmsg = rankmsg + "\(key):  \(value)" + " steps \n\n"
                    }
                    self.RankLabel.lineBreakMode = .byWordWrapping
                    self.RankLabel.numberOfLines = 0
                    
                    // change the color of rank message
                    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: rankmsg)
                    attributedString.setColor(color: UIColor.purple, forText: unwrapped_id+":")
                    self.RankLabel.attributedText = attributedString
                    
                    
                    //self.RankLabel.text = rankmsg
                    
                    
                case let .failure(error):
                    print(error)
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
