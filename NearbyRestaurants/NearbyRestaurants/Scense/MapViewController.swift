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
        disableDarkMode()
        let setup: MapViewViewModel = MapViewViewModel()
        self.configure(viewModel: setup)
        self.setupMapView()
        self.searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    private func bindViewModel() {
        self.viewModel.output.didGetNearbyRestaurantsFromLocalSuccess = didGetNearbyRestaurantsLocalSuccess
        self.viewModel.output.didGetNearbyRestaurantsFromLocalFail = didGetNearbyLocationsLocalFail
        self.viewModel.output.didGetNearbyRestaurantsFromLocalWithKeywordSuccess = didGetNearbyRestaurantsFromLocalWithKeywordSuccess
        self.viewModel.output.didGetNearbyRestaurantsFromLocalWithKeywordFail = didGetNearbyRestaurantsFromLocalWithKeywordFail
        self.viewModel.output.didGetNearbyRestaurantsFromNetworkWithKeywordSuccess = didGetNearbyRestaurantsFromNetworkWithKeywordSuccess
    }
    
    fileprivate func disableDarkMode() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
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
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        return locationManager.location?.coordinate ?? nil
    }
    
    @IBAction private func getNearbyRestaurants(_ sender: Any) {
        guard let region = self.coordinateRegion else {
            return
        }
        self.viewModel.input.saveNearbyRestaurantsToLocal(region: region)
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
    
    private func addMarker(location: CLLocationCoordinate2D, title: String, restaurant: Restaurant) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.userData = restaurant
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
        guard let restaurantData = marker.userData as? Restaurant else {
            return
        }
        let actionSheetPicker = UIAlertController(title: "\(marker.title ?? "")", message: nil, preferredStyle: .actionSheet)
        let phoneAction: UIAlertAction = UIAlertAction(title: "Phone Number.", style: .default, handler: { _ in
            let phoneNumber = self.reformatPhoneNumber(number: restaurantData.phoneNumber ?? "")
            guard let number = URL(string: "tel://" + "\(String(describing: phoneNumber))") else {
                self.alertError(with: "Phone number not found.")
                return
            }
            UIApplication.shared.open(number)
        })
        let urlAction: UIAlertAction = UIAlertAction(title: "Website", style: .default, handler: { _ in
            guard let url = URL(string: "\(restaurantData.website ?? "")") else {
                self.alertError(with: "Website not found.")
                return
            }
            UIApplication.shared.open(url)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetPicker.addAction(phoneAction)
        actionSheetPicker.addAction(urlAction)
        actionSheetPicker.addAction(cancelAction)
        self.present(actionSheetPicker, animated: true, completion: nil)
    }
    
    private func didGetNearbyRestaurantsLocalSuccess(restaurants: [Restaurant]) {
        self.gmsMapView.clear()
        for restaurant in restaurants {
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "", restaurant: restaurant)
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
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "", restaurant: restaurant)
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
            self.addMarker(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: restaurant.lat ?? 0.0)!, longitude: CLLocationDegrees(exactly: restaurant.long ?? 0.0)!), title: restaurant.name ?? "", restaurant: restaurant)
        }
        self.setCameraZoomBound()
    }
    
    private func reformatPhoneNumber(number: String) -> String {
        guard !number.isEmpty else {
            return ""
        }
        var numberToCall = ""
        let removeprefix = number.replacingOccurrences(of: "_$!<", with: "")
        let removesuffix = removeprefix.replacingOccurrences(of: ">!$_", with: "")
        numberToCall = removesuffix
        let replacedLeftBracket = numberToCall.replacingOccurrences(of: "(", with: "")
        let replacedRightBracket = replacedLeftBracket.replacingOccurrences(of: ")", with: "")
        let replacedUpperLineNumber = replacedRightBracket.replacingOccurrences(of: "-", with: "")
        let replaced2SpaceNumber = replacedUpperLineNumber.replacingOccurrences(of: " ", with: "")
        let replaceZeroFormat = replaced2SpaceNumber.replace(target: "+66", withString: "0")
        return replaceZeroFormat.digits
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

