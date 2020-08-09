//
//  MapViewViewModel.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 7/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation
import MapKit

protocol MapViewInputProtocol {
    func saveNearbyRestaurantsToLocal(region: MKCoordinateRegion)
}

protocol MapViewOutputProtocol: class {
    var didGetNearbyRestaurantsFromLocalSuccess: (([Restaurant]) -> Void?)? { get set }
    var didGetNearbyRestaurantsFromKeywordSuccess: (([Restaurant]) -> Void?)? { get set }
    var didGetNearbyRestaurantsFromLocalFail: (() -> Void)? { get set }
}

protocol MapProtocol: MapViewInputProtocol, MapViewOutputProtocol {
    var input: MapViewInputProtocol { get }
    var output: MapViewOutputProtocol { get }
}

final class MapViewViewModel: MapProtocol {
    var input: MapViewInputProtocol { return self}
    
    var output: MapViewOutputProtocol { return self }
    
    var didGetNearbyRestaurantsFromLocalSuccess: (([Restaurant]) -> Void?)?
    
    var didGetNearbyRestaurantsFromKeywordSuccess: (([Restaurant]) -> Void?)?
    
    var didGetNearbyRestaurantsFromLocalFail: (() -> Void)?
    
    private var getRestaurantsUseCase: GetRestaurantsUseCase = GetRestaurantsUseCaseImpl()
    
    private var saveRestaurantsUseCase: SaveNearbyRestaurantsUseCase = SaveRestaurantsUseCaseImpl()
    
    func saveNearbyRestaurantsToLocal(region: MKCoordinateRegion) {
        self.saveRestaurantsUseCase.saveNearbyRestaurantsToLocal(region: region)
        if self.getRestaurantsUseCase.getNearbyRestaurantsFromLocal().count != 0 {
            self.didGetNearbyRestaurantsFromLocalSuccess?(self.getRestaurantsUseCase.getNearbyRestaurantsFromLocal())
        } else {
            self.didGetNearbyRestaurantsFromLocalFail?()
        }
    }
    
}
