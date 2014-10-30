// Playground - noun: a place where people can play
//
//  Created by Abhi Beckert on 14/08/2014.
//
//  This is free and unencumbered software released into the public domain.
//  See unlicense.org
//

import UIKit
import QuartzCore
import CoreText

let documentsDir = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
if !documentsDir.checkResourceIsReachableAndReturnError(nil) {
  NSFileManager.defaultManager().createDirectoryAtURL(documentsDir, withIntermediateDirectories: true, attributes: nil, error: nil)
}


let logFile = documentsDir.URLByAppendingPathComponent("test.txt")
"".writeToURL(logFile, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
var error: NSError?
let logFileHandle = NSFileHandle.fileHandleForWritingToURL(logFile, error: &error)
if logFileHandle == nil  {
  println(error)
}
logFileHandle?.writeData("[Samples]\r\nTime,Speed,Gear,RPM,Raw\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)


let currentRPM: CGFloat = 7250
let recentMaxRPM: CGFloat = 7850
let optimalRPM: CGFloat = 7600
let currentGear = 3
let currentSpeed = 235

let maxRPM: CGFloat = 8000
let shiftSoonRPM: CGFloat = 6500
let shiftMinRPM: CGFloat = 7200
let shiftMaxRPM: CGFloat = 7800



let tachView = UIView(frame: CGRectMake(0,0, 1136, 640))
tachView.backgroundColor = UIColor.blackColor()


let tachMinStrokeStart: CGFloat = 0.53
let tachMaxStrokeEnd: CGFloat = 0.745

let tachPath = UIBezierPath(ovalInRect: CGRect(x: 75, y: tachView.bounds.size.height * 0.2, width: tachView.bounds.width * 1.85, height: tachView.bounds.height * 0.9))

let tachCutoutPath = UIBezierPath(ovalInRect: CGRect(x: 0 - 70, y: (tachView.bounds.size.height * 0.2) + 50, width: tachView.bounds.width * 1.9, height: tachView.bounds.height * 0.9))


let tachBackgroundLayer = CAShapeLayer()
tachBackgroundLayer.path = tachPath.CGPath
tachBackgroundLayer.strokeColor = UIColor.whiteColor().CGColor
tachBackgroundLayer.opacity = 0.25
tachBackgroundLayer.fillColor = UIColor.clearColor().CGColor
tachBackgroundLayer.lineWidth = 100

tachBackgroundLayer.strokeStart = tachMinStrokeStart
tachBackgroundLayer.strokeEnd = tachMaxStrokeEnd

tachView.layer.addSublayer(tachBackgroundLayer)



let tachOptimalLayer = CAShapeLayer()
tachOptimalLayer.path = tachPath.CGPath

tachOptimalLayer.strokeColor = UIColor.grayColor().CGColor

tachOptimalLayer.fillColor = UIColor.clearColor().CGColor
tachOptimalLayer.lineWidth = 100

tachOptimalLayer.strokeStart = tachMinStrokeStart
tachOptimalLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / optimalRPM)) + ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)

tachView.layer.addSublayer(tachOptimalLayer)



let tachLayer = CAShapeLayer()

tachLayer.path = tachPath.CGPath
switch (currentRPM) {
case 0..<shiftSoonRPM:
  tachLayer.strokeColor = UIColor.whiteColor().CGColor
case shiftSoonRPM..<shiftMinRPM:
  tachLayer.strokeColor = UIColor.cyanColor().CGColor
case shiftMinRPM..<shiftMaxRPM:
  tachLayer.strokeColor = UIColor.yellowColor().CGColor
default:
  tachLayer.strokeColor = UIColor.redColor().CGColor
}

tachLayer.fillColor = UIColor.clearColor().CGColor
tachLayer.lineWidth = 100

tachLayer.strokeStart = tachMinStrokeStart
tachLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / currentRPM))

tachView.layer.addSublayer(tachLayer)

let tachRecentMaxLayer = CAShapeLayer()
tachRecentMaxLayer.path = tachPath.CGPath

switch (recentMaxRPM) {
case 0..<shiftSoonRPM:
  tachRecentMaxLayer.strokeColor = UIColor.whiteColor().CGColor
case shiftSoonRPM..<shiftMinRPM:
  tachRecentMaxLayer.strokeColor = UIColor.cyanColor().CGColor
case shiftMinRPM..<shiftMaxRPM:
  tachRecentMaxLayer.strokeColor = UIColor.yellowColor().CGColor
default:
  tachRecentMaxLayer.strokeColor = UIColor.redColor().CGColor
}


tachRecentMaxLayer.fillColor = UIColor.clearColor().CGColor
tachRecentMaxLayer.lineWidth = 100

tachRecentMaxLayer.strokeStart = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) - ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)
tachRecentMaxLayer.strokeEnd = tachMinStrokeStart + ((tachMaxStrokeEnd - tachMinStrokeStart) / (maxRPM / recentMaxRPM)) + ((tachMaxStrokeEnd - tachMinStrokeStart) * 0.0017)

tachView.layer.addSublayer(tachRecentMaxLayer)


let tachCutoutLayer = CAShapeLayer()
tachCutoutLayer.path = tachCutoutPath.CGPath
//tachCutoutLayer.opacity = 0.6
tachCutoutLayer.fillColor = UIColor.blackColor().CGColor

tachView.layer.addSublayer(tachCutoutLayer)










let speedLayer = CATextLayer()
speedLayer.frame = CGRect(x: 80, y: 380, width: 400, height: 400)

let speedString = "\(currentSpeed)"
let speedCFString = (speedString as NSString) as CFString

speedLayer.string = CFAttributedStringCreate(nil, speedCFString, [kCTForegroundColorAttributeName: UIColor.whiteColor().CGColor, kCTFontAttributeName: UIFont(name: "Avenir-Heavy", size: 150)])

tachView.layer.addSublayer(speedLayer)





let gearLayer = CATextLayer()
gearLayer.frame = CGRect(x: tachView.frame.size.width - 300, y: 180, width: 300, height: 400)

let gearString = "\(currentGear)"
let gearCFString = (gearString as NSString) as CFString

gearLayer.string = CFAttributedStringCreate(nil, gearCFString, [kCTForegroundColorAttributeName: UIColor.whiteColor().CGColor, kCTFontAttributeName: UIFont(name: "Avenir-Heavy", size: 350)])

tachView.layer.addSublayer(gearLayer)


tachView
