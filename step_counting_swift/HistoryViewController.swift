//
//  HistoryViewController.swift
//  StepCounting
//
//  Created by Irena on 2020-08-18.
//  Copyright © 2020 Irena. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON
import Foundation

open class BalloonMarker: MarkerImage
{
    @objc open var color: UIColor
    @objc open var arrowSize = CGSize(width: 15, height: 11)
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.fillPath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }
        
        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(String(entry.y))
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}

public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: IAxisValueFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: IAxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let string = "x: "
            + xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
            + ", y: "
            + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
        setLabel(string)
    }
    
}


class HistoryViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var TitleLabel: UILabel!
    
    var cur_userid: String?
    
    let URL_USER_CHECK_WEEK = "http://192.168.0.149/checkweek.php"
    
    let URL_USER_CHECK_MONTH = "http://192.168.0.149/checkweek.php"
    let URL_USER_CHECK_YEAR = "http://192.168.0.149/checkyear.php"
    
    let defaultValues = UserDefaults.standard
    
    @IBAction func showWeek(sender: UIButton) {
        print(cur_userid)
        var unwrapped_id = ""
        if let unwrapped = cur_userid {
            unwrapped_id = unwrapped
        } else {
            print("Missing name")
        }
        
        self.TitleLabel.text = "Daily Step Counts"
        
        self.barChartView.clear()
        self.barChartView.notifyDataSetChanged()
        
        //making a post request
        AF.request(URL_USER_CHECK_WEEK, method: .post, parameters: ["id":unwrapped_id]).responseJSON
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
                    //print(recent_results)
                    
                    let stepgoal = json["stepgoal"]
                    //print(stepgoal)
                    
                    let sorted_recent_results = recent_results.sorted(by:<)
                    
                    //print(sorted_recent_results)
                    
                    var xvalues = Array<String>()
                    var yvalues = Array<Int>()
                    
                    //var new_recent_results = Array<Any>()
                    
                    // put dates into x values; steps into y values
                    for (one_date, one_step) in sorted_recent_results{
                        xvalues.append(one_date)
                        yvalues.append(one_step.int!)
                    }
                    
                    //print(xvalues) // date
                   // print(yvalues) // steps
                    
                    var dataEntries: [BarChartDataEntry] = []
                            
                    for i in 0 ..< record_num {
                        let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yvalues[i]))
                        dataEntries.append(dataEntry)
                    }
                    //print(dataEntries)
                
                    let chartData = BarChartData()
                    let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Daily Steps")
                    
                    chartDataSet.drawValuesEnabled = false
                    
                    chartData.addDataSet(chartDataSet)
                    self.barChartView.data = chartData
                    self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xvalues)
                    self.barChartView.xAxis.granularity = 1
                    self.barChartView.xAxis.labelRotationAngle = -15
                    self.barChartView.extraTopOffset = 15
                    self.barChartView.setVisibleXRangeMaximum(7)
                    self.barChartView.setVisibleXRangeMinimum(0)
                    
                    self.barChartView.barData?.barWidth = 0.5
                    
                    let goalline = ChartLimitLine(limit: stepgoal.double!, label: "Goal")
                    self.barChartView.rightAxis.addLimitLine(goalline)
                    
                    self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                    
                    self.barChartView.leftAxis.axisMinimum = 0
                    self.barChartView.rightAxis.axisMinimum = 0
                    
                    let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                              font: .systemFont(ofSize: 12),
                                              textColor: .white,
                                              insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                              xAxisValueFormatter: self.barChartView.xAxis.valueFormatter!)
                    marker.chartView = self.barChartView
                    marker.minimumSize = CGSize(width: 80, height: 40)
                    self.barChartView.marker = marker

                case let .failure(error):
                    print(error)
                }
        }
    }
    
    @IBAction func showMonth(sender: UIButton) {
        print(cur_userid)
        var unwrapped_id = ""
        if let unwrapped = cur_userid {
            unwrapped_id = unwrapped
        } else {
            print("Missing name")
        }
        
        self.barChartView.clear()
        self.barChartView.notifyDataSetChanged()
        
        self.TitleLabel.text = "Daily Step Counts"
        
        //making a post request
        AF.request(URL_USER_CHECK_MONTH, method: .post, parameters: ["id":unwrapped_id]).responseJSON
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
                    //print(recent_results)
                    
                    let stepgoal = json["stepgoal"]
                    //print(stepgoal)
                    
                    let sorted_recent_results = recent_results.sorted(by:<)
                    
                    //print(sorted_recent_results)
                    
                    var xvalues = Array<String>()
                    var yvalues = Array<Int>()
                    
                    //var new_recent_results = Array<Any>()
                    
                    // put dates into x values; steps into y values
                    for (one_date, one_step) in sorted_recent_results{
                        xvalues.append(one_date)
                        yvalues.append(one_step.int!)
                    }
                    
                    //print(xvalues) // date
                   // print(yvalues) // steps
                    
                    var dataEntries: [BarChartDataEntry] = []
                            
                    for i in 0 ..< record_num {
                        let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yvalues[i]))
                        dataEntries.append(dataEntry)
                    }
                    //print(dataEntries)
                
                    let chartData = BarChartData()
                    let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Daily Steps")
                    
                    chartDataSet.drawValuesEnabled = false
                    
                    chartData.addDataSet(chartDataSet)
                    self.barChartView.data = chartData
                    self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xvalues)
                    self.barChartView.xAxis.granularity = 1
                    self.barChartView.xAxis.labelRotationAngle = -15
                    
                    
                    self.barChartView.extraTopOffset = 15
                    
                    self.barChartView.barData?.barWidth = 0.5
                    self.barChartView.setVisibleXRangeMaximum(30)
                    
                    let goalline = ChartLimitLine(limit: stepgoal.double!, label: "Goal")
                    self.barChartView.rightAxis.addLimitLine(goalline)
                    
                    self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                    
                    self.barChartView.leftAxis.axisMinimum = 0
                    self.barChartView.rightAxis.axisMinimum = 0
                    
                    let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                              font: .systemFont(ofSize: 12),
                                              textColor: .white,
                                              insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                              xAxisValueFormatter: self.barChartView.xAxis.valueFormatter!)
                    marker.chartView = self.barChartView
                    marker.minimumSize = CGSize(width: 80, height: 40)
                    self.barChartView.marker = marker
                    
                    self.barChartView.autoScaleMinMaxEnabled = true
                   
                    
                case let .failure(error):
                    print(error)
                }
        }
    }
    
    @IBAction func showYear(sender: UIButton) {
        print(cur_userid)
        var unwrapped_id = ""
        if let unwrapped = cur_userid {
            unwrapped_id = unwrapped
        } else {
            print("Missing name")
        }
        
        self.barChartView.clear()
        self.barChartView.notifyDataSetChanged()
        
        self.TitleLabel.text = "Avg Step Counts"
        
        //making a post request
        AF.request(URL_USER_CHECK_YEAR, method: .post, parameters: ["id":unwrapped_id]).responseJSON
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
                    //print(recent_results)
                    
                    let stepgoal = json["stepgoal"]
                    print(stepgoal)
                    
                    let sorted_recent_results = recent_results.sorted(by:<)
                    
                    print(sorted_recent_results)
                    
                    var xvalues = Array<String>()
                    var yvalues = Array<Double>()
                    
                    //var new_recent_results = Array<Any>()
                    
                    // put dates into x values; steps into y values
                    for (one_date, one_step) in sorted_recent_results{
                        xvalues.append(one_date)
                        yvalues.append(one_step.double!)
                    }
                    
                    //print(xvalues) // date
                   // print(yvalues) // steps
                    
                    var dataEntries: [BarChartDataEntry] = []
                            
                    for i in 0 ..< record_num {
                        let dataEntry = BarChartDataEntry(x: Double(i), y: yvalues[i])
                        dataEntries.append(dataEntry)
                    }
                    //print(dataEntries)
                
                    let chartData = BarChartData()
                    let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Daily Steps")
                    
                    chartDataSet.drawValuesEnabled = false
                    
                    chartData.addDataSet(chartDataSet)
                    self.barChartView.data = chartData
                    self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xvalues)
                    self.barChartView.xAxis.granularity = 1
                    self.barChartView.xAxis.labelRotationAngle = -15
                    self.barChartView.extraTopOffset = 15
                    self.barChartView.setVisibleXRangeMaximum(12)
                    self.barChartView.barData?.barWidth = 0.5
                    
                    let goalline = ChartLimitLine(limit: stepgoal.double!, label: "Goal")
                    self.barChartView.rightAxis.addLimitLine(goalline)
                    
                    self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                    
                    self.barChartView.leftAxis.axisMinimum = 0
                    self.barChartView.rightAxis.axisMinimum = 0
                    
                    let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                              font: .systemFont(ofSize: 12),
                                              textColor: .white,
                                              insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                              xAxisValueFormatter: self.barChartView.xAxis.valueFormatter!)
                    marker.chartView = self.barChartView
                    marker.minimumSize = CGSize(width: 80, height: 40)
                    self.barChartView.marker = marker

                case let .failure(error):
                    print(error)
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.delegate = self
        
        barChartView.noDataText = "Please select from above."
        
        TitleLabel.text = "History Records 📋"

        // Do any additional setup after loading the view.
        //print(cur_userid)
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

