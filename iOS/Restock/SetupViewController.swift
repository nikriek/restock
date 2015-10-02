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
        button.setTitle("Login with Wunderlist", forState: .Normal)
        button.backgroundColor = UIColor(red: 219/255, green: 76/255, blue: 63/255, alpha: 1)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(wunderlistButton)
        wunderlistButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(Constants.GridWidth * 4)
            make.right.equalTo(self.view).offset(-1 * Constants.GridWidth * 4)
            make.bottom.equalTo(self.view).offset(-1 * Constants.GridHeight * 4)
            make.height.equalTo(Constants.GridHeight * 2)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}