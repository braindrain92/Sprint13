//
//  GeoViewController.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GeoViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    private let locationManager = CLLocationManager()
    var curentLocation: CLLocationCoordinate2D?
    var index = 0
    let experienceController = ExperienceController.shared
    
    var titletext: String?
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Actions
    
    @IBAction func startExperienceBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addExperienceSegue", sender: sender)
    }
    
    @IBAction func storeBtnPressed(_ sender: Any) {
    }
    
    // MARK: - VC Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            NSLog("Allow access")
        }
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let experience = annotation as? Experience else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView", for: experience) as! MKMarkerAnnotationView
        annotationView.markerTintColor = .gray
        annotationView.glyphTintColor = .black
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        curentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: curentLocation!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        // Set region on map
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func updateView() {
        let anotations = mapView.annotations
        
        mapView.removeAnnotations(anotations)
        mapView.addAnnotations(experienceController.experiences)
        print(experienceController.experiences.count)
        if experienceController.experiences.count > 0 {
            
            let newPin = MKPointAnnotation()
            if let lastCoordinate = experienceController.experiences.last?.coordinate {
                newPin.coordinate = lastCoordinate
            }
            if let annotationText = experienceController.experiences.last?.title {
                newPin.title = annotationText
            }
            mapView.addAnnotation(newPin)
        }
    }
}
