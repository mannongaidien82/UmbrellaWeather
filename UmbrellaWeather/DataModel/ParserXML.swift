//
//  ParserXML.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 16/1/1.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import Foundation

class ParserXML: NSObject,XMLParserDelegate{
  
  fileprivate var elementName = ""
  var cities = [City]()
  
  override init(){
    super.init()
    parseXMLResource()
  }
  
  fileprivate func parseXMLResource(){
    let parser = XMLParser(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Citys", ofType: "xml")!))
    if let parser = parser{
      parser.delegate = self
      parser.parse()
    }
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    self.elementName = elementName
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    if elementName == "city"{
      let city = City()
//      print("xml 解析完成")
      city.cityCN = str
      cities.append(city)
    }
  }
  
  func rangeOfLocation(_ placemark: String) -> String {
    var cityName: String!
    let p = placemark.lowercased()
    for (_ , value) in cities.enumerated(){
      if p.range(of: value.cityCN) != nil{
        cityName =  value.cityCN
        break
      } else {
        cityName = placemark
      }
    }
    return cityName
  }
}
