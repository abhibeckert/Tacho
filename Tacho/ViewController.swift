//
//  ViewController.swift
//  Tacho
//
//  Created by Abhi Beckert on 14/08/2014.
//
//  This is free and unencumbered software released into the public domain.
//  See unlicense.org
//

import UIKit

struct ISpeedEngineWarnings : RawOptionSetType {
  typealias RawValue = UInt
  private var value: UInt = 0
  init(_ value: UInt) { self.value = value }
  init(rawValue value: UInt) { self.value = value }
  init(nilLiteral: ()) { self.value = 0 }
  static var allZeros: ISpeedEngineWarnings { return self(0) }
  static func fromMask(raw:UInt) -> ISpeedEngineWarnings { return self(raw) }
  var rawValue: UInt { return self.value }
  
  static var None:              ISpeedEngineWarnings { return self(0) }
  static var WaterTemp:         ISpeedEngineWarnings { return self(0x01) }
  static var FuelPressure:      ISpeedEngineWarnings { return self(0x02) }
  static var OilPressure:       ISpeedEngineWarnings { return self(0x04) }
  static var EngineStalled:     ISpeedEngineWarnings { return self(0x08) }
  static var PitSpeedLimiter:   ISpeedEngineWarnings { return self(0x10) }
  static var RevLimiter:        ISpeedEngineWarnings { return self(0x20) }
}

class ViewController: UIViewController {
                            
  var speedLabel: UILabel!
  var gearLabel: UILabel!
  var rpmLabel: UILabel!
  var tachView: TachView!
  var fuelRemainingLabel: UILabel!
  var fuelPerLapLabel: UILabel!
  var lapsRemainingLabel: UILabel!
  var fuelPressureLabel: UILabel!
  var oilPressureLabel: UILabel!
  var waterTempLabel: UILabel!
  var settingsButton: UIButton!
  var settingsViewController: SettingsViewController?
  
  var searchingForServerLabel: UILabel!
  
  override func loadView() {
    super.loadView()
    
    let screenSize = UIScreen.mainScreen().bounds.size
    let viewSize = CGSize(width: max(screenSize.width, screenSize.height), height: min(screenSize.width, screenSize.height))
    
    self.tachView = TachView(frame: CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height))
    self.view.addSubview(self.tachView)
    
    self.searchingForServerLabel = UILabel(frame: CGRect(x: 20, y: viewSize.height - 197, width: viewSize.width - 40, height: 220))
    self.searchingForServerLabel.font = UIFont(name: "Avenir", size: 22)
    self.searchingForServerLabel.textColor = UIColor.whiteColor()
    self.searchingForServerLabel.textAlignment = .Center
    self.searchingForServerLabel.text = "Searching for iSpeed...\n "
    self.searchingForServerLabel.numberOfLines = 2
    self.view.addSubview(self.searchingForServerLabel)
    
    self.gearLabel = UILabel(frame: CGRect(x: (viewSize.width - 180) / 2, y: viewSize.height - 197, width: 180, height: 220))
    self.gearLabel.font = UIFont(name: "Avenir-Heavy", size: 180)
    self.gearLabel.textAlignment = .Center
    self.gearLabel.textColor = UIColor.whiteColor()
    self.view.addSubview(self.gearLabel)
    
    self.speedLabel = UILabel(frame: CGRect(x: 30, y: viewSize.height - 110, width: 180, height: 90))
    self.speedLabel.font = UIFont(name: "Avenir-Heavy", size: 70)
    self.speedLabel.textColor = UIColor.whiteColor()
    self.view.addSubview(self.speedLabel)
    
