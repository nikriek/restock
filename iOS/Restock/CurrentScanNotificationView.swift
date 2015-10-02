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

class CurrentScanNotificationView: UITableViewHeaderFooterView {

    let undoButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Undo", forState: .Normal)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    let blurredBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        
        return view
    }()
    
    convenience init() {
        self.init(frame:CGRectZero)
        self.addSubview(self.blurredBackgroundView)
        self.addSubview(self.undoButton)
        self.addSubview(self.label)
        
        self.blurredBackgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(self.snp_bottom)
            make.left.equalTo(self.snp_left).offset(Constants.GridWidth)
            make.right.equalTo(self.snp_right).offset(-1 * Constants.GridWidth)
        }
        
        self.label.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(self.snp_bottom)
            make.left.equalTo(self.snp_left).offset(Constants.GridWidth * 2)
            make.right.greaterThanOrEqualTo(self.snp_centerX)
        }
        
        self.undoButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top).offset(Constants.GridHeight/2)
            make.bottom.equalTo(self.snp_bottom).offset(-1 * Constants.GridHeight/2)
            make.right.equalTo(self.snp_right).offset(-1 * Constants.GridWidth * 2)
            make.width.equalTo(Constants.GridWidth * 6)
        }
    }
    
    func setProductTitleName(name: String) {
        let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(17)]
        let attributedString = NSMutableAttributedString(string:name, attributes:attrs)
        let addedString = NSMutableAttributedString(string:" added")

        attributedString.appendAttributedString(addedString)
        self.label.attributedText = attributedString
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
