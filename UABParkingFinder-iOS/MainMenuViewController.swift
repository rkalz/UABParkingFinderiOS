//
//  MainMenuViewController.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import SDWebImage

// Allows manipulation of lot cell
class MainMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var map: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var lastReport: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var distance: UILabel!
}

class MainMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var lots = [Lot]()
    var ref: DatabaseReference!
    @IBOutlet weak var listOfLots: UITableView!
    var refreshControl: UIRefreshControl!
    
    // Contacts Heroku ingest server
    func WakeUpHeroku() {
        print("Connecting to ingest server...")
        
        let request = URLRequest(url: URL(string: "http://uab-parking-finder-server.herokuapp.com")!)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if (error != nil) {
                print("Cannot connect to ingest server: ", terminator:"")
                print(error!)
            }
            print("Ingest server online!")
        }
        task.resume()
    }
    
    // Downloads JSON with list of parking lots
    func GetParkingData() {
        print("Downloading parking location data...")
        
        let request = URLRequest(url: URL(string: "http://rofael.net/projects/uabpf/parking.json")!)
        
        // Completion handler means code won't run until after data is downloaded
        let completion: (Data?, URLResponse?, Error?) -> Void = {
            (data, response, error) in
            do {
                let jsonPlaces = try JSONDecoder().decode(JSONParkingContainer.self, from: data!)
                for place in jsonPlaces.data {
                    self.lots.append(place.toLot())
                }
                print("Parking data received!")
                DispatchQueue.main.async {
                    // Must reload on main thread
                    self.listOfLots.reloadData()
                }
            } catch {
                print(error)
            }
        }
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
    
    override func loadView() {
        super.loadView()
        
        // Make sure ingest is online, download lots, and connect to Firebase
        WakeUpHeroku()
        GetParkingData()
        ref = Database.database().reference()
        
        // Tells list of lots to use this
        self.listOfLots.delegate = self
        self.listOfLots.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add pull to refresh to list of lots
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MainMenuViewController.refresh), for: UIControlEvents.valueChanged)
        self.listOfLots.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Height of each cell
        // TODO: Make sure this works across several screen sizes
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Populates each cell of the lots table
        // TODO: Get time of last update and overall status fron Firebase
        
        let parking = lots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "parkingLotCell", for: indexPath) as! MainMenuTableViewCell
        
        // Place Google Maps image
        let mapURL = generateSingleGMapsURL(lat: parking.lat, lon: parking.lon, size: 60)
        cell.map?.sd_setImage(with: mapURL,
                              placeholderImage: UIImage(named: "unk"),
                              completed: { (image, error, cacheType, imageURL) in
                                if (error != nil) { print(error!) }
        })
        
        cell.name?.text = parking.name
        cell.statusImg?.image = UIImage(named: "unk")
        
        return cell
    }
    
    @objc func refresh(sender: AnyObject) {
        // What to do on refresh
        // TODO: See cellForRowAt indexPath
        
        self.listOfLots.reloadData()
        refreshControl.endRefreshing()
    }
    
    


}

