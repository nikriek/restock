//
//  MoreViewController.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 03.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(blurEffectView)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        var bounds = self.navigationController?.navigationBar.bounds as CGRect!
        bounds.origin.y = -UIApplication.sharedApplication().statusBarFrame.size.height
        bounds.size.height += UIApplication.sharedApplication().statusBarFrame.size.height
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.navigationController?.navigationBar.addSubview(visualEffectView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: "clickedClose")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickedClose() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
