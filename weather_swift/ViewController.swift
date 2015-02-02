//
//  ViewController.swift
//  weather_swift
//
//  Created by wangxiaoliang on 15-1-26.
//  Copyright (c) 2015年 wangxiaoliang. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON


class ViewController: UIViewController,CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var time4: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var temp1: UILabel!
    @IBOutlet weak var temp2: UILabel!
    @IBOutlet weak var temp3: UILabel!
    @IBOutlet weak var temp4: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        //精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.loadingIndicator.startAnimating()
        
        let background = UIImage(named: "background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        //添加手势
        self.view.addGestureRecognizer(singleFingerTap)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func handleSingleTap(recognizer:UITapGestureRecognizer){
        locationManager.startUpdatingLocation()
        self.loadingIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //请求
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat":latitude,"lon":longitude]
        println(params)
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { (request, response, json, error)  in
            if error != nil{
                println("Error:\(error)")
                println(request)
                println(response)
                self.loading.text = "Internet appears down!"
            }
            else{
                println("Success:\(url)")
                println(request)
                var json = JSON(json!)
                
                self.updateUISuccess(json)
            }
        }
    }
    
    func updateUISuccess(json:JSON){
        self.loading.text = nil
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        
        //let
        
        if let tempResult = json["list"][0]["main"]["temp"].double{
            //Get country
            let country = json["city"]["country"].stringValue
            
            //Get and convert temperature
            var temperature = self.convertTemperature(country, temperature: tempResult)
        
            self.temperature.text = "\(temperature)°"
            
            //Get city name
            self.location.text = json["city"]["name"].stringValue
            
            //Get and set icon
            let weather = json["list"][0]["weather"][0]
            let condition = weather["id"].intValue
            var icon = weather["icon"].stringValue
            
            var nightTime = self.isNightTime(icon)
            self.updateWeatherIcon(condition, nightTime: nightTime, index: 0, callback: self.updatePictures)
            
            //Get forecast
            for index in 1...4{
                println(json["list"][index])
                if let newtempResult = json["list"][index]["main"]["temp"].double{
                    //Get and convert temperature
                    var newtemperature = self.convertTemperature(country, temperature: newtempResult)
                    if index == 1{
                        self.temp1.text = "\(newtemperature)°"
                    }
                    else if index == 2{
                        self.temp2.text = "\(newtemperature)°"
                    }
                    else if index == 3{
                        self.temp3.text = "\(newtemperature)°"
                    }
                    else if index == 4{
                        self.temp4.text = "\(newtemperature)°"
                    }
                    
                    //Get forecast time
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    let rawDate = json["list"][index]["dt"].doubleValue
                    let date = NSDate(timeIntervalSince1970: rawDate)
                    let forecastTime = dateFormatter.stringFromDate(date)
                    
                    if index == 1{
                        self.time1.text = forecastTime
                    }
                    else if index == 2{
                        self.time2.text = forecastTime
                    }
                    else if index == 3{
                        self.time3.text = forecastTime
                    }
                    else if index == 4{
                        self.time4.text = forecastTime
                    }
                    
                    //Get and set icon
                    let newWeather = json["list"][index]["weather"][0]
                    let newCondition = newWeather["id"].intValue
                    let newIcon = newWeather["icon"].stringValue
                    var newNightTime = self.isNightTime(newIcon)
                    self.updateWeatherIcon(newCondition, nightTime: newNightTime, index: index, callback: self.updatePictures)
                }
                else{
                    continue
                }
            }
        }else
        {
            self.loading.text = "Weather info is not available!"
        }
    }
    
    func isNightTime(icon: String)->Bool {
        return icon.rangeOfString("n") != nil
    }
    
    func convertTemperature(country: String, temperature: Double)->Double{
        if (country == "US") {
            // Convert temperature to Fahrenheit if user is within the US
            return round(((temperature - 273.15) * 1.8) + 32)
        }
        else {
            // Otherwise, convert temperature to Celsius
            return round(temperature - 273.15)
        }
    }

    
    func updateWeatherIcon(condition: Int, nightTime: Bool, index: Int, callback:(index: Int, name: String)->()) {
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                callback(index: index, name: "tstorm1_night")
            } else {
                callback(index: index, name: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            callback(index: index, name: "light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            callback(index: index, name: "shower3")
        }
            // Snow
        else if (condition < 700) {
            callback(index: index, name: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                callback(index: index, name: "fog_night")
            } else {
                callback(index: index, name: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            callback(index: index, name: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                callback(index: index, name: "sunny_night")
            }
            else {
                callback(index: index, name: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                callback(index: index, name: "cloudy2_night")
            }
            else{
                callback(index: index, name: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            callback(index: index, name: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            callback(index: index, name: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            callback(index: index, name: "snow5")
        }
            // Hot
        else if (condition == 904) {
            callback(index: index, name: "sunny")
        }
            // Weather condition is not available
        else {
            callback(index: index, name: "dunno")
        }
    }

    
    
    func updatePictures(index: Int, name: String) {
        if (index==0) {
            self.icon.image = UIImage(named: name)
        }
        if (index==1) {
            self.image1.image = UIImage(named: name)
        }
        if (index==2) {
            self.image2.image = UIImage(named: name)
        }
        if (index==3) {
            self.image3.image = UIImage(named: name)
        }
        if (index==4) {
            self.image4.image = UIImage(named: name)
        }
    }
    
    //MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if location.horizontalAccuracy > 0{
            self.locationManager.stopUpdatingLocation()
            println("lat = \(location.coordinate.latitude),lon = \(location.coordinate.longitude)")
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.loading.text = "Can't get your location!"
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }


}

