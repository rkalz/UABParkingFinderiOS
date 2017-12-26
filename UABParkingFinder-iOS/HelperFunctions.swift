//
//  HelperFunctions.swift
//  UABParkingFinder-iOS
//
//  Created by Rofael Aleezada on 12/25/17.
//  Copyright © 2017 Rofael Aleezada. All rights reserved.
//

import Foundation

func generateSingleGMapsURL(lat: Double, lon: Double, size: Int) -> URL? {
    
    let path = "https://maps.googleapis.com/maps/api/staticmap?center=" + String(lat) + "," + String(lon) + "&markers=color:red|" + String(lat) +
        "," + String(lon) + "&zoom=13&size=" + String(size) + "x" + String(size)
    
    return URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
}
