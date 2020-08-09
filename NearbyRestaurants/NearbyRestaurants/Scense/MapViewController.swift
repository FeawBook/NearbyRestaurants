//
//  ViewController.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 7/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

final class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var gmsMapView: GMSMapView!
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    private var coordinateRegion: MKCoordinateRegion?
    private var markerArray: [GMSMarker] = []
    var viewModel: MapViewViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let setup: MapViewViewModel = MapViewViewModel()
        self.configure(viewModel: setup)
        self.setupMapView()
        self.searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func bindViewModel() {
        self.viewModel.output.didGetNearbyRestaurantsFromLocalSuccess = didGetNearbyRestaurantsLocalSuccess
        self.viewModel.output.didGetNearbyRestaurantsFromLocalFail = didGetNearbyLocationsLocalFail
        self.viewModel.output.didGetNearbyRestaurantsFromLocalWithKeywordSuccess = didGetNearbyRestaurantsFromLocalWithKeywordSuccess
        self.viewModel.output.didGetNearbyRestaurantsFromLocalWithKeywordFail = didGetNearbyRestaurantsFromLocalWithKeywordFail
        self.viewModel.output.didGetNearbyRestaurantsFromNetworkWithKeywordSuccess = didGetNearbyRestaurantsFromNetworkWithKeywordSuccess
    }
    
    private func configure(viewModel: MapViewViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupMapView() {
        guard let location = self.getCurrentLocation() else {
            return
        }
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 15.0)
        self.gmsMapView.camera = camera
        self.gmsMapView.isMyLocationEnabled = true
        self.gmsMapView.delegate = self
    }
    
    private func getCurrentLocation() -> CLLocationCoordinate2D? {
        locationManager.delegate = self
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        return locationManager.location?.coordinate ?? nil
    }
    
    private func searchNearbyRestaurants() {
        guard let region = self.coordinateRegion else {
            return
        }
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
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
                print(item.url?.absoluteString)
                
                self.addMarker(location: location.coordinate, title: item.name ?? "")
            }
            self.setCameraZoomBound()
        })
    }
    
    private func searchRestaurant(textToSearch: String) {
        guard let region = self.coordinateRegion else {
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(textToSearch)"
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, error) in
            guard let response = response else {
                debugPrint(error?.localizedDescription ?? "unknow error")
                return
            }
            self.gmsMapView.clear()
            self.markerArray.removeAll()
            for item in response.mapItems {
                guard let location = item.placemark.location else {
                    return
                }
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
                self.addMarker(location: location.coordinate, title: item.name ?? "")
            }
            self.setCameraZoomBound()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            gmsMapView.isHidden = true
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let currentLocation = location.coordinate
        coordinateRegion = MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: 700,
            longitudinalMeters: 700
        )
        locationManager.stopUpdatingLocation()
        if let region = self.coordinateRegion {
            self.viewModel.input.saveNearbyRestaurantsToLocal(region: region)
        }
//        self.searchNearbyRestaurants()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertError(error)
    }
    
    private func alertError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func alertError(with stringError: String) {
        let alertController = UIAlertController(title: "Error", message: "\(stringError)", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func addMarker(location: CLLocationCoordinate2D, title: String) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.map = self.gmsMapView
        
        self.markerArray.append(marker)
    }
    
    private func setCameraZoomBound() {
        var bounds = GMSCoordinateBounds()
        for marker in markerArray {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        self.gmsMapView.animate(with: update)
    }
    
    private func openDetail(marker: GMSMarker) {
        let actionSheetPicker = UIAlertController(title: "\(marker.title ?? "")", message: nil, preferredStyle: .actionSheet)
        let phoneAction: UIAlertAction = UIAlertAction(title: "Phone number.", style: .default, handler: { _ in
            guard let number = URL(string: "tel://" + "0959081779") else { return }
            UIApplication.shared.open(number)
        })
        let urlAction: UIAlertAction = UIAlertAction(title: "Website", style: .default, handler: { _ in
            guard let url = URL(string: "https://www.google.com") else {
                return
            }
            UIApplication.shared.open(url)
        })
        actionSheetPicker.addAction(phoneAction)
        actionSheetPicker.addAction(urlAction)
        self.present(actionSheetPicker, animated: true, completion: nil)
    }
    
    private func didGetNearbyRestaurantsLocalSuccess(restaurants: [Restaurant]) {
        self.gmsMapView.clear()
        for restaurant in restaurants {
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "")
        }
        self.setCameraZoomBound()
    }
    
    private func didGetNearbyLocationsLocalFail() {
        guard let region = self.coordinateRegion else {
            return
        }
        self.viewModel.input.saveNearbyRestaurantsToLocal(region: region)
    }
    
    private func didGetNearbyRestaurantsFromLocalWithKeywordSuccess(restaurants: [Restaurant]) {
        self.gmsMapView.clear()
        for restaurant in restaurants {
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "")
        }
        self.setCameraZoomBound()
    }
    
    private func didGetNearbyRestaurantsFromLocalWithKeywordFail() {
        guard let region = self.coordinateRegion else {
            return
        }
        self.viewModel.input.searchLocationFromNetwork(keyword: self.searchTextField.text ?? "", region: region)
    }
    
    private func didGetNearbyRestaurantsFromNetworkWithKeywordSuccess(restaurants: [Restaurant]) {
        guard restaurants.count != 0 else {
            self.alertError(with: "Location not found")
            return
        }
        self.gmsMapView.clear()
        for restaurant in restaurants {
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "")
        }
        self.setCameraZoomBound()
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTextField.endEditing(true)
        self.viewModel.input.searchNearbyRestaurantFromLocal(keyword: textField.text ?? "")
        return true
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.openDetail(marker: marker)
    }
}

