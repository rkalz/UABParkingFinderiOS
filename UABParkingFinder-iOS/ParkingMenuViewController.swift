//
//  ParkingMenuViewController.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

import FirebaseDatabase
import SDWebImage

class ParkingMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var reportTimeLabel: UITextField!
    @IBOutlet weak var reportTextLabel: UITextField!
    @IBOutlet weak var reportStatusImage: UIImageView!
}

class ParkingMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    var lot: Lot = Lot(inName: "lotName")
    var reports = [Report]()
    var pickerData = [String]()
    var selectedStatus: Int = -1
    var reportReady = false
    
    let manager = CLLocationManager()
    var ref: DatabaseReference!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var lotMapImage: UIImageView!
    @IBOutlet weak var lotStatusLabel: UILabel!
    @IBOutlet weak var selectStatusPicker: UIPickerView!
    @IBOutlet weak var listOfReports: UITableView!
    
    // Populates report table with the ten most recent reports and adds listener for any
    // data that comes in later
    func getFirebaseData() {
        // Get fifteen most recent reports, sort in descending order
        ref.child("reports").child(lot.name).queryLimited(toLast: 15).observeSingleEvent(of: DataEventType.value, with: {
            (snapshot) in
            let result = snapshot.value as? NSDictionary
            for (_, rep) in result! {
                let time = (rep as! NSDictionary)["reportTime"] as! Int64
                let status = (rep as! NSDictionary)["status"] as! Int
                
                self.reports.append(Report(inLot: self.lot, inStat: status, inTime: time))
            }
            self.reports.sort()
            self.listOfReports.reloadData()
        })
        
        // Add listener for new reports
        ref.child("reports").child(lot.name).queryLimited(toLast: 1).observe(DataEventType.value, with: {
            (snapshot) in
            let result = snapshot.value as? NSDictionary
            for (_, rep) in result! {
                let time = (rep as! NSDictionary)["reportTime"] as! Int64
                let status = (rep as! NSDictionary)["status"] as! Int
                
                self.reports.append(Report(inLot: self.lot, inStat: status, inTime: time))
            }
            self.reports.sort()
            let _ = self.reports.popLast()
            self.listOfReports.reloadData()
        })
    }
    
    override func loadView() {
        super.loadView()
        
        ref = Database.database().reference()
        self.listOfReports.delegate = self
        self.listOfReports.dataSource = self
        self.selectStatusPicker.delegate = self
        self.selectStatusPicker.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lotNameLabel?.text = lot.name
        lotStatusLabel?.text = lot.viewStatus()
        
        // Add pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ParkingMenuViewController.refresh), for: UIControlEvents.valueChanged)
        self.scrollView.addSubview(refreshControl)
        
        // Location service setup
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // Get data from database
        getFirebaseData()
        
        // Populate pickerData
        pickerData = ["How full is the parking lot?",
                      "Somewhat empty",
                      "Filling up",
                      "Almost full"]
        
        // Add long press to map image
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ParkingMenuViewController.longPressed))
        lotMapImage?.addGestureRecognizer(tapRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let report = reports[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ParkingMenuTableViewCell
        
        cell.reportTimeLabel?.text = report.readableLastReportTime()
        cell.reportTextLabel?.text = report.viewStatus()
        cell.reportStatusImage?.image = report.statusImage()
        
        return cell
    }
    
    @objc func refresh(sender: AnyObject) {
        self.listOfReports.reloadData()
        refreshControl.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let curLoc = locations[0]
        let curLat = curLoc.coordinate.latitude
        let curLon = curLoc.coordinate.longitude
        
        lotMapImage?.sd_setImage(with: generatePairGMapsURL(latA: curLat, lonA: curLon, latB: lot.lat, lonB:       lot.lon, size: 300), placeholderImage: UIImage(named: "unk"), completed: { (image, error, cacheType, imageURL) in if (error != nil) { print(error!) } })
        
        self.manager.stopUpdatingLocation()
        self.listOfReports.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedStatus = row - 1
        if (row != 0) { reportReady = true }
    }
    
    // Sends report when send report button is pressed
    @IBAction func onSendReportTouchDown(_ sender: Any) {
        if (reportReady) {
            let data = Report(inLot: self.lot, inStat: self.selectedStatus)
            
            let report: NSDictionary = [
                "lot" : data.lot.name as NSString,
                "reportTime" : data.reportTime! as NSNumber,
                "status" : data.status! as NSNumber
            ]
            
            ref.child("reports").child(lot.name).childByAutoId().setValue(report)
            self.reportReady = false
        }
    }
    
    // Opens Maps for directions to lot
    @objc func longPressed(sender: UITapGestureRecognizer) {
        var url = String()
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            url = "comgooglemaps://?center=" + String(self.lot.lat) + "," + String(self.lot.lon) + "&zoom=14"
        } else {
            url = "http://maps.apple.com/?sll=" + String(self.lot.lat) + "," + String(self.lot.lon) + "&z=14"
        }
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
}

