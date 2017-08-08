//
//  HeadView.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/5/4.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class HeadView: UIView {
  
  @IBOutlet weak var detailButton: UIButton!
  @IBOutlet weak var cityButton: UIButton!
  @IBOutlet weak var dateView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  
  
  var timeString: String!
  
  var endDragging: Bool? {
    willSet{
        dateView.backgroundColor = UIColor.shallowBlack()
      if dateString != nil {
          dateLabel.text = dateString
        }
      }
  }
  
  var dateString: String!
  
  var shoudRemind: Bool! {
    willSet {
      springAnimation1(dateView)
      dateView.backgroundColor = UIColor.rainColor()
      dateLabel.text = timeString
      remindStatus = newValue
    if newValue == true {
      detailButton.setBackgroundImage(UIImage(named: "DetailColor"), for: UIControlState())
    } else if newValue == false {
       detailButton.setBackgroundImage(UIImage(named: "Detail"), for: UIControlState())
      }
    }
  }
  
  var remindStatus: Bool!
  
  var offsetY: CGFloat! {
    willSet {
      if newValue <= -60 {
        dateLabel.text = timeString
        dateView.backgroundColor = self.tintColor
        if remindStatus == true && newValue <= -100 {
          dateLabel.text = timeString
          dateView.backgroundColor = UIColor.shallowBlack()
        }
      } else {
        if dateString != "" {
          dateLabel.text = dateString
        }
        dateView.backgroundColor = UIColor.shallowBlack()
      }
    }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  func initialTextString() {
    cityButton.titleLabel?.text = "   "
    cityButton.setTitle("   ", for: UIControlState())
    dateLabel.text = ""
  }
  
  func updateUI(_ cityName: String!) {
    cityButton.setTitle(cityName, for: UIControlState())
    
    if dateString != nil {
      dateLabel.text = dateString
    } else {
    let currentdate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let  convertedDate = dateFormatter.string(from: currentdate)
    dateLabel.text = convertedDate
    dateString = convertedDate
    }
  }
  
  @IBAction func headButton() {
    print("head button tap")
  }

}
