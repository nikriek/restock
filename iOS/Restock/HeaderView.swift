//
//  CouponHeaderView.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 03.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import SnapKit

class HeaderView: UITableViewHeaderFooterView {
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .Center
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.contentView.snp_left).offset(Constants.GridWidth)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.width.equalTo(Constants.GridWidth * 2)
        }
        self.contentView.addSubview(self.label)
        self.label.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.iconImageView.snp_right).offset(Constants.GridWidth)
            make.right.equalTo(self.contentView.snp_right).offset(-1 * Constants.GridWidth)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
