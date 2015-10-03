//
//  WunderlistClient.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WunderlistClient: NSObject {
    
    static var groceryListId : Int? = nil
    static var accessToken : String? = nil
    

    static var loginParameters : [String: String] {
        get {
            return ["X-Access-Token": self.accessToken!, "X-Client-ID": Constants.WunderlistClientId]
        }
    }
    
    class func findGroceriesList()    {
        Alamofire.request(.GET, "http://restock.thinkcarl.com/listId", headers: loginParameters)
            .responseJSON { (_,_, result) in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    self.groceryListId = json["id"].int
                case .Failure(let error):
                    NSLog("Failure \(error)")
                }
                
                
        }
    }
    
    class func testLoginStatus(callback: Bool -> (), onFailure: () -> ())  {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let token = defaults.stringForKey("accessToken")
        {
            self.accessToken = token
            Alamofire.request(.GET, "http://a.wunderlist.com/api/v1/user", headers: ["X-Client-ID": Constants.WunderlistClientId, "X-Access-Token": token])
                .responseJSON { (_,_, result) in
                    switch result {
                    case .Success(let data):
                        let json = JSON(data)
                        callback(json["name"].string != nil)
                    case .Failure(let (_,error) ):
                        NSLog(String(error))
                        onFailure()
                    }
            }
            
        }   else    {   callback(false) }
    }
    
    func login()    {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.wunderlist.com/oauth/authorize?client_id=f7dff4e1225dc1459172&redirect_uri=http://restock.thinkcarl.com/redirect&state=NOTRANDOM")!)
    }
    
    class func completeLogin(code: String)    {
        let parameters = ["client_id": Constants.WunderlistClientId,
            "client_secret": Constants.WunderlistClientSecret,
            "code": code]
        Alamofire.request(.POST, "https://www.wunderlist.com/oauth/access_token", parameters: parameters).responseJSON  {
            (_,_, result) in
            switch result {
            case .Success(let data):
                let json = JSON(data)
                if let token = json["access_token"].string {
                    self.accessToken = token
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "accessToken")
                }
            case .Failure(let error):
                NSLog("Failure \(error)")
            }
        }
    }
    
    func addProduct(product: Product) {
        
    }
    
    func removeLastAddedProduct() {
        
    }
}
