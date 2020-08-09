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
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion?, completion: @escaping (([Restaurant]) -> Void?))
    func saveNearbyRestaurantsToLocal(restaurants: [Restaurant])
    func getNearbyRestaurantsFromLocal() -> [Restaurant]
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant]
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String, completion: @escaping (([Restaurant]) -> Void?))
}

 final class MapViewRepositoryImpl: MapViewRepository {
    func getNearbyRestaurantsLocation(region: MKCoordinateRegion?, completion: @escaping (([Restaurant]) -> Void?)) {
        guard let region = region else {
            return
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
                let restaurant = Restaurant(name: item.name ?? "", lat: Double(location.coordinate.latitude), long: Double(location.coordinate.longitude), phoneNumber: item.phoneNumber ?? "", website: item.url?.absoluteString ?? "")
                arrRestaurant.append(restaurant)
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
            }
            completion(arrRestaurant)
        })
        
    }
    
    func saveNearbyRestaurantsToLocal(restaurants: [Restaurant]) {
        if let _ = UserDefaults.standard.data(forKey: "restaurants") {
            UserDefaults.standard.removeObject(forKey: "restaurants")
        }
        let encodeData: Data = NSKeyedArchiver.archivedData(withRootObject: restaurants)
        UserDefaults.standard.set(encodeData, forKey: "restaurants")
        UserDefaults.standard.synchronize()
    }
    
    func getNearbyRestaurantsFromLocal() -> [Restaurant] {
        if let restaurantsDecode = UserDefaults.standard.data(forKey: "restaurants") {
            return NSKeyedUnarchiver.unarchiveObject(with: restaurantsDecode) as! [Restaurant]
        } else {
            return []
        }
    }
    
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant] {
        if let restaurants = UserDefaults.standard.data(forKey: "restaurants") {
            let decodeRestaurants = NSKeyedUnarchiver.unarchiveObject(with: restaurants) as! [Restaurant]
            return decodeRestaurants.filter{ $0.name! == keyword }
        } else {
            return []
        }
    }
    
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String, completion: @escaping (([Restaurant]) -> Void?)) {
        guard let region = region else {
            return
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
                let restaurant = Restaurant(name: item.name ?? "", lat: Double(location.coordinate.latitude), long: Double(location.coordinate.longitude), phoneNumber: item.phoneNumber ?? "", website: item.url?.absoluteString ?? "")
                arrRestaurant.append(restaurant)
                
                debugPrint(item.name ?? "not available")
                debugPrint(item.phoneNumber ?? "there aren't phone number.")
            }
            completion(arrRestaurant)
        })
    }
    
}
