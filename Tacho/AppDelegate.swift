//
//  AppDelegate.swift
//  Tacho
//
//  Created by Abhi Beckert on 14/08/2014.
//
//  This is free and unencumbered software released into the public domain.
//  See unlicense.org
//

import UIKit

let TachoUpdateVehicleStatusNotificationName = "TachoUpdateVehicleStatusNotificationName"
let TachoDidFailToFindServerNotificationName = "TachoDidFailToFindServerNotificationName"

//var ISpeedServerIPAddress: String?
//var ISpeedServerIPAddress = "192.168.99.109"
var ISpeedServerIPAddress = "auto"
var ISpeedServerPort = "3278"
//var ISpeedServerPort = "80"
var ISpeedServerUri = "data.json"

let ISpeedPollHertz: UInt64 = 60
var animateTachChanges = false // looks nicer but less useful?

var maxRPM: CGFloat = 0
var shiftGreenMinRPM: CGFloat = 0
var shiftRedMinRPM: CGFloat = 0
var shiftBlueMinRPM: CGFloat = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSURLConnectionDataDelegate {
  
  var window: UIWindow?
  
  var updateTimer: NSTimer?
  var rpm = 0
  var peakRpm = 0
  var peakRpmLastUpdate = NSDate()
  var speed = 0
  var gear = 0
  var lastCheckForFuel = NSDate()
  var lastCheckForSessionData = NSDate()
  var fuelRemaining = 0.0
  var fuelPerLap = 0.0
  var lapsRemaining = 0
  var fuelRequiredToFinish = 0.0
  var sampleData: NSDictionary!
  
  var iSpeedUrlConnection: NSURLConnection?
  
  var logFileHandle: NSFileHandle?
  var logFileStartDate: NSDate!
  
  var sampleDataLogFile: NSFileHandle!
  
  var currentConnection: NSURLConnection?
  var currentResponseData: NSMutableData?
  
  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    
    // init log writing
    let documentsDir = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    if !documentsDir.checkResourceIsReachableAndReturnError(nil) {
      NSFileManager.defaultManager().createDirectoryAtURL(documentsDir, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    let logFile = documentsDir.URLByAppendingPathComponent("log.irlap")
    "".writeToURL(logFile, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    self.logFileHandle = NSFileHandle(forWritingToURL: logFile, error: nil)
    let headerData: NSData! = "".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    self.logFileHandle?.writeData(headerData)
    self.logFileStartDate = NSDate()
    
    let sampleDataLogFile = documentsDir.URLByAppendingPathComponent("sampleDataLogFile.txt")
    "-log-".writeToURL(sampleDataLogFile, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    self.sampleDataLogFile = NSFileHandle(forWritingToURL: sampleDataLogFile, error: nil)
    
    // start trying to talk to iSpeed
    self.pollISpeed()
    
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication!) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication!) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication!) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication!) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication!) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func pollISpeed()
  {
    // try to guess IP address
    if ISpeedServerIPAddress == "auto" {
      
      self.guessISpeedIP()

      return
    }
    
    
    
    // poll iSpeed
    let sampleDataStr = "?SendSampleData=EngineWarnings,WaterTemp,WaterLevel,FuelPress,OilTemp,OilPress,OilLevel"
    var splitsFuelStr = "&nosplits&nofuel"
    var sessionDataStr = ""
    
    var requestURL: NSURL!
    if self.lastCheckForFuel.timeIntervalSinceNow < -1 {
      splitsFuelStr = ""
      sessionDataStr = "&SendSessionData=DriverInfo.DriverCarSLShiftRPM,DriverInfo.DriverCarSLLastRPM,DriverInfo.DriverCarSLFirstRPM,DriverInfo.DriverCarSLBlinkRPM,DriverInfo.DriverCarRedLine"
      
      self.lastCheckForFuel = NSDate()
    }
    requestURL = NSURL(string: "http://\(ISpeedServerIPAddress):\(ISpeedServerPort)/\(ISpeedServerUri)\(sampleDataStr)\(splitsFuelStr)\(sessionDataStr)")
    
    let request = NSURLRequest(URL: requestURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 0.5)
    
    if self.currentConnection != nil {
      self.currentConnection?.cancel()
    }
    
    self.currentResponseData = NSMutableData()
    
    self.currentConnection = NSURLConnection(request: request, delegate: self)
    
//    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {[unowned self] (response, data, error) -> Void in
//      let seconds = fabs(self.logFileStartDate.timeIntervalSinceNow)
//      self.sampleDataLogFile.writeData("\n\n\(seconds)\n\(requestURL)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
//      if let httpResponse = response as NSHTTPURLResponse? {
//        self.sampleDataLogFile.writeData("HTTP \(httpResponse.statusCode)\n\(httpResponse.allHeaderFields)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
//      }
//      if data != nil {
//        self.sampleDataLogFile.writeData(data)
//      }
//      
//      self.processResponse(response, data: data, error: error)
//    }
  }
  
  func processResponse(response: NSURLResponse?, data: NSData?, error: NSError?)
  {
    var delay = NSEC_PER_SEC / ISpeedPollHertz
    
    if let safeError = error {
      delay = NSEC_PER_SEC / 2
    }
    
    dispatch_after(delay, dispatch_get_main_queue(), {
      self.pollISpeed()
    })
    
    if data == nil {
      return
    }
    
    if let safeData = data {
      let unsafeDecodedJSon: AnyObject! = NSJSONSerialization.JSONObjectWithData(safeData, options: nil, error: nil)
      if let jsonRecord = unsafeDecodedJSon as? NSDictionary {
        if let speedRecord = jsonRecord["speed"] as? NSDictionary {
          if let speed = speedRecord["val"] as? Double {
            self.speed = max(Int(speed), 0)
          }
        }
        if let rpm = jsonRecord["rpm"] as? Int {
          self.rpm = max(rpm, 0)
        }
        if let gear = jsonRecord["gear"] as? Int {
          self.gear = gear
        }
        if let fuelRecord = jsonRecord["fuel"] as? NSDictionary {
          if let fuelRemainingStr = fuelRecord["fuelremaining"] as? String {
            let fuelRemaining = (fuelRemainingStr.stringByReplacingOccurrencesOfString(" L", withString: "", options: nil, range: nil) as NSString).doubleValue
            self.fuelRemaining = fuelRemaining
          }
          if let fuelPerLapStr = fuelRecord["curfuelperlap"] as? String {
            let fuelPerLap = (fuelPerLapStr.stringByReplacingOccurrencesOfString(" L", withString: "", options: nil, range: nil) as NSString).doubleValue
            self.fuelPerLap = fuelPerLap
          }
        }
        if let lapsRemaining = jsonRecord["lapsremaining"] as? Int {
          self.lapsRemaining = lapsRemaining
          self.fuelRequiredToFinish = Double(self.lapsRemaining) * self.fuelPerLap
        }
        
        if let handle = self.logFileHandle {
          let microseconds = fabs(self.logFileStartDate.timeIntervalSinceNow) * 1000
          let rawJson = NSString(data: safeData, encoding: NSUTF8StringEncoding)
          
          let entry = "\(microseconds),\(self.speed),\(self.gear),\(self.rpm),\(rawJson)\r\n"
          
          let rowData: NSData! = entry.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
          handle.writeData(rowData)
        }
        
        if let sessionData = jsonRecord["sessiondata"] as? NSDictionary {
          
          
          if let rpm = sessionData["DriverInfo.DriverCarSLFirstRPM"] as? NSString {
            shiftGreenMinRPM = CGFloat(rpm.floatValue);
          }
          
          if let rpm = sessionData["DriverInfo.DriverCarSLShiftRPM"] as? NSString {
            shiftBlueMinRPM = CGFloat(rpm.floatValue);
          }
          
          shiftRedMinRPM = shiftGreenMinRPM + ((shiftBlueMinRPM - shiftGreenMinRPM) / 2)
          
          if let rpm = sessionData["DriverInfo.DriverCarRedLine"] as? NSString {
            maxRPM = CGFloat(rpm.floatValue);
          }
          
        }
        
        if let data = jsonRecord["sampledata"] as? NSDictionary {
          self.sampleData = data
        } else {
          self.sampleData = nil
        }
      } else {
        println("failed to decode JSON")
      }
      
      self.broadcastResponseData()
    }
  }
  
  
  func broadcastResponseData()
  {
    //      let documentsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    //
    //      if !documentsDir.checkResourceIsReachableAndReturnError(nil) {
    //        NSFileManager.defaultManager().createDirectoryAtURL(documentsDir, withIntermediateDirectories: true, attributes: nil, error: nil)
    //      }
    //
    //      let logUrl = documentsDir.URLByAppendingPathComponent("debug.txt")
    //      data.writeToURL(logUrl, atomically: true)
    
    // peak RPM is too old?
    if (self.peakRpmLastUpdate.timeIntervalSinceNow < -1.0) {
      self.peakRpm = 0;
    }
    if (self.rpm > self.peakRpm) {
      self.peakRpm = self.rpm
      self.peakRpmLastUpdate = NSDate()
    }
    
    // update gear
    let userInfo = ["gear": self.gear, "rpm": self.rpm, "peakRpm": self.peakRpm, "speed": Int(self.speed), "fuelRemaining": self.fuelRemaining, "fuelPerLap": self.fuelPerLap, "lapsRemaining": self.lapsRemaining, "fuelRequiredToFinish": self.fuelRequiredToFinish, "sampledata": self.sampleData]
    
    NSNotificationCenter.defaultCenter().postNotificationName(TachoUpdateVehicleStatusNotificationName, object: self, userInfo: userInfo)
  }
  
  func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse?
  {
    return nil // never cache anything. ever.
  }
  
  func connection(connection: NSURLConnection, didReceiveData data: NSData)
  {
    if self.currentResponseData == nil {
      self.currentResponseData = NSMutableData()
    }
    
//    self.sampleDataLogFile.writeData(data)
    
    self.currentResponseData!.appendData(data)
  }
  
  func connection(connection: NSURLConnection, didFailWithError error: NSError)
  {
    self.processResponse(nil, data: nil, error: error)
  }
  
  func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse)
  {
//      let seconds = fabs(self.logFileStartDate.timeIntervalSinceNow)
//      self.sampleDataLogFile.writeData("\n\n\(seconds)\n\(requestURL)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
//      if let httpResponse = response as NSHTTPURLResponse? {
//        self.sampleDataLogFile.writeData("HTTP \(httpResponse.statusCode)\n\(httpResponse.allHeaderFields)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
//      }
  }
  
  func connectionDidFinishLoading(connection: NSURLConnection)
  {
    self.processResponse(nil, data: self.currentResponseData, error: nil)
  }
  
  func prefersStatusBarHidden() -> Bool
  {
    return false
  }
  
  func getDeviceLANIPAddress() -> String?
  {
    let ifAddresses = self.getIFAddresses()
    
    for ifAddress in ifAddresses {
      if ifAddress.rangeOfString("192.168.", options: .AnchoredSearch) == nil {
        continue
      }
      
      return ifAddress
    }
    
    // try to find a 10. address
    for ifAddress in ifAddresses {
      if ifAddress.rangeOfString("10.", options: .AnchoredSearch) == nil {
        continue
      }
      
      return ifAddress
    }
    
    return nil
  }
  
  func getIFAddresses() -> [String] {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
    if getifaddrs(&ifaddr) == 0 {
      
      // For each interface ...
      for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
        let flags = Int32(ptr.memory.ifa_flags)
        var addr = ptr.memory.ifa_addr.memory
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
          if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
            
            // Convert interface address to a human readable string:
            var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
            if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
              nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                if let address = String.fromCString(hostname) {
                  addresses.append(address)
                }
            }
          }
        }
      }
      freeifaddrs(ifaddr)
    }
    
    return addresses
  }
  
  func guessISpeedIP()
  {
    // find our LAN IP
    let deviceIP = self.getDeviceLANIPAddress() as String!
    if deviceIP == nil {
      dispatch_after(NSEC_PER_SEC / (ISpeedPollHertz / 10), dispatch_get_main_queue(), { () -> Void in
        self.pollISpeed()
      })
      NSNotificationCenter.defaultCenter().postNotificationName(TachoDidFailToFindServerNotificationName, object: self, userInfo: ["message": "No LAN IP"])
      return
    }
    
    // find our subnet
    let subnet = deviceIP.stringByReplacingOccurrencesOfString("\\.[0-9]+$", withString: "", options: .RegularExpressionSearch, range: nil)
    
    // sequentially pick a host number
    struct Holder {
      static var lastHostNumber = -1
    }
    if (Holder.lastHostNumber == -1) {
      Holder.lastHostNumber = NSUserDefaults().integerForKey("LastHostNumber");
    } else {
      Holder.lastHostNumber++
    }
    if Holder.lastHostNumber < 0 || Holder.lastHostNumber > 255 {
      Holder.lastHostNumber = 0
    }
    
    // try this IP address
    let possibleISpeedIP = "\(subnet).\(Holder.lastHostNumber)"
    let url = NSURL(string: "http://\(possibleISpeedIP):\(ISpeedServerPort)/\(ISpeedServerUri)")
    let request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 0.1)
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {[unowned self] (response, data, error) -> Void in
      if error != nil {
        dispatch_after(NSEC_PER_SEC / ISpeedPollHertz, dispatch_get_main_queue(), { () -> Void in
          self.pollISpeed()
        })
        NSNotificationCenter.defaultCenter().postNotificationName(TachoDidFailToFindServerNotificationName, object: self, userInfo: ["message": possibleISpeedIP])
        return
      }
      
      ISpeedServerIPAddress = "\(possibleISpeedIP)"
      NSUserDefaults().setInteger(Holder.lastHostNumber, forKey: "LastHostNumber")
      self.pollISpeed()
    }
  }
}

