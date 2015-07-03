//
//  ViewController.swift
//  Shortcut
//
//  Created by Paula Chojnacki on 6/29/15.
//  Copyright (c) 2015 Paula Chojnacki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchValue: UITextField!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    let locationManager = CLLocationManager()
    
//    @IBAction func search(sender: UITextField) {
//        sender.resignFirstResponder()
//        mapView.removeAnnotations(mapView.annotations)
//        self.performSearch()
//    }
    
    func performSearch() {
        println("got here!")
        matchingItems.removeAll()
        println("after remove all")
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchValue.text
        request.region = mapView.region
        
        println("request set")
        
        let search = MKLocalSearch(request: request)
        println("search set")
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse!, error: NSError!) in
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("No matches found")
            } else {
                println("Matches found")
                for item in response.mapItems as! [MKMapItem] {
                    println("Name = \(item.name)")
                    self.matchingItems.append(item as MKMapItem)
                    println("Matching items = \(self.matchingItems.count)")
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchValue.delegate = self
        // Ask for Authorisation from the User.
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("return pressed")
        searchValue.resignFirstResponder()
        println("first responder resigned")
        mapView.removeAnnotations(mapView.annotations)
        println("annotations removed")
        self.performSearch()
        println("search performed")
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate;
        let span2 = MKCoordinateSpanMake(1, 1)
        let long = locValue.longitude;
        let lat = locValue.latitude;
        println(long);
        println(lat);
        let loadlocation = CLLocationCoordinate2D(
            latitude: lat, longitude: long
            
        )
        
        mapView.centerCoordinate = loadlocation;
        locationManager.stopUpdatingLocation();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

