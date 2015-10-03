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
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(Constants.GridWidth)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_top)
            make.width.equalTo(self.contentView.snp_height)
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
