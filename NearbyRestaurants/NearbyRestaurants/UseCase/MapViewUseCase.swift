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
    func searchNearbyRestaurantsFromLocal(keyword: String) -> [Restaurant]
    func getNearbyRestaurantsFromLocal() -> [Restaurant]
    func searchNearbyRestaurantFromMap(region: MKCoordinateRegion?, textToSearch: String) -> [Restaurant]
}

protocol SaveNearbyRestaurantsUseCase {
    func saveNearbyRestaurantsToLocal(region: MKCoordinateRegion?)
}

final class GetRestaurantsUseCaseImpl: GetRestaurantsUseCase {
    private var mapViewRepository: MapViewRepository
    init(mapViewRepository: MapViewRepository = MapViewRepositoryImpl()) {
        self.mapViewRepository = mapViewRepository
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

final class SaveRestaurantsUseCaseImpl: SaveNearbyRestaurantsUseCase {
    private var mapViewRepository: MapViewRepository
    init(mapViewRepository: MapViewRepository = MapViewRepositoryImpl()) {
        self.mapViewRepository = mapViewRepository
    }
    
    func saveNearbyRestaurantsToLocal(region: MKCoordinateRegion?) {
        guard let region = region else {
            return
        }
        self.mapViewRepository.getNearbyRestaurantsLocation(region: region, completion: { restaurants in
            self.mapViewRepository.saveNearbyRestaurantsToLocal(restaurants: restaurants)
        })
    }
}
