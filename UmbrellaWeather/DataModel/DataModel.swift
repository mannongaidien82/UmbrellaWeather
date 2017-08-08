//
//  DataModel.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 16/1/3.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit

class DataModel{
  var currentCity = ""
  var dueString = "__ : __"
  var shouldRemind = false
  var cities = [City]()
//  var dailyResults = [DailyResult]()
  var weatherResult = WeatherResult()
  
  init(){
    handleFirstTime()
    loadData()
  }
  
  func scheduleNotification(){
    
    removeLocalNotification()
    
    if shouldRemind && currentCity != ""{
    
      let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-ddHH:mm"
   
      for dailyResult in weatherResult.dailyResults{
        
        let dateString = dailyResult.dailyDate
        let pop = dailyResult.dailyPop
     
        let stringFormTime = dateString + dueString
       
        guard let notificationTime = formatter.date(from: stringFormTime) else{ return }
       
      if pop >= 10 && notificationTime.compare(Date()) != .orderedAscending{
        
        let localNotification = UILocalNotification()
        localNotification.timeZone = TimeZone.current
        localNotification.soundName = "WaterSound.wav"
        let alertBody = "\(dateString) \(dailyResult.dailyState) 今天下雨几率为 \(pop) 记得带伞☂"
        localNotification.fireDate = notificationTime
        localNotification.alertBody = alertBody
        UIApplication.shared.scheduleLocalNotification(localNotification)
      }
    }
      guard let dataString = weatherResult.dailyResults.last?.dailyDate else{
        return
      }
      let localNotification = UILocalNotification()
      let dueTime = formatter.date(from: dataString + dueString)
      localNotification.timeZone = TimeZone.current
      localNotification.soundName = "WaterSound.wav"
      localNotification.fireDate = dueTime!.addingTimeInterval(30)
      localNotification.alertBody = "你已经一周没有打开过软件,提醒通知将取消"
      UIApplication.shared.scheduleLocalNotification(localNotification)
    }
  }
  
  fileprivate func removeLocalNotification(){
    let allNotifications = UIApplication.shared.scheduledLocalNotifications
    if let allNotifications = allNotifications, !allNotifications.isEmpty{
      UIApplication.shared.cancelAllLocalNotifications()
    }
  }
  
  func appendCity(_ city:City){
    for thisCity in cities{
      if thisCity.cityCN == city.cityCN{
        return
      }
    }
    cities.append(city)
  }
  
  
  fileprivate func documentsDirectory() -> String{
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return paths[0]
  }
  
  fileprivate func dataFilePath() -> String{
    return (documentsDirectory() as NSString).appendingPathComponent("DataModel.plist")
  }
  
  func saveData(){
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(currentCity, forKey: "CurrentCity")
    archiver.encode(dueString, forKey: "DueString")
    archiver.encode(shouldRemind, forKey: "ShouldRemind")
    archiver.encode(cities, forKey: "Cities")
    archiver.encode(weatherResult.dailyResults, forKey: "DailyResults")
    archiver.finishEncoding()
    data.write(toFile: dataFilePath(), atomically: true)
    scheduleNotification()
  }
  
  func loadData(){
    let path = dataFilePath()
    if FileManager.default.fileExists(atPath: path){
      if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        currentCity = unarchiver.decodeObject(forKey: "CurrentCity") as! String
        dueString = unarchiver.decodeObject(forKey: "DueString") as! String
        shouldRemind = unarchiver.decodeBool(forKey: "ShouldRemind")
        cities = unarchiver.decodeObject(forKey: "Cities") as! [City]
        weatherResult.dailyResults = unarchiver.decodeObject(forKey: "DailyResults") as! [DailyResult]
        unarchiver.finishDecoding()
      }
    }
  }
  
  //上线的新版本改变了数据结构
  func handleFirstTime(){
    let userDefaults = UserDefaults.standard
    userDefaults.register(defaults: ["FirstTime":true])
    userDefaults.register(defaults: ["IsOldData":true])
    
    let isOldData = userDefaults.bool(forKey: "IsOldData")
    if isOldData{
     let fileMager = FileManager()
      do{
      try fileMager.removeItem(atPath: dataFilePath())
      }catch{
        print("FirstTime")
      }
      userDefaults.set(false, forKey: "IsOldData")
      userDefaults.synchronize()
    }
  }
  
}
