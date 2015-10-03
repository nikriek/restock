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
    
    let wunderlistButton: UIButton = {
        let button = UIButton(type: .Custom)
        //button.setTitle("Loading...", forState: .Normal)
        button.backgroundColor = UIColor(red: 219/255, green: 76/255, blue: 63/255, alpha: 1)
        return button
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Icon"))
        imageView.contentMode = .Center
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Restock"
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(25)
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hungry?\n\n1. Scan it.\n2. Put it on your todo list.\n3. Get coupons."
        label.numberOfLines = 6
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
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
        
        self.view.addSubview(iconImageView)
        iconImageView.snp_makeConstraints { (make) -> Void in
            make.top.top.equalTo(self.view.snp_top).offset(Constants.GridHeight * 4)
            make.left.equalTo(self.view.snp_left).offset(Constants.GridWidth * 2)
            make.right.equalTo(self.view.snp_right).offset(Constants.GridWidth * -2)
            make.height.equalTo(Constants.GridHeight * 4)
        }
        self.view.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.iconImageView.snp_bottom).offset(Constants.GridHeight)
            make.left.equalTo(self.view.snp_left).offset(Constants.GridWidth * 2)
            make.right.equalTo(self.view.snp_right).offset(Constants.GridWidth * -2)
            make.height.equalTo(Constants.GridHeight * 3)
        }
        
        self.view.addSubview(descriptionLabel)
        descriptionLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.titleLabel).offset(Constants.GridHeight * 2)
            make.left.equalTo(self.view.snp_left).offset(Constants.GridWidth * 6)
            make.right.equalTo(self.view.snp_right).offset(Constants.GridWidth * -6)
            make.height.equalTo(Constants.GridHeight * 5)
        }
        
        self.view.addSubview(wunderlistButton)
        wunderlistButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(Constants.GridWidth * 4)
            make.right.equalTo(self.view).offset(-1 * Constants.GridWidth * 4)
            make.bottom.equalTo(self.view).offset(-1 * Constants.GridHeight * 4)
            make.height.equalTo(Constants.GridHeight * 2)
        }
        wunderlistButton.setTitle("Login with Wunderlist", forState: .Normal)
        wunderlistButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func login(sender: UIButton!)    {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.wunderlist.com/oauth/authorize?client_id=f7dff4e1225dc1459172&redirect_uri=http://restock.thinkcarl.com/redirect&state=NOTRANDOM")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.layoutSubviews()
    }
    
    func layoutSubviews() {
        self.view.layoutSubviews()
        wunderlistButton.setRoundedCorners(.AllCorners, radius: 4.0)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}