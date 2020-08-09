//
//  RestaurantModel.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 8/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation
import MapKit

struct Restaurant {
    let name: String?
    let location: CLLocationCoordinate2D?
    let phoneNumber: String?
    let website: String?
    
    init(name: String, location: CLLocationCoordinate2D, phoneNumber: String, website: String) {
        self.name = name
        self.location = location
        self.phoneNumber = phoneNumber
        self.website = website
    }
}
