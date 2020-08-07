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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapView()
        self.searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func bindViewModel() {
        
    }
    
    private func setupMapView() {
        guard let location = self.getCurrentLocation() else {
            return
        }
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 15.0)
        self.gmsMapView.camera = camera
        self.gmsMapView.isMyLocationEnabled = true
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
        self.searchNearbyRestaurants()
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
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTextField.endEditing(true)
        self.searchRestaurant(textToSearch: textField.text ?? "")
        return true
    }
}

