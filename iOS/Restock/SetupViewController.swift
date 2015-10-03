//
//  SetupViewController.swift
//  Restock
//
//  Created by Carl Julius Gödecken on 02/10/15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import SnapKit

class SetupViewController : UIViewController    {
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidden = false
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let wunderlistButton: UIButton = {
        let button = UIButton(type: .Custom)
        //button.setTitle("Loading...", forState: .Normal)
        button.backgroundColor = UIColor(red: 219/255, green: 76/255, blue: 63/255, alpha: 1)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(blurEffectView)
        
        wunderlistButton.addSubview(activityIndicator)
        activityIndicator.snp_makeConstraints {(make) in
         make.center.equalTo(wunderlistButton)
        }
        self.view.addSubview(wunderlistButton)
        wunderlistButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(Constants.GridWidth * 4)
            make.right.equalTo(self.view).offset(-1 * Constants.GridWidth * 4)
            make.bottom.equalTo(self.view).offset(-1 * Constants.GridHeight * 4)
            make.height.equalTo(Constants.GridHeight * 2)
        }
        
        //tryLogin()
    }
    
    func tryLogin() {
        WunderlistClient.testLoginStatus({loggedIn in
            if(loggedIn)    {
                self.performSegueToScanView()
            }   else    {
                self.enableLoginButton()
            }
            }, onFailure: {
                let alertController = UIAlertController(title: "Networking error", message: "The Wunderlist server cannot be reached", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "Try Again", style: .Default, handler: {_ in self.tryLogin()    })
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func login(sender: UIButton!)    {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.wunderlist.com/oauth/authorize?client_id=f7dff4e1225dc1459172&redirect_uri=http://restock.thinkcarl.com/redirect&state=NOTRANDOM")!)
    }
    
    func layoutSubviews() {
        self.view.layoutSubviews()
        wunderlistButton.setRoundedCorners(.AllCorners, radius: 2.0)
    }
    
    func enableLoginButton()    {
        wunderlistButton.setTitle("Login with Wunderlist", forState: .Normal)
        activityIndicator.stopAnimating()
        wunderlistButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func performSegueToScanView() {
        SBSLicense.setAppKey(Constants.ScanditBarcodeScannerAppKey)
        let scanViewController = ScanViewController()
        scanViewController.startScanning()
        let navigationViewController = UINavigationController(rootViewController: scanViewController)
        self.presentViewController(navigationViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}