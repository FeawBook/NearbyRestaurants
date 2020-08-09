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

protocol MapViewRepository {
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion?) -> [Restaurant]
    func saveNearbyRestaurantsToLocal(restaurants: [Restaurant])
    func getNearbyRestaurantsFromLocal() -> [Restaurant]
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant]
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String) -> [Restaurant]
}

 final class MapViewRepositoryImpl: MapViewRepository {
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion?) -> [Restaurant] {
        guard let region = region else {
            return []
        }
        var arrRestaurant: [Restaurant] = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurants"
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, error) in
            guard let response = response else {
                debugPrint(error?.localizedDescription ?? "unknow error")
                return
            }
            for item in response.mapItems {
                guard let location = item.placemark.location else {
                    return
                }
                let restaurant = Restaurant(name: item.name ?? "", location: location.coordinate, phoneNumber: item.phoneNumber ?? "", website: item.url?.absoluteString ?? "")
                arrRestaurant.append(restaurant)
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
            }
        })
        return arrRestaurant
    }
    
    func saveNearbyRestaurantsToLocal(restaurants: [Restaurant]) {
        UserDefaults.standard.set(restaurants, forKey: "restaurants")
    }
    
    func getNearbyRestaurantsFromLocal() -> [Restaurant] {
        if let restaurants = UserDefaults.standard.array(forKey: "restaurants") as? [Restaurant] {
            return restaurants
        } else {
            return []
        }
    }
    
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant] {
        if let restaurants = UserDefaults.standard.array(forKey: "restaurants") as? [Restaurant] {
            return restaurants.filter { $0.name!.contains(keyword) }
        } else {
            return []
        }
    }
    
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String) -> [Restaurant] {
        guard let region = region else {
            return []
        }
        var arrRestaurant: [Restaurant] = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(textToSearch)"
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, error) in
            guard let response = response else {
                debugPrint(error?.localizedDescription ?? "unknow error")
                return
            }
            for item in response.mapItems {
                guard let location = item.placemark.location else {
                    return
                }
                let restaurant = Restaurant(name: item.name ?? "", location: location.coordinate, phoneNumber: item.phoneNumber ?? "", website: item.url?.absoluteString ?? "")
                arrRestaurant.append(restaurant)
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
            }
        })
        return arrRestaurant
    }
    
}
