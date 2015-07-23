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

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    var startLocation: String?
    var start = CLLocationCoordinate2D()
    var endLocation: String?
    var route: MKRoute?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchValue: UITextField!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        searchValue.delegate = self
        self.mapView.delegate = self
        
        if let start = startLocation {
            println(start)
        }
        if let end = endLocation {
            println(end)
            performSearch(end)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func performSearch(searchString: String) {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchString
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse!, error: NSError!) in
            if error != nil || response.mapItems.count == 0 {
                let alertController = UIAlertController(title: "No Matches", message: "No matches were found, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                println("No matches found")
            } else {
                println("Matches found")
//                for item in response.mapItems as! [MKMapItem] {
//                    println("Name = \(item.name)")
//                    println(item)
//                    self.matchingItems.append(item as MKMapItem)
//                    var annotation = MKPointAnnotation()
//                    annotation.coordinate = item.placemark.coordinate
//                    annotation.title = item.name
//                    self.mapView.addAnnotation(annotation)
//                }
                let found: MKMapItem = response.mapItems[0] as! MKMapItem
//                let foundLocation = CLLocationCoordinate2D (latitude: found.placemark.location.coordinate.latitude, longitude: found.placemark.location.coordinate.longitude)
                var annotation = MKPointAnnotation()
                annotation.coordinate = found.placemark.coordinate
                annotation.title = found.name
                self.mapView.addAnnotation(annotation)
//                self.mapView.centerCoordinate = found.placemark.coordinate
                
                let request = MKDirectionsRequest()
                request.setSource(MKMapItem.mapItemForCurrentLocation())
                request.setDestination(found)
                request.requestsAlternateRoutes = false
                
                let directions = MKDirections(request: request)
                
                directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse!, error: NSError!) in
                    if error != nil {
                        //handle error
                        println("error")
                        println(error)
                    } else {
                        println("route found")
//                        self.route = response.routes[0] as? MKRoute
//                        self.mapView.addOverlay(self.route?.polyline)
                        self.showRoute(response)
                    }
                })
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as! [MKRoute] {
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                println(step.instructions)
            }
        }
//        let userLocation = mapView.userLocation
//        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
//        mapView.setRegion(region, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchValue.resignFirstResponder()
        mapView.removeAnnotations(mapView.annotations)
        self.performSearch(searchValue.text)
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate;
        let span2 = MKCoordinateSpanMake(0.1, 0.1)
        let long = locValue.longitude;
        let lat = locValue.latitude;
        println(long);
        println(lat);
        let loadlocation = CLLocationCoordinate2D(
            latitude: lat, longitude: long
        )
        start = loadlocation
        
        mapView.centerCoordinate = loadlocation;
        let initialLocation = CLLocation(latitude: lat, longitude: long)
        centerMapOnLocation(initialLocation)
        locationManager.stopUpdatingLocation();
    }
    
    func mapView(MapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var renderer = MKPolylineRenderer(polyline: route?.polyline!)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

