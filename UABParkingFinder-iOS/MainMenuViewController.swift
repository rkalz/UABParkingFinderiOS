//
//  MainMenuViewController.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import UIKit
import Foundation

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
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            do {
                let jsonPlaces = try JSONDecoder().decode(JSONParkingContainer.self, from: data!)
                for place in jsonPlaces.data {
                    self.lots.append(place.toLot())
                }
                print("Parking data received!")
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        WakeUpHeroku()
        GetParkingData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let parking = lots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "parkingLotCellProto", for: indexPath) as! MainMenuTableViewCell
        cell.map.image = UIImage(named: "unk")
        cell.name.text = parking.name
        cell.statusImg.image = UIImage(named: "unk")
        return cell
    }*/


}

