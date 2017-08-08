//
//  AppDelegate.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/1/7.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var dataModel = DataModel()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let controller = self.window?.rootViewController as! HomeViewController
    controller.dataModel = dataModel
   
   UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(3600 * 12))
  
    return true
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let serviceResult = ServiceResult()
    serviceResult.fetchDailyResults(dataModel.currentCity) { [weak self] dailyResults  in
      self?.dataModel.weatherResult.dailyResults = dailyResults
      self?.dataModel.saveData()
      completionHandler(.newData)
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    saveData()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    let serviceResult = ServiceResult()
    serviceResult.fetchDailyResults(dataModel.currentCity) { [weak self] dailyResults  in
      self?.dataModel.weatherResult.dailyResults = dailyResults
    }
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    
  }

  func applicationWillTerminate(_ application: UIApplication) {
    saveData()
  }
  
  func saveData(){
    dataModel.saveData()
  }
  
}

