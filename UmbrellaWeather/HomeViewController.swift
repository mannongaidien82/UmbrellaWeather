//
//  HomeViewController.swift
//  UmbrellaWeather
//
//  Created by ZeroJianMBP on 16/1/21.
//  Copyright © 2016年 ZeroJian. All rights reserved.
//

import UIKit
import AudioToolbox

class HomeViewController: UIViewController,TimePickerViewControllerDelegate,SupportTableViewControllerDelegate,CityListViewControllerDelegate,HomeViewDelegate{

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var homeView: HomeView!
  
  var serviceResult = ServiceResult()
  var dataModel: DataModel!
  var observer: AnyObject!
  var buttonClicked = false
  var soundID: SystemSoundID = 0
  
  override func viewDidLoad() {
        super.viewDidLoad()
    loadSoundEffect("WaterSound.wav")
    launchAnimation(self.view) { (finishion) in
      if finishion{
        self.handleFirstTime()
      }
    }
    homeView.showRemindStatus(withTimeString:dataModel.dueString, remind: dataModel.shouldRemind)
    homeView.delegate = self
    listenForLocation()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    homeView.initialUI()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func location() {
    
    buttonClicked = true
    
    updateWeatherResult()
  }

  func updateWeatherResult(){
    homeView.initialUI()
    
    if dataModel.currentCity == "" || buttonClicked == true{
      buttonClicked = false
      locationCity()
    }else{
      perforRequest()
    }
  }
  
  func listenForLocation() {
    observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Location_Denied"), object: nil, queue: OperationQueue.main, using: { [weak self](_) in
      self?.showAlert("没有打开定位服务请在设置中打开定位或上拉搜索选择城市", "好的", againReuqest:  false, shouldRemind: false)
      })
  }
  
  deinit {
    NotificationCenter.default.removeObserver(observer)
  }
  
  func locationCity(){
    LocationService.startLocation()
    LocationService.sharedManager.afterUpdatedCityAction = {
      [weak self] sucess in
      if !sucess{
        self?.homeView.loadingAnimationStatus(.finish)
        let message = "定位失败,请稍后重试或上滑视图打开城市搜索"
        self?.showAlert(message, "好的", againReuqest: false, shouldRemind: false)
      }
      self?.showLocationStatus()
    }
    showLocationStatus()
  }
  
  
  func showLocationStatus(){
    switch LocationService.sharedManager.locationStatus{
    case .loading:
      homeView.loadingAnimationStatus(.loading)
    case .result(let city):
        dataModel.currentCity = city
        perforRequest()
    case .normal:
      return
    }
  }
  
  func perforRequest(){
      serviceResult.performResult(dataModel.currentCity) { success in
        print("网络请求")
        if !success{
          self.homeView.loadingAnimationStatus(.finish)
          let message = "网络请求出现错误,请稍后重试"
          self.showAlert(message,"取消", againReuqest: true,shouldRemind: false)
        }
        self.showRequestStatus()
      }
      showRequestStatus()
  }
  
  func showRequestStatus(){
    switch serviceResult.state{
    case .loading:
      homeView.loadingAnimationStatus(.loading)
    case .results(let result):
      dataModel.weatherResult = result
      updateUI()
      homeView.loadingAnimationStatus(.finish)
    case .noRequest:
      let message = "今天服务器请求已经超过访问次数,请明天再试"
      showAlert(message,"好的", againReuqest: false,shouldRemind: false)
      homeView.loadingAnimationStatus(.finish)
    case .nonsupportCity:
      dataModel.currentCity = ""
      let message = "很抱歉,服务器暂不支持此城市,请在城市搜索界面查找其他城市"
      showAlert(message, "好的", againReuqest: false, shouldRemind: false)
      homeView.loadingAnimationStatus(.finish)
      break
    case .noYet:
      return
    }
  }
  
  func updateUI(){
    homeView.updateUI(dataModel.weatherResult)
    collectionView.reloadData()
  }
  
  //设置第一次启动引导
  func handleFirstTime(){
    let userDefaults = UserDefaults.standard
    let firstTime = userDefaults.bool(forKey: "FirstTime")
    if firstTime{
      let firstView = FirstView.showView(self.view)
      firstView.doneButton.addTarget(self, action: #selector(touchBegin), for: .touchUpInside)
      firstView.tag = 1000;
      userDefaults.set(false, forKey: "FirstTime")
      userDefaults.synchronize()
    }else{
      updateWeatherResult()
    }
  }
  
  func touchBegin(){
    self.view .viewWithTag(1000)!.removeFromSuperview()
    updateWeatherResult()
  }
  
  func showAlert(_ message: String, _ actionTitle: String,againReuqest: Bool,shouldRemind: Bool){
    
    let alertTitle = shouldRemind ? "确定取消天气通知吗?" : "发生错误"
    let alertStyle = shouldRemind ? UIAlertControllerStyle.actionSheet : .alert
    let actionDoneTitle = shouldRemind ? "取消通知" : "重试"
    
    let alert = UIAlertController(title: alertTitle, message: message , preferredStyle: alertStyle)
    
    if againReuqest || shouldRemind{
      let actionRequest = UIAlertAction(title: actionDoneTitle, style: .default, handler: { (action) -> Void in
        if shouldRemind{
          
          self.shoudldNotification(false)
        }else{
          self.perforRequest()
        }
      })
      alert.addAction(actionRequest)
    }
    
    let actionCancel = UIAlertAction(title: actionTitle, style: .default, handler: {(_) in
      self.updateUI()
    })
    
    alert.addAction(actionCancel)
    
    present(alert, animated: true, completion: nil)
  }
 
  func shoudldNotification(_ should: Bool){
    
    dataModel.shouldRemind = should
    if should{
      playSoundEffect()
      let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }else{
      self.dataModel.dueString = "__ : __"
    }
    homeView.headViewContext(should, timeString: dataModel.dueString)
  }
  
  // MARK: - Sound Effect
  func loadSoundEffect(_ name: String){
    if let path = Bundle.main.path(forResource: name, ofType: nil){
      let fileURL = URL(fileURLWithPath: path, isDirectory: false)
      let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
      if error != kAudioServicesNoError{
        print("Sound Error: \(error), path: \(path)")
      }
    }
  }
  
  func unloadSoundEffect(){
    AudioServicesDisposeSystemSoundID(soundID)
    soundID = 0
  }
  
  func playSoundEffect(){
    AudioServicesPlaySystemSound(soundID)
  }
  
  func timePickerViewControllerDidSelect(_ controller: TimePickerViewController, didSelectTime time: String) {
    dataModel.dueString = time
    shoudldNotification(true)
    dismiss(animated: true, completion: nil)
  }
  
  func timePickerViewControllerDidCancel(_ controller: TimePickerViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func supportTableViewController(_ controller: SupportTableViewController) {
    homeView.initialScrollViewOffset()
    self.perform(#selector(HomeViewController.updateUI), with: nil, afterDelay: 0.3)
    dismiss(animated: true, completion: nil)
  }
  
  func cityListViewControolerDidSelectCity(_ controller: CityListViewController, didSelectCity city: City) {
    
    //减少网络请求次数,相同城市只有动画效果不重新加载网络请求
    if dataModel.currentCity == city.cityCN{
      self.perform(#selector(HomeViewController.updateUI), with: nil, afterDelay: 0.3)
    }else{
      dataModel.currentCity = city.cityCN
      updateWeatherResult()
    }
    dataModel.appendCity(city)
    homeView.initialScrollViewOffset()
    dismiss(animated: true, completion: nil)
  }
  
  func cityListViewControllerDeleteCity(_ controller: CityListViewController, currentCities cities: [City]){
    dataModel.cities = cities
  }
  
  func cityListViewControllerCancel(_ controller: CityListViewController) {
    homeView.initialScrollViewOffset()
    self.perform(#selector(HomeViewController.updateUI), with: nil, afterDelay: 0.3)
    dismiss(animated: true, completion: nil)
  }
  
  func HomeViewScrollStatus(_ view: HomeView, status: ScrollStatus, offsety: CGFloat, showTimePicker: Bool) {
    switch status {
    case .didScroll:
      homeView.remindStatus(dataModel.shouldRemind)
    case .endDragging:
      if showTimePicker {
        performSegue(withIdentifier: "TimePicker", sender: self)
      }
      if offsety <= -100 && !showTimePicker{
        showAlert("","不取消", againReuqest: false, shouldRemind: true)
      }
      if offsety >= 260{
        performSegue(withIdentifier: "CityList", sender: self)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "TimePicker"{
      let controller = segue.destination as! TimePickerViewController
      controller.delegate = self
    }
    if segue.identifier == "SupportView"{
     let controller = segue.destination as! SupportTableViewController
      controller.delegate = self
    }
    if segue.identifier == "CityList"{
      let controller = segue.destination as! CityListViewController
      controller.delegate = self
      controller.cities = dataModel.cities
    }
  }
}


extension HomeViewController: UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataModel.weatherResult.dailyResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekWeatherCell", for: indexPath) as! WeekWeatherCell
    
    let dailyResult = dataModel.weatherResult.dailyResults[indexPath.item]
    cell.configureForDailyResult(dailyResult)
    
    return cell
  }
}
