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
    
    private func searchRestaurants(textForSearch: String) {
        guard textForSearch != "" else {
            debugPrint("nothing....")
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(textForSearch)"
//        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, error) in
            guard let response = response else {
                debugPrint(error?.localizedDescription ?? "unknow error")
                return
            }
            
            for item in response.mapItems {
                print(item.name ?? "not available")
                print(item.phoneNumber ?? "there aren't phone number.")
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: 700,
            longitudinalMeters: 700
        )
//        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
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
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTextField.endEditing(true)
//        self.searchRestaurants(textForSearch: textField.text ?? "")
        return true
    }
}

