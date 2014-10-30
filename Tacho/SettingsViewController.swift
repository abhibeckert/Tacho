//
//  SettingsViewController.swift
//  Tacho
//
//  Created by Abhi Beckert on 20/08/2014.
//
//  This is free and unencumbered software released into the public domain.
//  See unlicense.org
//

import UIKit

class SettingsViewController: UIViewController {
  
  var ipField: UITextField!
  var portField: UITextField!
  var connectButton: UIButton!
  
  override func loadView() {
    super.loadView()
    
    let screenSize = UIScreen.mainScreen().bounds.size
    let viewSize = CGSize(width: max(screenSize.width, screenSize.height), height: min(screenSize.width, screenSize.height))
    
    self.view = UIView(frame: CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height))
    self.view.backgroundColor = UIColor.whiteColor()
    
    let ipLabelField = UILabel(frame: CGRect(x: 15, y: 40, width: 300, height: 30))
    ipLabelField.text = "iSpeed IP Address:"
    ipLabelField.sizeToFit()
    self.view.addSubview(ipLabelField)
    
    self.ipField = UITextField(frame: CGRect(x: ipLabelField.frame.maxX + 14, y: ipLabelField.frame.minY - 5, width: 200, height: 30))
    self.ipField.borderStyle = .RoundedRect
    self.ipField.text = ISpeedServerIPAddress
    self.ipField.keyboardType = .NumbersAndPunctuation
    self.ipField.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.ipField)
    
    let portLabelField = UILabel(frame: CGRect(x: self.ipField.frame.maxX + 14, y: ipLabelField.frame.minY, width: 300, height: 30))
    portLabelField.text = "Port:"
    portLabelField.sizeToFit()
    self.view.addSubview(portLabelField)
    
    self.portField = UITextField(frame: CGRect(x: portLabelField.frame.maxX + 14, y: portLabelField.frame.minY - 5, width: 80, height: 30))
    self.portField.borderStyle = .RoundedRect
    self.portField.text = ISpeedServerPort
    self.portField.keyboardType = .NumbersAndPunctuation
    self.portField.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.portField)
    
    self.connectButton = UIButton.buttonWithType(.System) as UIButton
    self.connectButton.frame = CGRect(x: self.ipField.frame.minX, y: self.ipField.frame.maxY + 14, width: 100, height: 30)
    self.connectButton.setTitle("Connect", forState: .Normal)
    self.connectButton.sizeToFit()
    self.connectButton.addTarget(self, action: Selector("connect:"), forControlEvents: .TouchUpInside)
    self.view.addSubview(self.connectButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func connect(sender: AnyObject)
  {
    ISpeedServerIPAddress = self.ipField.text
    ISpeedServerPort = self.portField.text
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
