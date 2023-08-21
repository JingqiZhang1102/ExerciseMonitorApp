//
//  RecentViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-06.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class RecentViewController: UIViewController {
    
    @IBOutlet weak var RecentLineChart: LineChartView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    let URL_USER_CHECK_RECENT = "http://192.168.0.149/checkrecent.php"
    
    let defaultValues = UserDefaults.standard
    
    var cur_userid: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(cur_userid)
        var unwrapped_id = ""
        if let unwrapped = cur_userid {
             TitleLabel.text = unwrapped+"'s Recent Records"
            unwrapped_id = unwrapped
        } else {
            print("Missing name")
        }
        
        //making a post request
        AF.request(URL_USER_CHECK_RECENT, method: .post, parameters: ["id":unwrapped_id]).responseJSON
            {
                response in
                //printing response
                print(response)
                
                switch response.result {
                case let .success(value):
                    //print(value)
                    //let recent_results = value["recent_results"]
                    let json = JSON(value)
                    let recent_results = json["recent_results"]
                    let record_num = recent_results.count
                    print(recent_results)
                    
                    let sorted_recent_results = recent_results.sorted(by:<)
                    
                    print(sorted_recent_results)
                    
                    var xvalues = Array<String>()
                    var yvalues = Array<Int>()
                    
                    //var new_recent_results = Array<Any>()
                    
                    // put dates into x values; steps into y values
                    for (one_date, one_step) in sorted_recent_results{
                        xvalues.append(one_date)
                        yvalues.append(one_step.int!)
                        
                        /*let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-mm-dd"
                        let date = dateFormatter.date(from:one_date)*/
                    }
                    // date array
                    //print(xvalues)
                    // step count array
                    //print(yvalues)
                    
                    // line chart data entry
                    var record_daily : [ChartDataEntry] = []
                    
                    for i in 0 ..< record_num {
                        record_daily.append(ChartDataEntry(x: Double(i), y: Double(yvalues[i])))
                    }
                    
                    print(record_daily)
                    
                    let linechartdata = LineChartData()
                    let linechartdataset = LineChartDataSet(entries: record_daily, label: "Dates")
                    
                    linechartdata.addDataSet(linechartdataset)
                    self.RecentLineChart.data = linechartdata
                    self.RecentLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xvalues)
                    self.RecentLineChart.xAxis.granularity = 1
                    
                    // to avoid overlap
                    self.RecentLineChart.xAxis.labelRotationAngle = -15
                    self.RecentLineChart.extraTopOffset = 15
                    
                    
                    
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
