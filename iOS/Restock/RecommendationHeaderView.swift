//
//  RecommendationHeaderView.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 03.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import SnapKit

class RecommendationHeaderView: UITableViewHeaderFooterView {
    let iconImageView = UIImageView(image: UIImage(named: ""))
    
    let label: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.text = "Recommendations"
        return label
    }()
    
    convenience init() {
        self.init(frame:CGRectZero)
        
        self.contentView.addSubview(self.iconImageView)
        self.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(Constants.GridWidth)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_top)
            make.width.equalTo(self.contentView.snp_height)
        }
        self.contentView.addSubview(self.label)
        self.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.iconImageView.snp_right).offset(Constants.GridWidth)
            make.right.equalTo(self.contentView.snp_right).offset(-1 * Constants.GridWidth)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
    }
}
