//
//  TachView.swift
//  Tacho
//
//  Created by Abhi Beckert on 15/08/2014.
//
//  This is free and unencumbered software released into the public domain.
//  See unlicense.org
//

import UIKit
import QuartzCore
import CoreText

class TachView: UIView
{
  var currentRPM: CGFloat = 0
  var stalled: Bool = false
  var pitSpeedLimiter = false
  var revLimiter = false
  var recentMaxRPM: CGFloat = 0
  
  let tachMinStrokeStart: CGFloat = 0.52
  let tachMaxStrokeEnd: CGFloat = 0.745
  
  let tachBackgroundLayer = CAShapeLayer()
  let tachLayer = CAShapeLayer()
  let tachRecentMaxLayer = CAShapeLayer()
  let tachCutoutLayer = CAShapeLayer()
  
  let tachBackgroundColor = UIColor(white: 0.2, alpha: 1.0).CGColor
  let lowRPMColor = UIColor.whiteColor().CGColor
  let midRPMColor = UIColor.cyanColor().CGColor
  let highRPMColor = UIColor.yellowColor().CGColor
  let shiftNowColor = UIColor.greenColor().CGColor
  let limiterColor = UIColor.redColor().CGColor
  let limiterAltColor = UIColor.blackColor().CGColor
  let pitLimiterColor = UIColor.orangeColor().CGColor
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.layer.contentsScale = 2.0
    self.isAccessibilityElement = true
  }
  
  required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
    
    self.layer.contentsScale = 2.0
    self.isAccessibilityElement = true
  }
  
  func createLayers()
  {
    self.backgroundColor = UIColor.blackColor()
    
    
    let tachPath = UIBezierPath(ovalInRect: CGRect(x: 40, y: self.bounds.size.height * 0.2, width: self.bounds.width * 1.85, height: self.bounds.height * 0.9))
    
    let tachCutoutPath = UIBezierPath(ovalInRect: CGRect(x: 0 - 80, y: (self.bounds.size.height * 0.2) + 35, width: self.bounds.width * 2.3, height: self.bounds.height * 0.9))
    
    
    tachBackgroundLayer.contentsScale = 2.0
    tachBackgroundLayer.path = tachPath.CGPath
    tachBackgroundLayer.strokeColor = self.tachBackgroundColor
    tachBackgroundLayer.fillColor = UIColor.clearColor().CGColor
    tachBackgroundLayer.lineWidth = 75
    
    tachBackgroundLayer.strokeStart = tachMinStrokeStart
    tachBackgroundLayer.strokeEnd = tachMaxStrokeEnd
    
    self.layer.addSublayer(tachBackgroundLayer)
    
    tachLayer.path = tachPath.CGPath
    tachLayer.contentsScale = 2.0
    if (currentRPM < shiftGreenMinRPM) {
      tachLayer.strokeColor = self.lowRPMColor
    } else if (currentRPM < shiftRedMinRPM) {
      tachLayer.strokeColor = self.midRPMColor
    } else if (currentRPM < shiftBlueMinRPM) {
      tachLayer.strokeColor = self.highRPMColor
    } else {
      tachLayer.strokeColor = self.shiftNowColor
    }
    
    tachLayer.fillColor = UIColor.clearColor().CGColor
    tachLayer.lineWidth = 75
    
    tachLayer.strokeStart = tachMinStrokeStart
    tachLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / currentRPM))
    
    self.layer.addSublayer(tachLayer)
    
    
    tachRecentMaxLayer.contentsScale = 2.0
    tachRecentMaxLayer.path = tachPath.CGPath
    
    if (recentMaxRPM < shiftGreenMinRPM) {
      tachRecentMaxLayer.strokeColor = self.lowRPMColor
    } else if (recentMaxRPM < shiftRedMinRPM) {
      tachRecentMaxLayer.strokeColor = UIColor.cyanColor().CGColor
    } else if (recentMaxRPM < shiftBlueMinRPM) {
      tachRecentMaxLayer.strokeColor = self.highRPMColor
    } else {
      tachRecentMaxLayer.strokeColor = self.shiftNowColor
    }
    
    
    tachRecentMaxLayer.fillColor = UIColor.clearColor().CGColor
    tachRecentMaxLayer.lineWidth = 75
    
    tachRecentMaxLayer.strokeStart = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) - ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)
    tachRecentMaxLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) + ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)
    
    self.layer.addSublayer(tachRecentMaxLayer)
    
    tachCutoutLayer.contentsScale = 2.0
    tachCutoutLayer.path = tachCutoutPath.CGPath
    tachCutoutLayer.fillColor = UIColor.blackColor().CGColor
    
    self.layer.addSublayer(tachCutoutLayer)
    
  }
  
  func updateLayers()
  {
    CATransaction.begin()
    if (!animateTachChanges) {
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    } else {
      CATransaction.setAnimationDuration(1.0 / 5)
    }
    
    let tachPath = UIBezierPath(ovalInRect: CGRect(x: 40, y: (self.bounds.size.height * 0.2) + 5, width: self.bounds.width * 1.85, height: self.bounds.height * 0.9))
    
    let tachCutoutPath = UIBezierPath(ovalInRect: CGRect(x: 0 - 80, y: (self.bounds.size.height * 0.2) + 35, width: self.bounds.width * 2.3, height: self.bounds.height * 0.9))
    
    tachBackgroundLayer.path = tachPath.CGPath
    tachLayer.path = tachPath.CGPath
    
    tachLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / currentRPM))
    
    if self.pitSpeedLimiter {
      if round(NSDate.timeIntervalSinceReferenceDate() * 4) % 2 == 0 {
        tachBackgroundLayer.strokeColor = self.pitLimiterColor
      } else {
        tachBackgroundLayer.strokeColor = self.tachBackgroundColor
      }
    } else {
      tachBackgroundLayer.strokeColor = self.tachBackgroundColor
    }
    
    if (self.stalled) {
      tachLayer.strokeColor = UIColor.clearColor().CGColor
    } else if (self.revLimiter && !self.pitSpeedLimiter) {
      if round(NSDate.timeIntervalSinceReferenceDate() * 12) % 2 == 0 {
        tachLayer.strokeColor = self.limiterColor
      } else {
        tachLayer.strokeColor = self.limiterAltColor
      }
    } else if (currentRPM < shiftGreenMinRPM) {
      tachLayer.strokeColor = self.lowRPMColor
    } else if (currentRPM < shiftRedMinRPM) {
      tachLayer.strokeColor = self.midRPMColor
    } else if (currentRPM < shiftBlueMinRPM) {
      tachLayer.strokeColor = self.highRPMColor
    } else if (currentRPM <= maxRPM) {
      tachLayer.strokeColor = self.shiftNowColor
    } else {
      if (round(NSDate.timeIntervalSinceReferenceDate() * 12) % 2 == 0) {
        tachLayer.strokeColor = self.limiterColor
      } else {
        tachLayer.strokeColor = self.limiterAltColor
      }
    }
    
    
    if fabs(recentMaxRPM - currentRPM) < 0.1 {
      tachRecentMaxLayer.opacity = 0
    } else {
      tachRecentMaxLayer.opacity = 1
      tachRecentMaxLayer.path = tachPath.CGPath
      if (recentMaxRPM < shiftGreenMinRPM) {
        tachRecentMaxLayer.strokeColor = self.lowRPMColor
      } else if (recentMaxRPM < shiftRedMinRPM) {
        tachRecentMaxLayer.strokeColor = self.midRPMColor
      } else if (recentMaxRPM < shiftBlueMinRPM) {
        tachRecentMaxLayer.strokeColor = self.highRPMColor
      } else {
        tachRecentMaxLayer.strokeColor = self.shiftNowColor
      }
      tachRecentMaxLayer.strokeStart = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) - ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)
      tachRecentMaxLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) + ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)
    }
    
    tachCutoutLayer.path = tachCutoutPath.CGPath
    
    CATransaction.commit()
  }
  
  func accessibilityLabel() -> String
  {
    let rpm: Int = Int(self.currentRPM)
    
    return "\(rpm)"
  }
}
