//
//  Location.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 16/1/4.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit
import CoreLocation



class LocationService: NSObject,CLLocationManagerDelegate{
  
  
  var updatingLocation = false
  var parserXML:ParserXML?
   let geocoder = CLGeocoder()
  
  static let sharedManager = LocationService()
  
  enum LocationStatus{
    case loading
    case result(String)
    case normal
  }
  
  class func startLocation() {
    if CLLocationManager.locationServicesEnabled() {
      self.sharedManager.locationManager.startUpdatingLocation()
    }
  }
  
  
  var afterUpdatedCityAction: ((Bool) -> Void)?
  
  fileprivate(set) var locationStatus: LocationStatus = .normal
  

  
  lazy var locationManager: CLLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    return locationManager
  }()
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    if status == .denied {
      NotificationCenter.default.post(name: Notification.Name(rawValue: "Location_Denied"), object: nil)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   guard let newLocation = locations.last else{
      return
    }
    locationManager.stopUpdatingLocation()

    
    geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) -> Void in
      var sucess = false
      self.locationStatus = .loading
      if error != nil{
        
      }else if let p = placemarks, !p.isEmpty{
   
        if let locality = p.last?.locality{
          self.parserXML = ParserXML()
          let cityName = self.parserXML!.rangeOfLocation(locality)
          sucess = true
          self.locationStatus = .result(cityName)
          self.parserXML = nil
        }
      }
      self.afterUpdatedCityAction?(sucess)
    }
  }
}
