//
//  WeatherManager.swift
//  Clima
//
//  Created by Wangie on 23/12/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherurl = "https://api.openweathermap.org/data/2.5/weather?appid=9ccfecc5470aa522bc3d880ed1f640df&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherurl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        //let lat = String(format: "%0.1f", latitude)
        //let lon = String(format: "%0.1f", longitude)
        // print("lat is \(lat), and long is \(lon)")
        let urlString =  "\(weatherurl)&lat=\(latitude)&lon=\(longitude)"
        // print(urlString)
        performRequest(with: urlString)
    }

    
    func performRequest(with UrlString: String){
        //1. Create a URL
        if let url = URL(string: UrlString) {
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. start the task
            task.resume()
        }
        
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodeData.name
            print("city is \(decodeData.name)")
            
            let temp = decodeData.main.temp
            print("temp is \(decodeData.main.temp)")
            
            let description = decodeData.weather[0].description
            print("weather is \(decodeData.weather[0].description)")
            
            let id = decodeData.weather[0].id
            print("id is \(decodeData.weather[0].id)")
        
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, description: description)
            print(weather.conditionName)
            print("temperatur in string is \(weather.temparatureString)")
            return (weather)
        }
        catch {
            delegate?.didFailWithError(error: error)
            return (nil)
        }
    }
    
    
}
