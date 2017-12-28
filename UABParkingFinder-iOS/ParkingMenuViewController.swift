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

class ParkingMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var lot: Lot = Lot(inName: "lotName")
    var reports = [Report]()
    let manager = CLLocationManager()
    var ref: DatabaseReference!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var lotMapImage: UIImageView!
    @IBOutlet weak var lotStatusLabel: UILabel!
    @IBOutlet weak var selectStatusPicker: UIPickerView!
    @IBOutlet weak var sendReportButton: UIButton!
    @IBOutlet weak var listOfReports: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    
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
                self.reports.remove(at: 0)
            }
            self.reports.sort()
            self.listOfReports.reloadData()
        })
    }
    
    override func loadView() {
        super.loadView()
        
        ref = Database.database().reference()
        self.listOfReports.delegate = self
        self.listOfReports.dataSource = self
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
    
}

