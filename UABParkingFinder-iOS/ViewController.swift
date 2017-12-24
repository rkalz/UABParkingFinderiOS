//
//  ViewController.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    func WakeUpHeroku() {
        // Wakes up Heroku server if idle
        let request = URLRequest(url: URL(string: "http://uab-parking-finder-server.herokuapp.com")!)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if (error != nil) {
                print("Cannot connect to ingest server: ", terminator:"")
                print(error!)
            }
            print("Ingest server online")
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Contacting ingest server...")
        WakeUpHeroku()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

