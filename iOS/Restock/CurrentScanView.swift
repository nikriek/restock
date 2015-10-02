//
//  CurrentScanHeaderView.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import SnapKit
import QuartzCore

class CurrentScanView: UIView, UITableViewDelegate, UITableViewDataSource {
    private let RecommendationTableViewCellIdentifier = "recommendationTableViewCellIdentifier"
    
    let undoButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Undo", forState: .Normal)
        button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    let blurredBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    convenience init() {
        self.init(frame:CGRectZero)
        self.addSubview(self.blurredBackgroundView)
        self.addSubview(self.undoButton)
        self.addSubview(self.label)
        self.addSubview(self.tableView)

        
        self.blurredBackgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.height.equalTo(Constants.GridHeight*2)
            make.left.equalTo(self.snp_left).offset(Constants.GridWidth)
            make.right.equalTo(self.snp_right).offset(-1 * Constants.GridWidth)
        }
        
        self.label.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.blurredBackgroundView.snp_top)
            make.bottom.equalTo(self.blurredBackgroundView.snp_bottom)
            make.left.equalTo(self.blurredBackgroundView).offset(Constants.GridWidth)
            make.right.greaterThanOrEqualTo(self.blurredBackgroundView.snp_centerX)
            make.rightMargin.equalTo(Constants.GridWidth * 2)
        }
        
        self.undoButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.blurredBackgroundView.snp_top).offset(Constants.GridHeight/2)
            make.bottom.equalTo(self.blurredBackgroundView.snp_bottom).offset(-1 * Constants.GridHeight/2)
            make.right.equalTo(self.blurredBackgroundView.snp_right).offset(-1 * Constants.GridWidth)
            make.width.equalTo(Constants.GridWidth * 6)
        }
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.snp_bottom)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.top.equalTo(self.blurredBackgroundView.snp_bottom)
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerClass(RecommendationTableViewCell.self, forCellReuseIdentifier: RecommendationTableViewCellIdentifier)

    }
    
    func setProductTitleName(name: String) {
        let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(17)]
        let attributedString = NSMutableAttributedString(string:name, attributes:attrs)
        let addedString = NSMutableAttributedString(string:" added")

        attributedString.appendAttributedString(addedString)
        self.label.attributedText = attributedString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurredBackgroundView.setRoundedCorners([.TopLeft, .TopRight    ], radius: Constants.GridWidth)
        undoButton.setRoundedCorners(.AllCorners, radius: 2.0)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(RecommendationTableViewCellIdentifier, forIndexPath: indexPath) as? RecommendationTableViewCell
        
        if cell == nil {
            cell = RecommendationTableViewCell()
        }
        
        return cell!
    }

}
