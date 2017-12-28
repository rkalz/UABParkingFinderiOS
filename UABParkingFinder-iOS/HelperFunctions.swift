//
//  HelperFunctions.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/25/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import Foundation

// Takes latitude, longitude, and a size to return a Google Maps image
// of those coordinates of size x size
func generateSingleGMapsURL(lat: Double, lon: Double, size: Int) -> URL? {
    
    let path = "https://maps.googleapis.com/maps/api/staticmap?center=" + String(lat) + "," + String(lon) + "&markers=color:red|" + String(lat) + "," + String(lon) + "&zoom=14&size=" + String(size) + "x" + String(size)
    
    return URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
}

// Takes a size and two pairs of latitude and longitude to return a Google Maps image
// of these coordinates of size x size
func generatePairGMapsURL(latA: Double, lonA: Double, latB: Double, lonB: Double, size: Int) -> URL? {
    
    let path = "https://maps.googleapis.com/maps/api/staticmap?markers=color:blue||" + String(latA) + "," + String(lonA) + "&markers=color:red|" + String(latB) + "," + String(lonB) + "&size=" + String(size) + "x" + String(size)
    
    return URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
}

// Converts distance in feet to a readable string in the form "X.XXmi/ft"
func readableDistance(distance: Double) -> String {
    var output = distance
    
    if (distance > 1000) {
        output = output / (5280 as Double)
        output = round(output * 100) / (100 as Double)
        return String(output) + "mi"
        
    } else {
        output = round(output * 100) / (100 as Double)
        return String(output) + "ft"
    }
    
}
