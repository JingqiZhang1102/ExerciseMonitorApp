//
//  TimerViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-10.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import CoreMotion

class TimerViewController: UIViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    
    let stopColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
    // values for the pedometer data
    var numberOfSteps:Int! = nil
    var distance:Double! = nil
    
    var pedometer = CMPedometer()
    
    //timers code
    var timer = Timer()
    let timerInterval = 1.0
    var timeElapsed:TimeInterval = 0.0
    
    func startTimer(){
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval,target: self,selector: #selector(timerAction(timer:)) ,userInfo: nil,repeats: true)
    }
     
    func stopTimer(){
        timer.invalidate()
        displayPedometerData()
    }
     
    @objc func timerAction(timer:Timer){
        displayPedometerData()
    }
    
    func displayPedometerData(){
        //Time Elapsed
        timeElapsed += self.timerInterval
        statusTitle.text = "Timer: " + timeIntervalFormat(interval: timeElapsed)
        
        //Number of steps
        if let numberOfSteps = self.numberOfSteps{
            stepsLabel.text = String(format:"Steps: %i",numberOfSteps)
        } else {
            stepsLabel.text = "Steps: N/A"
        }
        
        //distance
        if let distance = self.distance{
            distanceLabel.text = String(format:"Distance: %02.02f meters", distance)
        } else {
            distanceLabel.text = "Distance: N/A"
        }
    }
    
    // convert seconds to hh:mm:ss as a string
    func timeIntervalFormat(interval:TimeInterval)-> String{
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }

    
    @IBAction func startStopButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start" {
            pedometer = CMPedometer()
            startTimer() // start the timer
            pedometer.startUpdates(from: Date(), withHandler: {
                (pedometerData, error) in
                if let pedData = pedometerData{
                    self.numberOfSteps = Int(pedData.numberOfSteps)
                    if let distance = pedData.distance {
                        self.distance = Double(distance)
                        //self.distanceLabel.text = "Distance:\(String(describing: self.distance))"
                    }
                    //self.stepsLabel.text = "Steps:\(self.numberOfSteps)"
                } else {
                    //self.stepsLabel.text = "Steps: Not Available"
                    print("not available")
                }
            })
            
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = stopColor
        }
        else {
            pedometer.stopUpdates()
            stopTimer() //stop the timer
            
            sender.backgroundColor = startColor
            sender.setTitle("Start", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
