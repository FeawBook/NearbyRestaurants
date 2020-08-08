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
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion)
    func saveNearbyRestaurantsToLocal(restaurant: Restaurant)
}

 final class MapViewRepositoryImpl: MapRepository {
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion) {
        
    }
    
    func saveNearbyRestaurantsToLocal(restaurant: Restaurant) {
        
    }
}
