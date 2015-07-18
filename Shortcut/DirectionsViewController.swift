//
//  DirectionsViewController.swift
//  Shortcut
//
//  Created by Paula Chojnacki on 7/3/15.
//  Copyright (c) 2015 Paula Chojnacki. All rights reserved.
//

import UIKit
import CoreLocation

class DirectionsViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var endLocation: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationController = segue.destinationViewController as! UINavigationController
        let controller = destinationController.topViewController as! MapViewController
        controller.startLocation = startLocation.text
        controller.endLocation = endLocation.text
    }
}