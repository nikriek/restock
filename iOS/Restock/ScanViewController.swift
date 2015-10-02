//
//  ViewController.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit

class ScanViewController: SBSBarcodePicker, SBSScanDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    let RecommendationTableViewCellIdentifier = "recommendationTableViewCellIdentifier"
    let CurrentScanNotificationViewIdentifier = "currentScanNotificationViewIdentifier"
    
    init() {
        super.init(settings:SBSScanSettings.pre47DefaultSettings())
        self.scanDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view.snp_bottom)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.top.equalTo(self.view.snp_centerY)
        }
        tableView.contentInset = UIEdgeInsetsMake(self.view.frame.size.height - Constants.GridHeight * 4, 0, 0, 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerClass(RecommendationTableViewCell.self, forCellReuseIdentifier: RecommendationTableViewCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barcodePicker(picker: SBSBarcodePicker!, didScan session: SBSScanSession!) {
        let recognized = session.newlyRecognizedCodes
        let code = recognized[0] as! SBSCode
        print(code.data)
        /*NSArray* recognized = session.newlyRecognizedCodes;
        SBSCode *code = [recognized firstObject];
        // add your own code to handle the barcode result e.g.
        NSLog(@"scanned %@ barcode: %@", code.symbology, code.data);*/
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CurrentScanNotificationViewIdentifier) as? CurrentScanNotificationView
        if view == nil {
            view = CurrentScanNotificationView()
        }
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.GridHeight * 2
    }


}

