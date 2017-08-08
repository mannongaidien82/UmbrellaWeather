//
//  SupportTableViewController.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/1/23.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit
import StoreKit

protocol SupportTableViewControllerDelegate: class{
  func supportTableViewController(_ controller: SupportTableViewController)
}


class SupportTableViewController: UITableViewController,SKPaymentTransactionObserver,SKProductsRequestDelegate {
  
  @IBOutlet weak var loadingImageView: UIImageView!
  @IBOutlet weak var row1ImageView: UIImageView!
  @IBOutlet weak var row2ImageView: UIImageView!
  @IBOutlet weak var row3ImageView: UIImageView!
  @IBOutlet weak var row1WidthCon: NSLayoutConstraint!
  @IBOutlet weak var row2WidthCon: NSLayoutConstraint!
  @IBOutlet weak var row3WidthCon: NSLayoutConstraint!
  
  weak var delegate:SupportTableViewControllerDelegate?
  var request: SKProductsRequest!
  var requestPay = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
      SKPaymentQueue.default().add(self)
    }
  
  deinit{
    if requestPay{
      request.delegate = nil
    }
    SKPaymentQueue.default().remove(self)
  }
  
  
  
  func requestProducts(_ pid: String){
    let set: Set<String> = [pid]
    request = SKProductsRequest(productIdentifiers: set)
    request.delegate = self
    request.start()
    requestPay = true
  }
  
  
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    buyProduct(response.products[0])
  }
  
  func buyProduct(_ product: SKProduct){
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
    print("请求线程购买")
  }
  
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    for transaction in transactions {
      print("队列状态变化 \(transaction.payment.productIdentifier)==\(transaction.transactionState.rawValue))")
      switch transaction.transactionState {
      case .purchasing:
        print("商品添加进列表 \(transaction.payment.productIdentifier)")
      case .purchased:
        switch transaction.payment.productIdentifier{
        case "UmbrellaWeather_1":
          row1WidthCon.constant = 0
          hiddenLoadingImageView(row1ImageView)
        case "UmbrellaWeather_6":
          row2WidthCon.constant = 0
          hiddenLoadingImageView(row2ImageView)
        case "UmbrellaWeather_18":
          row3WidthCon.constant = 0
          hiddenLoadingImageView(row3ImageView)
        default:
          break
        }
        self.finishTransaction(transaction)
      case .failed:
        //myedit if transaction.error?.code == 0{
          showAlert("感谢你的支持,无法连接到 iTunes Store,请稍后重试")
        //}
        switch transaction.payment.productIdentifier{
        case "UmbrellaWeather_1":
          row1WidthCon.constant = 0
          hiddenLoadingImageView(row1ImageView)
        case "UmbrellaWeather_6":
          row2WidthCon.constant = 0
          hiddenLoadingImageView(row2ImageView)
        case "UmbrellaWeather_18":
          row3WidthCon.constant = 0
          hiddenLoadingImageView(row3ImageView)
        default:
          break
        }
        print("交易失败error==\(String(describing: transaction.error))")
        self.finishTransaction(transaction)
      case .restored:
        print("已经购买过商品")
        self.finishTransaction(transaction)
      case .deferred:
        print("Allow the user to continue using your app.")
        break
      }
    }
  }
  
  
  func finishTransaction(_ transaction:SKPaymentTransaction) {
    // 将交易从交易队列中删除
    SKPaymentQueue.default().finishTransaction(transaction)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch (indexPath.section,indexPath.row){
      
    case (1,0):
    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id" + "1079751819")!)
    case (2,0):
      requestProducts("UmbrellaWeather_1")
      row1WidthCon.constant = row1ImageView.bounds.height
      loadingAnimation(row1ImageView)
    case (2,1):
      requestProducts("UmbrellaWeather_6")
      row2WidthCon.constant = row2ImageView.bounds.height
      loadingAnimation(row2ImageView)
    case (2,2):
      requestProducts("UmbrellaWeather_18")
      row3WidthCon.constant = row3ImageView.bounds.height
      loadingAnimation(row3ImageView)
    default:
      return
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func hiddenLoadingImageView(_ imageView: UIImageView){
    imageView.layer.removeAllAnimations()
    imageView.isHidden = true
  }
  
  func showAlert(_ message: String){
    let alert = UIAlertController(title: "加载错误", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction(title: "好的", style: UIAlertActionStyle.cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)

  }
  
  
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let offSety = scrollView.contentOffset.y
    
    if offSety < -50 && decelerate{
      delegate?.supportTableViewController(self)
    }
  }

}
