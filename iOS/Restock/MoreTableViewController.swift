//
//  MoreTableViewController.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 03.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit

class MoreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView.backgroundColor = UIColor.clearColor()
        return tableView
    }()
    
    let HeaderViewIdentifier = "headerViewIdentifier"
    let CellIdentifier = "cellIdentifier"
    
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
        self.navigationItem.title = "More"

        self.view.addSubview(self.tableView)
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.snp_top).offset((self.navigationController?.navigationBar.frame.size.height)! +
                UIApplication.sharedApplication().statusBarFrame.size.height)
            make.bottom.equalTo(self.view.snp_bottom)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
        let tableFooterView = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, Constants.GridHeight * 6))
        tableFooterView.text = "Restock – A hack from HackZurich 2015\n\nMade by Nico Knoll, Carl Gödecken, Daniel Theveßen & Niklas Riekenbrauck\n\nPowered by Icons8, Scandit, Wunderlist, Merit"
        tableFooterView.numberOfLines = 6
        tableFooterView.textColor = UIColor.lightGrayColor()
        tableFooterView.textAlignment = .Center
        self.tableView.tableFooterView = tableFooterView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickedClose() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.GridHeight * 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewIdentifier) as?HeaderView
        if view == nil {
            view = HeaderView(reuseIdentifier: HeaderViewIdentifier)
        }
        if (section == 0) {
            view?.label.text = "Recently added"
            view?.iconImageView.image = UIImage(named: "Clock")
        } else if (section == 1) {
            view?.label.text = "Coupons"
            view?.iconImageView.image = UIImage(named: "Coupon")
        }
        
        return view!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.GridHeight * 2
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
