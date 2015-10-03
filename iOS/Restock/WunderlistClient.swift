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
    
    static var groceryListId : Int? = {
        return NSUserDefaults.standardUserDefaults().integerForKey("groceryListId")
    }()
    static var accessToken : String? = nil
    
    static let sharedInstance = WunderlistClient()

    static var loginParameters : [String: String] {
        get {
            return ["X-Access-Token": self.accessToken!, "X-Client-ID": Constants.WunderlistClientId]
        }
    }
    
    class func findAndSaveGroceriesList()    {
        Alamofire.request(.GET, "http://restock.thinkcarl.com/listId", parameters: ["access_token": self.accessToken!])
            .responseJSON { (_,_, result) in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    if let id = json["id"].int  {
                        self.groceryListId = id
                        NSUserDefaults.standardUserDefaults().setInteger(id, forKey: "groceryListId")
                        NSLog("Got list id \(id)")
                    }
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
                        let user = json["name"].string
                        NSLog("Logged in as user \(user)");
                        callback(user != nil)
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
                    WunderlistClient.findAndSaveGroceriesList()
                }
            case .Failure(let error):
                NSLog("Failure \(error)")
            }
        }
    }
    
    static var lastProduct : Int?
    
    class func addProduct(product: Product) {
        lastProduct = nil
        let values = ["list_id": self.groceryListId!,
        "title": product.name ?? "Unnamed product"] as? [String : AnyObject]
        Alamofire.request(.POST, "https://a.wunderlist.com/api/v1/tasks", parameters: values, encoding: .JSON, headers: loginParameters).responseJSON  {
            (_,_, result) in
            print(result.value)
            switch result {
            case .Success(let data):
                let json = JSON(data)
                if let id = json["id"].int {
                    NSLog("Added task #\(id)")
                    lastProduct = id
                    // success callback maybe?
                }
            case .Failure(let error):
                NSLog("Failure \(error)")
            }
        }

    }
    
    class func removeLastAddedProduct() {
        if let id = lastProduct {
            Alamofire.request(.DELETE, "https://a.wunderlist.com/api/v1/tasks/\(id)", headers: loginParameters)
            NSLog("Deleting task #\(id)")
        }
    }
}
