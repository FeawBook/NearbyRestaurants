//
//  MapViewRepository.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 7/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation
import GoogleMaps
import MapKit

protocol MapRepository {
    func getNearbyRestaurantsLocation(currentLocation: CLLocationCoordinate2D)
}

 final class MapViewRepositoryImpl: MapRepository {
    func getNearbyRestaurantsLocation(currentLocation: CLLocationCoordinate2D) {
        
    }
    
    func getLocationDetails() {
        
    }
}
