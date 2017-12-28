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
    
    // Used by JSON intermediate
    init(inName: String, inLat: String, inLon: String) {
        name = inName
        lat = Double(inLat)
        lon = Double(inLon)
        status = -1
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
}

// Represents a report denoting which parking lot, status included in report,
// and time the report was made
struct Report: Comparable {
    
    var parking: Lot!
    var status: Int!
    var time: Int64!
    
    init(inLot: Lot, inStat: Int) {
        parking = inLot
        status = inStat
        time = Int64(Date().timeIntervalSince1970 * 1000)
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
    
    // Returns the appropriate UIImage from the status
    func statusImage() -> UIImage {
        switch(status) {
        case 0:
            return UIImage(named: "low")!
        case 1:
            return UIImage(named: "med")!
        case 2:
            return UIImage(named: "high")!
        default:
            return UIImage(named: "unk")!
        }
    }
    
    // Converts UNIX millsecond time to something readable
    // Relative to current time
    func readableLastReportTime() -> String {
        let curTime = Int64(Date().timeIntervalSince1970 * 1000)
        let diff = curTime - self.time
        
        var seconds = diff / 1000
        var minutes = seconds / 60
        var hours = minutes / 60
        let days = hours / 24
        
        var left: String
        var right: String
        
        if (days > 0) {
            hours = hours % 24
            if ( days == 1 ) { left = " day and " }
            else { left = " days and " }
            
            if ( hours == 1 ) { right = " hour ago" }
            else { right = " hours ago" }
            
            return String(days) + left + String(hours) + right
        } else if (hours > 0) {
            minutes = minutes % 60
            if (hours == 1) { left = " hour and " }
            else { left = " hours and "}
            
            if ( minutes == 1 ) { right = " minute ago" }
            else { right = " minutes ago" }
            
            return String(hours) + left + String(minutes) + right
        } else if (minutes > 0) {
            seconds = seconds % 60
            if (minutes == 1) { left = " minute and " }
            else { left = " minutes and " }
            
            if (seconds == 1) { right = " second ago" }
            else { right = " seconds ago" }
            
            return String(minutes) + left + String(seconds) + right
        } else {
            if (seconds == 1) { right = " second ago" }
            else { right = " seconds ago" }
            
            return String(seconds) + right
        }
    }
    
    // All sorts are reversed so we get reports in descending order (newest first)
    static func <(lhs: Report, rhs: Report) -> Bool {
        if (lhs.parking.name != rhs.parking.name) { return false }
        
        let timeLeft = Int(lhs.time)
        let timeRight = Int(rhs.time)
        
        if (timeLeft > timeRight) { return true }
        return false
    }
    
    static func <=(lhs: Report, rhs: Report) -> Bool {
        if (lhs.parking.name != rhs.parking.name) { return false }
        
        let timeLeft = Int(lhs.time)
        let timeRight = Int(rhs.time)
        
        if (timeLeft >= timeRight) { return true }
        return false
    }
    
    static func ==(lhs: Report, rhs: Report) -> Bool {
        if ((lhs.parking.name == rhs.parking.name) &&
            (lhs.status == rhs.status) &&
            (Int(lhs.time) == Int(rhs.time))) { return true }
        return false
    }
    
    static func >=(lhs: Report, rhs: Report) -> Bool {
        if (lhs.parking.name != rhs.parking.name) { return false }
        
        let timeLeft = Int(lhs.time)
        let timeRight = Int(rhs.time)
        
        if (timeLeft <= timeRight) { return true }
        return false
    }
    
    static func >(lhs: Report, rhs: Report) -> Bool {
        if (lhs.parking.name != rhs.parking.name) { return false }
        
        let timeLeft = Int(lhs.time)
        let timeRight = Int(rhs.time)
        
        if (timeLeft < timeRight) { return true }
        return false
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
