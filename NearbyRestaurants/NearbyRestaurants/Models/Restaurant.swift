//
//  RestaurantModel.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 8/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation
import MapKit

class Restaurant: NSObject, NSCoding {
    let name: String?
    let lat: Double?
    let long: Double?
    let phoneNumber: String?
    let website: String?
    
    init(name: String, lat: Double?, long: Double?, phoneNumber: String, website: String) {
        self.name = name
        self.lat = lat
        self.long = long
        self.phoneNumber = phoneNumber
        self.website = website
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let lat = aDecoder.decodeObject(forKey: "lat") as! Double
        let long = aDecoder.decodeObject(forKey: "long") as! Double
        let phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as! String
        let website = aDecoder.decodeObject(forKey: "website") as! String
        self.init(name: name, lat: lat, long: long, phoneNumber: phoneNumber,website: website)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(long, forKey: "long")
        aCoder.encode(phoneNumber, forKey: "phoneNumber")
        aCoder.encode(website, forKey: "website")
    }
}