    self.rpmLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - 212, width: 180, height: 35))
    self.rpmLabel.font = UIFont(name: "Avenir-Heavy", size: 32)
    self.rpmLabel.textColor = UIColor.whiteColor()
    self.rpmLabel.textAlignment = .Right
    self.view.addSubview(self.rpmLabel)
    
    let labelFont = UIFont(name: "Avenir", size:15)
    let labelHeight = 22.0
    
    
    self.lapsRemainingLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 1)), width: 170, height: 20))
    self.lapsRemainingLabel.font = labelFont
    self.lapsRemainingLabel.textColor = UIColor.whiteColor()
    self.lapsRemainingLabel.textAlignment = .Right
    self.view.addSubview(self.lapsRemainingLabel)
    
    self.fuelRemainingLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 2)), width: 170, height: 20))
    self.fuelRemainingLabel.font = labelFont
    self.fuelRemainingLabel.textColor = UIColor.whiteColor()
    self.fuelRemainingLabel.textAlignment = .Right
    self.view.addSubview(self.fuelRemainingLabel)
    
    self.fuelPerLapLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 3)), width: 170, height: 20))
    self.fuelPerLapLabel.font = labelFont
    self.fuelPerLapLabel.textColor = UIColor.whiteColor()
    self.fuelPerLapLabel.textAlignment = .Right
    self.view.addSubview(self.fuelPerLapLabel)
    
    self.fuelPressureLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 4)), width: 170, height: 20))
    self.fuelPressureLabel.font = labelFont
    self.fuelPressureLabel.textColor = UIColor.whiteColor()
    self.fuelPressureLabel.textAlignment = .Right
    self.view.addSubview(self.fuelPressureLabel)
    
    self.oilPressureLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 5)), width: 170, height: 20))
    self.oilPressureLabel.font = labelFont
    self.oilPressureLabel.textColor = UIColor.whiteColor()
    self.oilPressureLabel.textAlignment = .Right
    self.view.addSubview(self.oilPressureLabel)
    
    self.waterTempLabel = UILabel(frame: CGRect(x: viewSize.width - 180, y: viewSize.height - (190 - (25 * 6)), width: 170, height: 20))
    self.waterTempLabel.font = labelFont
    self.waterTempLabel.textColor = UIColor.whiteColor()
    self.waterTempLabel.textAlignment = .Right
    self.view.addSubview(self.waterTempLabel)
    
    self.settingsButton = UIButton(frame: CGRect(x: 15, y: 25, width: 150, height: 50))
    self.settingsButton.setTitle("Settings", forState: .Normal)
    self.settingsButton.sizeToFit()
    self.settingsButton.addTarget(self, action: Selector("showSettings:"), forControlEvents: .TouchUpInside)
    self.view.addSubview(self.settingsButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("vehicleStatusChanged:"), name: TachoUpdateVehicleStatusNotificationName, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("failedToFindServer:"), name: TachoDidFailToFindServerNotificationName, object: nil)
    
    dispatch_after(1 * NSEC_PER_SEC, dispatch_get_main_queue(), {
      self.tachView.createLayers()
    })
    
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  func failedToFindServer(notification: NSNotification)
  {
    let userInfo = notification.userInfo as NSDictionary!
    let message = userInfo["message"] as String!
    
    self.searchingForServerLabel.text = "Searching for iSpeed...\n\(message)"
    
    if self.searchingForServerLabel.hidden {
      self.searchingForServerLabel.hidden = false
    }
  }

  func vehicleStatusChanged(notification: NSNotification)
  {
    let details = notification.userInfo as NSDictionary!
    if !self.searchingForServerLabel.hidden {
      self.searchingForServerLabel.hidden = true
    }
    
    if let speed = details["speed"] as? Int {
      self.speedLabel.text = "\(speed)"
      
      if speed > 0 && ISpeedServerIPAddress != "test" {
        self.settingsButton.alpha = 0
      } else {
        self.settingsButton.alpha = 1
      }
    }
    
    if let gear = details["gear"] as? Int {
      if (gear == 0) {
        self.gearLabel.text = "N"
      } else if (gear == -1) {
        self.gearLabel.text = "R"
      } else {
        self.gearLabel.text = "\(gear)"
      }
    }
    
    if let currentRPM = details["rpm"] as? Int {
      self.tachView.currentRPM = CGFloat(currentRPM)
      self.rpmLabel.text = "\(currentRPM)"
    }
    if let recentMaxRPM = details["peakRpm"] as? Int {
      self.tachView.recentMaxRPM = CGFloat(recentMaxRPM)
    }
    if let lapsRemaining = details["lapsRemaining"] as? Int {
      self.lapsRemainingLabel.text = "Laps to go: \(lapsRemaining)"
    }
    if let fuelRemaining = details["fuelRemaining"] as? Double {
      var fuelRequiredToFinish = details["fuelRequiredToFinish"] as? Double
      if (fuelRequiredToFinish == nil) {
        fuelRequiredToFinish = 0
      }
      
      self.fuelRemainingLabel.text = String(format: "Fuel: %0.1f (need %0.1f)", fuelRemaining, fuelRequiredToFinish!)
      
      let color = (fuelRemaining - fuelRequiredToFinish! > 2) ? UIColor.blackColor() : UIColor.redColor()
      if (self.fuelRemainingLabel.backgroundColor != color) {
        self.fuelRemainingLabel.backgroundColor = color
      }
    }
    if let fuelPerLap = details["fuelPerLap"] as? Double {
      self.fuelPerLapLabel.text = String(format: "Fuel per lap: %0.2f", fuelPerLap)
    }
    
    if let sampleData = details["sampledata"] as? NSDictionary {
      if let fuelPressure = sampleData["FuelPress"] as? Double {
        fuelPressureLabel.text = String(format: "Fuel Pressure: %0.2f", fuelPressure)
      }
      if let oilPressure = sampleData["OilPress"] as? Double {
        oilPressureLabel.text = String(format: "Oil Pressure: %0.2f", oilPressure)
      }
      if let waterTemp = sampleData["WaterTemp"] as? Double {
        waterTempLabel.text = String(format: "Water Temp: %0.0f", waterTemp)
      }
      
      if let warningsInt = sampleData["EngineWarnings"] as? UInt {
        let warnings = ISpeedEngineWarnings.fromMask(warningsInt)
        
        var color = (warnings & .WaterTemp != nil) ? UIColor.redColor() : UIColor.blackColor()
        if (waterTempLabel.backgroundColor != color) {
          waterTempLabel.backgroundColor = color
        }
        color = (warnings & .FuelPressure != nil) ? UIColor.redColor() : UIColor.blackColor()
        if (fuelPressureLabel.backgroundColor != color) {
          fuelPressureLabel.backgroundColor = color
        }
        color = (warnings & .OilPressure != nil) ? UIColor.redColor() : UIColor.blackColor()
        if (oilPressureLabel.backgroundColor != color) {
          oilPressureLabel.backgroundColor = color
        }
        var bool = warnings & .EngineStalled != nil
        if (self.tachView.stalled != bool) {
          self.tachView.stalled = bool
        }
        bool = warnings & .PitSpeedLimiter != nil
        if (self.tachView.pitSpeedLimiter != bool) {
          self.tachView.pitSpeedLimiter = bool
        }
        bool = warnings & .RevLimiter != nil
        if (self.tachView.revLimiter != bool) {
          self.tachView.revLimiter = bool
        }
      }
    }
    
    
    self.tachView.updateLayers()
  }
  
  override func supportedInterfaceOrientations() -> Int {
    let orientation = UIInterfaceOrientationMask.Landscape
    
    return Int(orientation.rawValue)
  }
  
  func showSettings(sender: AnyObject)
  {
    self.settingsViewController = SettingsViewController(nibName: nil, bundle: nil)
    
    self.presentViewController(self.settingsViewController!, animated: true, completion: nil)
  }
}

