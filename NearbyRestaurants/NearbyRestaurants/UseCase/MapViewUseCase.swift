//
//  MapViewUseCase.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 7/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation
import MapKit

protocol GetRestaurantsUseCase {
    func getNearbyRestaurants(region: MKCoordinateRegion?) -> [Restaurant]
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant]
    func getNearbyRestaurantsFromLocal() -> [Restaurant]
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String) -> [Restaurant]
}

protocol SaveNearbyRestaurantsUseCase {
    func saveNearbyRestaurantsToLocal(restaurants: [Restaurant])
}

final class MapViewUseCaseImpl: GetRestaurantsUseCase {
    private var mapViewRepository: MapViewRepository
    init(mapViewRepository: MapViewRepositoryImpl) {
        self.mapViewRepository = mapViewRepository
    }
    func getNearbyRestaurants(region: MKCoordinateRegion?) -> [Restaurant] {
        return self.mapViewRepository.getNearbyRestaurantsLocation(region: region)
    }
    
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant] {
        return self.mapViewRepository.searchNearbyRestaurantsFromLocal(keyword: keyword)
    }
    
    func getNearbyRestaurantsFromLocal() -> [Restaurant] {
        return self.mapViewRepository.getNearbyRestaurantsFromLocal()
    }
    
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String) -> [Restaurant] {
        return self.mapViewRepository.searchNearbyRestaurantFromMap(region: region, textToSearch: textToSearch)
    }
    
}
