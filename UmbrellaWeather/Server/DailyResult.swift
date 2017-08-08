//
//  ArrayWeatherResult.swift
//  Umbrella Weather
//
//  Created by ZeroJianMBP on 15/12/17.
//  Copyright © 2015年 ZeroJian. All rights reserved.
//

import Foundation

class DailyResult: NSObject,NSCoding{
  var dailyTmpMax = ""
  var dailyTmpMin = ""
  var dailyState = ""
  var dailyDate = ""
  var dailyPop = 0
  var dailyStateCode = 0
  
  
  override init() {
    super.init()
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    dailyTmpMax = aDecoder.decodeObject(forKey: "DailyTmpMax") as! String
    dailyTmpMin = aDecoder.decodeObject(forKey: "DailyTmpMin") as! String
    dailyState = aDecoder.decodeObject(forKey: "DailyState") as! String
    dailyDate = aDecoder.decodeObject(forKey: "DailyDate") as! String
    dailyPop = aDecoder.decodeInteger(forKey: "DailyPop")
    dailyStateCode = aDecoder.decodeInteger(forKey: "DailyStateCode")
    super.init()
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(dailyTmpMax, forKey: "DailyTmpMax")
    aCoder.encode(dailyTmpMin, forKey: "DailyTmpMin")
    aCoder.encode(dailyState, forKey: "DailyState")
    aCoder.encode(dailyDate, forKey: "DailyDate")
    aCoder.encode(dailyPop, forKey: "DailyPop")
    aCoder.encode(dailyStateCode, forKey: "DailyStateCode")
  }
}
