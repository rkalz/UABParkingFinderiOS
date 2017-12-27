//
//  ParkingMenuViewController.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import SDWebImage

class ParkingMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var reportTimeLabel: UITextField!
    @IBOutlet weak var reportTextLabel: UITextField!
    @IBOutlet weak var reportStatusImage: UIImageView!
}

class ParkingMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var lotName: String = ""
    var reports = [Report]()
    var ref: DatabaseReference!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var lotMapImage: UIImageView!
    @IBOutlet weak var lotStatusLabel: UILabel!
    @IBOutlet weak var selectStatusPicker: UIPickerView!
    @IBOutlet weak var sendReportButton: UIButton!
    @IBOutlet weak var listOfReports: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    override func loadView() {
        super.loadView()
        
        self.listOfReports.delegate = self
        self.listOfReports.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lotNameLabel?.text = lotName
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
        
        return cell
    }
    
    
}

