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
  var waterLevelLabel: UILabel!
  var settingsButton: UIButton!
  var settingsViewController: SettingsViewController?
  
  override func loadView() {
    super.loadView()
    
    let screenSize = UIScreen.mainScreen().bounds.size
    let viewSize = CGSize(width: max(screenSize.width, screenSize.height), height: min(screenSize.width, screenSize.height))
    
    self.tachView = TachView(frame: CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height))
    self.view.addSubview(self.tachView)
    
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
    
    
    self.lapsRemainingLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 1)), width: 180, height: 20))
    self.lapsRemainingLabel.font = labelFont
    self.lapsRemainingLabel.textColor = UIColor.whiteColor()
    self.lapsRemainingLabel.textAlignment = .Right
    self.view.addSubview(self.lapsRemainingLabel)
    
    self.fuelRemainingLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 2)), width: 180, height: 20))
    self.fuelRemainingLabel.font = labelFont
    self.fuelRemainingLabel.textColor = UIColor.whiteColor()
    self.fuelRemainingLabel.textAlignment = .Right
    self.view.addSubview(self.fuelRemainingLabel)
    
    self.fuelPerLapLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 3)), width: 180, height: 20))
    self.fuelPerLapLabel.font = labelFont
    self.fuelPerLapLabel.textColor = UIColor.whiteColor()
    self.fuelPerLapLabel.textAlignment = .Right
    self.view.addSubview(self.fuelPerLapLabel)
    
    self.fuelPressureLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 4)), width: 180, height: 20))
    self.fuelPressureLabel.font = labelFont
    self.fuelPressureLabel.textColor = UIColor.whiteColor()
    self.fuelPressureLabel.textAlignment = .Right
    self.view.addSubview(self.fuelPressureLabel)
    
    self.oilPressureLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 5)), width: 180, height: 20))
    self.oilPressureLabel.font = labelFont
    self.oilPressureLabel.textColor = UIColor.whiteColor()
    self.oilPressureLabel.textAlignment = .Right
    self.view.addSubview(self.oilPressureLabel)
    
    self.waterLevelLabel = UILabel(frame: CGRect(x: viewSize.width - 200, y: viewSize.height - (190 - (25 * 6)), width: 180, height: 20))
    self.waterLevelLabel.font = labelFont
    self.waterLevelLabel.textColor = UIColor.whiteColor()
    self.waterLevelLabel.textAlignment = .Right
    self.view.addSubview(self.waterLevelLabel)
    
    self.settingsButton = UIButton(frame: CGRect(x: 15, y: 25, width: 150, height: 50))
    self.settingsButton.setTitle("Settings", forState: .Normal)
    self.settingsButton.sizeToFit()
    self.settingsButton.addTarget(self, action: Selector("showSettings:"), forControlEvents: .TouchUpInside)
    self.view.addSubview(self.settingsButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("vehicleStatusChanged:"), name: TachoUpdateVehicleStatusNotificationName, object: nil)
    
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

  func vehicleStatusChanged(notification: NSNotification)
  {
    let details = notification.userInfo as NSDictionary!
    
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
        fuelPressureLabel.text = String(format: "Fuel Pressure: %0.3f", fuelPressure)
      }
      if let oilPressure = sampleData["OilPress"] as? Double {
        oilPressureLabel.text = String(format: "Oil Pressure: %0.3f", oilPressure)
      }
      if let waterLevel = sampleData["WaterLevel"] as? Int {
        waterLevelLabel.text = String(format: "Water Level: \(waterLevel)")
      }
      if let warnings = sampleData["EngineWarnings"] as? Int {
        let color = warnings == 0 ? UIColor.blackColor() : UIColor.redColor()
        
        if (fuelPressureLabel.backgroundColor != color) {
          fuelPressureLabel.backgroundColor = color
          oilPressureLabel.backgroundColor = color
          waterLevelLabel.backgroundColor = color
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

