//
//  DataStructs.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/24/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import Foundation
import UIKit

// Represents the name of a lot and the latitude and longitude of its position
struct Lot {
    var name: String
    var lat: Double!
    var lon: Double!
    var status: Int
    
    init(inName: String) {
        name = inName
        lat = 33.5021227
        lon = -86.8086334
        status = -1
    }
    
    init(inName: String, inLat: String, inLon: String) {
        name = inName
        lat = Double(inLat)
        lon = Double(inLon)
        status = -1
    }
}

// Represents a report denoting which parking lot, status included in report,
// and time the report was made
struct Report {
    var parking: Lot!
    var status: Int!
    var time: Int64!
    
    init(inLot: Lot, inStat: Int) {
        parking = inLot
        status = inStat
        // set time to current time in milliseconds
    }
    
    init(inLot: Lot, inStat: Int, inTime: Int64) {
        parking = inLot
        status = inStat
        time = inTime
    }
    
    // String representation of status
    func viewStatus() -> String {
        switch(status) {
        case 0:
            return "Somewhat empty"
        case 1:
            return "Filling up"
        case 2:
            return "Almost full"
        default:
            return "How full is the parking lot?"
        }
    }
    
    // Converts UNIX millsecond time to something readable
    func readableLastReportTime() -> String {
        
        return ""
    }
}

// Intermediate, as JSON cannot be directly converted to Double
struct JSONParkingLot : Codable {
    var name: String
    var lat: String
    var lon: String
    
    func toLot() -> Lot {
        return Lot(inName: name, inLat: lat, inLon: lon)
    }
}

// Used to decode downloaded JSON file into array of objects
struct JSONParkingContainer : Codable {
    var data: [JSONParkingLot]
}
