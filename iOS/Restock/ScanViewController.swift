//
//  ViewController.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit

class ScanViewController: SBSBarcodePicker, SBSScanDelegate {

    let currentScanView = CurrentScanView()
    var currentProduct: Product?
    let wunderlistClient = WunderlistClient()
    
    init() {
        super.init(settings:SBSScanSettings.pre47DefaultSettings())
        self.scanDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(currentScanView)
        currentScanView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.top.equalTo(self.view.snp_bottom).offset(-1 * Constants.GridHeight * 2)
            make.height.equalTo(Constants.GridHeight*10)
        }
        currentScanView.undoButton.addTarget(self, action: "clickedUndo", forControlEvents: .TouchUpInside)
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        swipeGestureRecognizer.direction = [.Up, .Down]
        currentScanView.addGestureRecognizer(swipeGestureRecognizer)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture:")
        currentScanView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barcodePicker(picker: SBSBarcodePicker!, didScan session: SBSScanSession!) {
        let recognized = session.newlyRecognizedCodes
        let code = recognized.last as! SBSCode
        print(code.data)
        UPCClient.getProduct(code.data) { (product, error) -> () in
            self.currentProduct = product
            if let name = self.currentProduct?.name {
                dispatch_async(dispatch_get_main_queue(), {
                    self.currentScanView.setProductTitleName(name)
                })
            }
        }
        
        
    }

    func clickedUndo() {
        
    }
    
    func handleGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            default:
                break
            }
        } else if let tapGesture = gesture as? UITapGestureRecognizer {
            if tapGesture.state == .Ended {
                
            }
        }
    }

}

