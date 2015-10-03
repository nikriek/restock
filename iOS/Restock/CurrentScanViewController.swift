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
import Alamofire


class CurrentScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let CouponTableViewCellIdentifier = "CouponTableViewCellIdentifier"
    private let CouponHeaderViewIdentifier = "CouponHeaderViewIdentifier"
    
    var recommendProducts: [Product] = []
    var currentProduct: Product? {
        didSet {
            if let name = self.currentProduct?.name {
                dispatch_async(dispatch_get_main_queue(), {
                    self.setProductTitleName(name)
                    self.toggleUndoButton()
                })
            } else if let upc = self.currentProduct?.upc {
                dispatch_async(dispatch_get_main_queue(), {
                    self.setProductTitleName(upc)
                    self.toggleUndoButton()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.setProductTitleName(nil)
                })
            }
            
            
            // Add after 3 sec if product is present
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let product = self.currentProduct {
                    self.recommendProducts.append(product)
                    
                    print("Add \(product.name)")
                    self.resetProduct()
                }
            }
        }
    }
    
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
        let tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        self.view.addSubview(self.blurredBackgroundView)
        self.view.addSubview(self.undoButton)
        self.view.addSubview(self.label)
        self.view.addSubview(self.tableView)
        
        
        self.blurredBackgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.snp_top)
            make.height.equalTo(Constants.GridHeight*2)
            make.left.equalTo(self.view.snp_left).offset(Constants.GridWidth)
            make.right.equalTo(self.view.snp_right).offset(-1 * Constants.GridWidth)
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
            make.bottom.equalTo(self.view.snp_bottom)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.top.equalTo(self.blurredBackgroundView.snp_bottom)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CouponTableViewCellIdentifier)
        tableView.registerClass(HeaderView.self, forHeaderFooterViewReuseIdentifier: CouponHeaderViewIdentifier)
        
        let tableFooterView = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, Constants.GridHeight * 4))
        tableFooterView.text = "No coupons found"
        tableFooterView.textColor = UIColor.lightGrayColor()
        tableFooterView.textAlignment = .Center
        self.tableView.tableFooterView = tableFooterView
        
        self.currentProduct = nil
        self.undoButton.addTarget(self, action: "clickedUndo", forControlEvents: .TouchUpInside)
        toggleUndoButton()
        
        
    }
    
    func setProductTitleName(name: String?) {
        if let name = name {
            let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(17)]
            let attributedString = NSMutableAttributedString(string:name, attributes:attrs)
            let addedString = NSMutableAttributedString(string:" added")
            
            attributedString.appendAttributedString(addedString)
            self.label.attributedText = attributedString
        } else {
            self.label.text = "Scan your product"
        }
    }
    
    func layoutSubviews() {
        self.view.layoutSubviews()
        blurredBackgroundView.setRoundedCorners([.TopLeft, .TopRight], radius: Constants.GridWidth)
        undoButton.setRoundedCorners(.AllCorners, radius: 2.0)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendProducts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CouponTableViewCellIdentifier, forIndexPath: indexPath)
        
        let product = recommendProducts[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = product.name
        if let url = product.imageUrl {
            Alamofire.request(.GET, url).validate().responseData({ (_, _, result) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let tempCell = self.tableView.cellForRowAtIndexPath(indexPath) {
                        switch result {
                        case .Success(let imageDate):
                            let image = UIImage(data: imageDate)
                            tempCell.imageView?.image = image
                        default: break
                        }
                    }
                })
            })
        }
        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CouponHeaderViewIdentifier) as?HeaderView
        if view == nil {
            view = HeaderView(reuseIdentifier: CouponHeaderViewIdentifier)
        }
        view?.label.text = "Coupons"
        view?.iconImageView.image = UIImage(named: "Coupons")
        return view!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.GridHeight * 2
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func resetProduct() {
        currentProduct = nil
        self.setProductTitleName(nil)
        toggleUndoButton()
    }
    
    func clickedUndo() {
        self.resetProduct()
    }
    
    func toggleUndoButton() {
        self.undoButton.hidden = (self.currentProduct == nil)
    }
    
}
