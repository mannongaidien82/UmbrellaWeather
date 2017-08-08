//
//  ServiceResult.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 15/12/21.
//  Copyright © 2015年 ZeroJian. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ResultComplete = (Bool) -> Void

class ServiceResult {
  
  enum State{
    case loading
    case noRequest
    case nonsupportCity
    case noYet
    case results(WeatherResult)
  }
  
 
  fileprivate(set) var state: State = .noYet
  fileprivate var dataTask: URLSessionDataTask? = nil
  
  func performResult(_ cityName: String,completion: @escaping ResultComplete){
    if !cityName.isEmpty{
      
      dataTask?.cancel()
      state = .loading
      
    let url = citySearchText(cityName)
    let session = URLSession.shared
    dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
      var success = false
        if error != nil {//&& error?.code == -999{
        print(error ?? "error nil")
        return
      }
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 ,let data = data{
        success = true
        let dictionary = self.parseJSON(data)
        let weatherResult = self.parseDictionary(dictionary)
        if weatherResult.ServiceStatus == "no more requests"{
          self.state = .noRequest
        }else if weatherResult.ServiceStatus == "unknown city"{
          self.state = .nonsupportCity
        }else{
        self.state = .results(weatherResult)
        }
        
      }
      DispatchQueue.main.async(execute: {
        completion(success)
      })
    }) 
    dataTask?.resume()
    }
  }
  
  func fetchDailyResults(_ cityName: String,completion: (([DailyResult]) -> Void)?){
    
    if !cityName.isEmpty{
      
      let url = citySearchText(cityName)
      let session = URLSession.shared
      let dateTask = session.dataTask(with: url, completionHandler: { (data, response, error)
        in
        if error != nil{
          return
        }
        if let data = data{
          let dictionary = self.parseJSON(data)
          let dailyResults =  self.parseWithDairyResults(dictionary)
          completion?(dailyResults)
        }
      }) 
      dateTask.resume()
    }
  }
  
  
  fileprivate func citySearchText(_ searchText: String) -> URL{
    
    //api 每天免费请求次数3000,如果超过请求次数请自行注册
    //和风天气网址: http://www.heweather.com
    //mykey 
    let apiKeyTest = "7cded2970e40453dbb083cd3f38facc0"
    //let apiKeyTest = "cf386feb168149f4a45eb87d4f4b647f"
    
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let urlString = String(format: "https://api.heweather.com/x3/weather?city=%@&key="+apiKeyTest,escapedSearchText)
    let url = URL(string: urlString)
    return url!
  }
  
  fileprivate func parseJSON(_ data: Data) -> JSON{
    return JSON(data: data)
  }
  
  fileprivate func parseDictionary(_ dictionary: JSON) -> WeatherResult{
    let weatherResult = WeatherResult()
    let json = dictionary["HeWeather data service 3.0"][0]
    if let ServiceState = json["status"].string{
      weatherResult.ServiceStatus = ServiceState
    }
    
    if let jsonCity = json["basic"]["city"].string{
      weatherResult.city = jsonCity
    }
    if let state = json["now"]["cond"]["txt"].string{
      weatherResult.state = state
    }
    if let stateCode = json["now"]["cond"]["code"].string{
      weatherResult.stateCode = Int(stateCode)!
    }
  
    let dailyArrays = json["daily_forecast"]
    let dailyDayTmp = dailyArrays[0]["tmp"]
    if let pop = dailyArrays[0]["pop"].string{
      weatherResult.dayRain = pop
    }
    if let dayTemMax = dailyDayTmp["max"].string{
      weatherResult.dayTemMax = dayTemMax + "˚"
    }
    if let dayTmpMin = dailyDayTmp["min"].string{
    weatherResult.dayTmpMin = dayTmpMin + "˚"
    }
    
    for (_,subJson):(String, JSON) in json["daily_forecast"]{
      let dailyResult = DailyResult()
      
      if let dates = subJson["date"].string{
        dailyResult.dailyDate = dates
      }
      if let pop = subJson["pop"].string{
        dailyResult.dailyPop = Int(pop)!
      }
      if let tmpsMax = subJson["tmp"]["max"].string{
        dailyResult.dailyTmpMax = tmpsMax + "˚"
      }
      if let tmpsMin = subJson["tmp"]["min"].string{
        dailyResult.dailyTmpMin = tmpsMin + "˚"
      }
      if let conds = subJson["cond"]["txt_d"].string{
        dailyResult.dailyState = conds
      }
      if let stateCode = subJson["cond"]["code_d"].string{
        dailyResult.dailyStateCode = Int(stateCode)!
      }
      weatherResult.dailyResults.append(dailyResult)
    }
    return weatherResult
  }
  
  fileprivate func parseWithDairyResults(_ dictionary: JSON) -> [DailyResult]{
    var dailyResults = [DailyResult]()
    let json = dictionary["HeWeather data service 3.0"][0]
    for (_,subJson):(String, JSON) in json["daily_forecast"]{
      let dailyResult = DailyResult()
      if let dates = subJson["date"].string{
        dailyResult.dailyDate = dates
      }
      if let pop = subJson["pop"].string{
        dailyResult.dailyPop = Int(pop)!
      }
      if let tmpsMax = subJson["tmp"]["max"].string{
        dailyResult.dailyTmpMax = tmpsMax + "˚"
      }
      if let tmpsMin = subJson["tmp"]["min"].string{
        dailyResult.dailyTmpMin = tmpsMin + "˚"
      }
      if let conds = subJson["cond"]["txt_d"].string{
        dailyResult.dailyState = conds
      }
      if let stateCode = subJson["cond"]["code_d"].string{
        dailyResult.dailyStateCode = Int(stateCode)!
      }
      dailyResults.append(dailyResult)
    }
    return dailyResults
  }

}
  
