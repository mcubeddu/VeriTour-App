//
//  ViewController.swift
//  Tour Harvard
//
//  Created by Michael Cubeddu on 11/25/16.
//  Copyright © 2016 The Boys. All rights reserved.

//Websites we used: http://www.appcoda.com/geo-targeting-ios/

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
        
    // connect outlets from storyboard
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    @IBAction func buttonPressed(_ sender: Any) {
        if (sender as AnyObject).tag == 0 {
            placeLable = closestPlace
        }
        if (sender as AnyObject).tag == 1 {
            placeLable = closestPlace2
        }
    }
    
    // search bar varibables
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    
    
    // initialize global
    let minDistance = 1000.0
    let locationManager = CLLocationManager()
    var nearByLocations = [CLLocation]()
    var curLocation = CLLocation()
    var placeLable = String()
    var closestPlace = String()
    var closestPlace2 = String()
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // add standard/hybrid map options
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func changeMap(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            map.mapType = MKMapType.standard;
        case 1:
            map.mapType = MKMapType.hybrid;
        default:
            break; 
        } 
    }
    

    
    // initialize pins array (globally)
    let pins = [
        Pins(title: "Wigglesworth Hall", coordinate: CLLocationCoordinate2D(latitude: 42.373043, longitude: -71.117063), info: "Freshman Dormitory"),
        Pins(title: "Widener Library", coordinate: CLLocationCoordinate2D(latitude: 42.373662, longitude: -71.116430), info: "Harvard's main library!"),
        Pins(title: "Boylston Hall", coordinate: CLLocationCoordinate2D(latitude: 42.373313, longitude: -71.117293), info: "Class Building"),
        Pins(title: "Wadsworth House", coordinate: CLLocationCoordinate2D(latitude: 42.373328, longitude: -71.118106), info: "Administration Building"),
        Pins(title: "Grays (Dorm)", coordinate: CLLocationCoordinate2D(latitude: 42.373663, longitude: -71.117816), info: "Freshman Dormitory"),
        Pins(title: "Weld (Dorm)", coordinate: CLLocationCoordinate2D(latitude: 42.373911, longitude: -71.117124), info: "Freshman Dormitory"),
        Pins(title: "Matthews Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374082, longitude: -71.118142), info: "Freshman Dormitory"),
        Pins(title: "John Harvard Statue", coordinate: CLLocationCoordinate2D(latitude: 42.374376, longitude: -71.115741), info: "Our claim to fame!"),
        Pins(title: "Harvard Bixi Statue", coordinate: CLLocationCoordinate2D(latitude: 42.373472, longitude: -71.117007), info: "Statue donated by Chinese Harvard alumni!"),
        Pins(title: "Massachusetts Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374450, longitude: -71.118281), info: "Where the President works!"),
        Pins(title: "Straus Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374145, longitude: -71.118592), info: "Freshman Dormitory"),
        Pins(title: "Lehman Dudley House", coordinate: CLLocationCoordinate2D(latitude: 42.373602, longitude: -71.118501), info: "Graduate School of Arts and Sciences building"),
        Pins(title: "University Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374446, longitude: -71.117047), info: "Main Administrativie Building"),
        Pins(title: "Thayer (Dorm)", coordinate: CLLocationCoordinate2D(latitude: 42.375041, longitude: -71.116752), info: "Freshman Dormitory"),
        Pins(title: "Hollis (Dorm)", coordinate: CLLocationCoordinate2D(latitude: 42.375025, longitude: -71.117841), info: "Freshman Dormitory"),
        Pins(title: "Stoughton (Dorm)", coordinate: CLLocationCoordinate2D(latitude: 42.375394, longitude: -71.117739), info: "Freshman Dormitory"),
        Pins(title: "Holworthy", coordinate: CLLocationCoordinate2D(latitude: 42.375520, longitude: -71.117219), info: "Freshman Dormitory"),
        Pins(title: "Memorial Church", coordinate: CLLocationCoordinate2D(latitude: 42.374913, longitude: -71.116031), info: "Main Church!"),
        Pins(title: "Canaday", coordinate: CLLocationCoordinate2D(latitude: 42.375346, longitude: -71.116130), info: "Freshman Dormitory"),
        Pins(title: "Sever Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374351, longitude: -71.115486), info: "Classroom Building"),
        Pins(title: "Emerson Hall", coordinate: CLLocationCoordinate2D(latitude: 42.373907, longitude: -71.115140), info: "Classroom Building"),
        Pins(title: "Lamont Library", coordinate: CLLocationCoordinate2D(latitude: 42.372810, longitude: -71.115476), info: "Library"),
        Pins(title: "Harvard Hall", coordinate: CLLocationCoordinate2D(latitude: 42.374851, longitude: -71.118190), info: "Classroom Building"),
        Pins(title: "Lionel Hall", coordinate: CLLocationCoordinate2D(latitude: 42.375104, longitude: -71.118351), info: "Freshman Dormitory"),
        Pins(title: "Science Center", coordinate: CLLocationCoordinate2D(latitude: 42.376162, longitude: -71.116484), info: "Center of Science"),
        Pins(title: "Annenberg Dining Hall", coordinate: CLLocationCoordinate2D(latitude: 42.375992, longitude: -71.115390), info: "Freshman Dining Hall"),
        Pins(title: "Sanders Theater", coordinate: CLLocationCoordinate2D(latitude: 42.375892, longitude: -71.114690), info: "Main Dining Hall"),
        Pins(title: "Museum of Natural History", coordinate: CLLocationCoordinate2D(latitude: 42.378389, longitude: -71.115529), info: "Cool Museum!"),
        Pins(title: "Maxwell Dworkin", coordinate: CLLocationCoordinate2D(latitude: 42.378790, longitude: -71.117278), info: "Engineering Building"),
        Pins(title: "Harvard Art Museums", coordinate: CLLocationCoordinate2D(latitude: 42.374154, longitude: -71.114239), info: "Self Explanatory ;)"),
        Pins(title: "Carpenter Center for Visual Arts", coordinate: CLLocationCoordinate2D(latitude: 42.373591, longitude: -71.114282), info: "Cinema Builing"),
        Pins(title: "Smith Campus Center", coordinate: CLLocationCoordinate2D(latitude: 42.372957, longitude: -71.118488), info: "Currently Under Construction!"),
        Pins(title: "Harvard Square", coordinate: CLLocationCoordinate2D(latitude: 42.373416, longitude: -71.119016), info: "T STOP"),
        Pins(title: "Malkin Athletic Center", coordinate: CLLocationCoordinate2D(latitude: 42.371462, longitude: -71.119359), info: "Student Gym"),
        Pins(title: "Eliot House", coordinate: CLLocationCoordinate2D(latitude: 42.370281, longitude: -71.121307), info: "Upperclassmen Dorm"),
        Pins(title: "Kirkland House", coordinate: CLLocationCoordinate2D(latitude: 42.370967, longitude: -71.120770), info: "Upperclassmen Dorm"),
        Pins(title: "Lowell House", coordinate: CLLocationCoordinate2D(latitude: 42.370817, longitude: -71.117962), info: "Upperclassmen Dorm"),
        Pins(title: "Kennedy School Library", coordinate: CLLocationCoordinate2D(latitude: 42.371026, longitude: -71.121861), info: "Government Library"),
        Pins(title: "The Harvard Lampoon", coordinate: CLLocationCoordinate2D(latitude: 42.371630, longitude: -71.117320), info: "Coolest Building in the Square!"),
        Pins(title: "Bureau of Study Council", coordinate: CLLocationCoordinate2D(latitude: 42.372571, longitude: -71.117413), info: "Academic Resources Building"),
        Pins(title: "Adams House", coordinate: CLLocationCoordinate2D(latitude: 42.371929, longitude: -71.116866), info: "Upperclassmen Dorm"),
        Pins(title: "Quincy House", coordinate: CLLocationCoordinate2D(latitude: 42.370713, longitude: -71.117039), info: "Upperclassmen Dorm"),
        Pins(title: "Winthrop House", coordinate: CLLocationCoordinate2D(latitude: 42.370341, longitude: -71.119341), info: "Upperclassmen Dorm"),
        Pins(title: "Leverett House", coordinate: CLLocationCoordinate2D(latitude: 42.370054, longitude: -71.117420), info: "Upperclassmen Dorm"),
        Pins(title: "Dunster House", coordinate: CLLocationCoordinate2D(latitude: 42.368684, longitude: -71.115924), info: "Upperclassmen Dorm"),
        Pins(title: "Mather House", coordinate: CLLocationCoordinate2D(latitude: 42.368410, longitude: -71.115307), info: "Upperclassmen Dorm"),
        Pins(title: "Cabot House", coordinate: CLLocationCoordinate2D(latitude: 42.381911, longitude: -71.123943), info: "Upperclassmen Dorm"),
        Pins(title: "Currier House", coordinate: CLLocationCoordinate2D(latitude: 42.381808, longitude: -71.125542), info: "Upperclassmen Dorm"),
        Pins(title: "Pforzheimer House", coordinate: CLLocationCoordinate2D(latitude: 42.382119, longitude: -71.124866), info: "Upperclassmen Dorm"),
        Pins(title: "The Student Organization Center at Hilles (SOCH)", coordinate: CLLocationCoordinate2D(latitude: 42.380891, longitude: -71.125070), info: "Student Orgaization Building."),
        Pins(title: "Porcellian Club", coordinate: CLLocationCoordinate2D(latitude: 42.372944, longitude: -71.117721), info: "Final Club"),
        Pins(title: "The Fly Club", coordinate: CLLocationCoordinate2D(latitude: 42.371485, longitude: -71.117814), info: "Final Club"),
        Pins(title: "The Owl Club", coordinate: CLLocationCoordinate2D(latitude: 42.371539, longitude: -71.118667), info: "Final Club"),
        Pins(title: "The A.D. Club", coordinate: CLLocationCoordinate2D(latitude: 42.372552, longitude: -71.116567), info: "Final Club"),
        Pins(title: "The Delphic Club", coordinate: CLLocationCoordinate2D(latitude: 42.372386, longitude: -71.117458), info: "Final Club"),

    ]

    
    // set up CLLocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get and save current location
        let location = locations[0]
        self.map.showsUserLocation = true
        curLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // update location
        locationManager.startUpdatingLocation()
        
        // initialize variables to hold two closest locations and distances
        var nearestLocation = Pins(title: String(), coordinate: CLLocationCoordinate2D(), info: String())
        var nearestLocation2 = Pins(title: String(), coordinate: CLLocationCoordinate2D(), info: String())
        var shortestDistance = minDistance
        var shortestDistance2 = minDistance

        // find two closest locations
        for pin in pins {
            let distance = curLocation.distance(from:CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude))
            if distance < shortestDistance {
                nearestLocation = pin
                shortestDistance = distance
            }
           else if distance < shortestDistance2 {
                nearestLocation2 = pin
                shortestDistance2 = distance
            }
        }
        
        // get name of two closest locations
        closestPlace = nearestLocation.title!
        closestPlace2 = nearestLocation2.title!
        
        // show button for closest locations and display if within minimum distance
        if shortestDistance != minDistance {
            button1.setTitle(nearestLocation.title! + " - More Info",for: .normal)
            button2.setTitle(nearestLocation2.title! + " - More Info",for: .normal)
            button1.isHidden = false
            button2.isHidden = false
        }
        else {
            button1.isHidden = true
            button2.isHidden = false
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide buttons by default
        button1.isHidden = true
        button1.isHidden = false
        
        // set up Location Manager
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        // add pins to map
        let lengthOfArray = pins.count
        for i in 0..<lengthOfArray {
            let pin = pins[i]
            map.addAnnotations([pin as MKAnnotation])
        }
    }
    
    // set up annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Pins"
        
        if annotation is Pins {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {

                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            }
            else {

                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        return nil
    }
    
    // show pop-up annotation on click
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let Pins = view.annotation as! Pins
        let placeName = Pins.title
        let placeInfo = Pins.info
        placeLable = placeName!

        // add alert on click of annotaion
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Click for More Information", style: .default) { (_) -> Void in
            self.performSegue(withIdentifier: "moreInfo", sender: nil)
        })
        ac.addAction(UIAlertAction(title: "No Thanks :(", style: .default))

        present(ac, animated: true)
    }
    
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Alert", message: "Location services were previously denied. Please enable location services for this app in Settings.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
        // save initial location
        let initLocation = CLLocationCoordinate2DMake(curLocation.coordinate.latitude, curLocation.coordinate.longitude)
        
        // begin with camera tilted
        let mapCamera = MKMapCamera(lookingAtCenter: initLocation, fromDistance: 800.0, pitch: 45.0, heading: 0.0)
        map.setCamera(mapCamera, animated: false)

    }
    
    // pass building name to info page based on button clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfo" {
            let secondVC = segue.destination as! infoVC
            secondVC.passedData = placeLable
        }
    }
    
    // show search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
        }
    }
    
}
