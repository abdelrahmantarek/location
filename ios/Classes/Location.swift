//
//  Location.swift
//  low_calories_google_map
//
//  Created by Abdo on 27/09/2021.
//

import Foundation



import Foundation
import Flutter
import UIKit
import CoreLocation


class Location : NSObject, CLLocationManagerDelegate{
    
    
    var locationManager:CLLocationManager = CLLocationManager()
    var resultAskPermisionLocation:FlutterResult!
    var resultAskGps:FlutterResult!
    var resultGetLocation:FlutterResult!
    
    
    override init(){
        super.init()
        locationManager.delegate = self
    }
    
    // ask ---------- status
    func getLocationStatus(_ result:FlutterResult){
        if CLLocationManager.locationServicesEnabled() {
                result(true)
            } else {
                result(false)
        }
    }
    
    // ask ---------- status
    func getLocationStatusPermission(_ result:FlutterResult){
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                result(false)
            case .authorizedAlways, .authorizedWhenInUse:
                result(true)
            @unknown default:
                result(false)
        }
    }
    
    
    // request ----------
    func requestOpenGps(_ result:FlutterResult?){
        self.resultAskGps = result
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                if UIApplication.shared.canOpenURL(url){
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // request ----------
    func requestLocationPermission(_ result:FlutterResult?){
        self.resultAskPermisionLocation = result
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    // get ---------- status
    func getLocation(_ result:FlutterResult?){
        self.resultGetLocation = result
        self.locationManager.startUpdatingLocation()
    }

     func openSettingsLocationPermissionIos(){
        //Redirect to Settings app
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        } else {
            UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
        }
   }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        if(self.resultGetLocation != nil){
            locationManager.stopUpdatingLocation();
            print("user latitude = \(userLocation.coordinate.latitude)")
            print("user longitude = \(userLocation.coordinate.longitude)")
            self.resultGetLocation([userLocation.coordinate.latitude,userLocation.coordinate.longitude])
            self.resultGetLocation = nil
        }
    }
    
    
    // listener ---------- status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status.rawValue)
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                if(self.resultAskPermisionLocation != nil){
                    self.resultAskPermisionLocation(false)
                    self.resultAskPermisionLocation = nil
                }
                if(self.resultAskGps != nil){
                    self.resultAskGps(CLLocationManager.locationServicesEnabled())
                    self.resultAskGps = nil
                }
            case .authorizedAlways, .authorizedWhenInUse:
                if(self.resultAskPermisionLocation != nil){
                    self.resultAskPermisionLocation(true)
                    self.resultAskPermisionLocation = nil
                }
                if(self.resultAskGps != nil){
                    self.resultAskGps(CLLocationManager.locationServicesEnabled())
                    self.resultAskGps = nil
                }
                
            @unknown default:
                if(self.resultAskPermisionLocation != nil){
                    self.resultAskPermisionLocation(false)
                    self.resultAskPermisionLocation = nil
                }
                if(self.resultAskGps != nil){
                    self.resultAskGps(CLLocationManager.locationServicesEnabled())
                    self.resultAskGps = nil
                }
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
              print("Error while updating location " + error.localizedDescription)
    }
    
}




