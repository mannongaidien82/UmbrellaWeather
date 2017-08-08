//
//  PullViewController.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/1/24.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PullView: UIView {
  

  @IBOutlet weak var remindLabel: UILabel!
  @IBOutlet weak var lineImage: UIImageView!
  @IBOutlet weak var lineXConstraion: NSLayoutConstraint!
  @IBOutlet weak var topHeightConstraion: NSLayoutConstraint!
  @IBOutlet weak var buttonHeightConstraion: NSLayoutConstraint!
  
  
  var shoudRemind: Bool! {
    willSet {
      if newValue == true {
        remindString = "释放更换通知时间"
        if offsetY <= -100 {
          remindLabel.text = "释放取消通知"
          remindLabel.textColor = UIColor.GreenBlue()
          animationWithColor(self, color: UIColor.shallowBlack())
        }
      }else if newValue == false {
        remindString = "释放激活下雨通知"
      }
    }
  }
  
  var endDragging: Bool? {
    willSet{
      hiddenView()
    }
  }
  
  var remindString: String!
  
  var offsetY: CGFloat! {
    willSet {
      if newValue < -30 {
        lineAnimation()
        topHeightConstraion.constant = abs(newValue)
        self.isHidden = false
        if newValue <= -60 && newValue > -100 {
          viewDidScroll("↓下拉设置通知", alpha: 0.04 * (abs(newValue) - 60))
          animationWithColor(self,color:UIColor.GreenBlue())
          if newValue < -85 {
            viewDidScroll(remindString, alpha: 1)
          }
        }
      } else {
          if !self.isHidden {
            hiddenView()
          }
        }
      }
    }

  func viewDidScroll(_ labelText: String!,alpha: CGFloat){
    remindLabel.isHidden = false
    remindLabel.text = labelText
    remindLabel.textColor = UIColor.white
    remindLabel.alpha = alpha
  }
  
  
  func lineAnimation(){
    lineImage.isHidden = false
    lineXConstraion.constant = self.bounds.width
    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: nil)
  }
  
  
  func hiddenView(){
    self.isHidden = true
    remindLabel.isHidden = true
    remindLabel.alpha = 0
    lineImage.isHidden = true
    topHeightConstraion.constant = 0
    self.backgroundColor = UIColor.shallowBlack()
    lineXConstraion.constant -= lineImage.bounds.width
  }
 
}
