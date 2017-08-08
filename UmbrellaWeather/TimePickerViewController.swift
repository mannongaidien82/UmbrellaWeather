//
//  TimePickerViewController.swift
//  UmberellaWeather
//
//  Created by ZeroJianMBP on 15/12/27.
//  Copyright © 2015年 ZeroJian. All rights reserved.
//

import UIKit

protocol TimePickerViewControllerDelegate: class{
  func timePickerViewControllerDidSelect(_ controller: TimePickerViewController, didSelectTime time: String)
  func timePickerViewControllerDidCancel(_ controller: TimePickerViewController)
  }

class TimePickerViewController: UIViewController {
  @IBOutlet weak var datePicker: UIDatePicker!

  weak var delegate: TimePickerViewControllerDelegate?

  
  @IBAction func cancel(_ sender: AnyObject) {
    delegate?.timePickerViewControllerDidCancel(self)
  }
  
  @IBAction func done(_ sender: AnyObject) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let dateString = formatter.string(from: datePicker.date)
    
    delegate?.timePickerViewControllerDidSelect(self, didSelectTime: dateString)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .custom
    transitioningDelegate = self
  }
}

extension TimePickerViewController: UIViewControllerTransitioningDelegate{
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
}
