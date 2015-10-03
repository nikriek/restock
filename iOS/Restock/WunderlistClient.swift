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

/*
class WunderlistClient: NSObject {
    
    var groceryListId : Int? = nil
    var accessToken : String = ""

    var loginParameters : [String: String] {
        get {
            return ["X-Access-Token": accessToken, "X-Client-ID": Constants.WunderlistClientId]
        }
    }
    
    func findGroceriesList()    {
        Alamofire.request(.GET, "http://restock.thinkcarl.com/listId", parameters: loginParameters)
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
    
    func login()    {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.wunderlist.com/oauth/authorize?client_id=f7dff4e1225dc1459172&redirect_uri=http://restock.thinkcarl.com/redirect&state=NOTRANDOM")!)
    }
    
    func completeLogin(code: String)    {
        let parameters = ["client_id": Constants.WunderlistClientId,
            "client_secret": Constants.WunderlistClientSecret,
            "code": code]
        Alamofire.request(.POST, "https://www.wunderlist.com/oauth/access_token", parameters: parameters).responseJSON  {
            (_,_, result) in
            switch result {
            case .Success(let data):
                let json = JSON(data)
                self.accessToken = json["access_token"].stringValue
            case .Failure(let error):
                NSLog("Failure \(error)")
            }
        }
    }
    
    func addProduct(product: Product) {
        
    }
    
    func removeLastAddedProduct() {
        
    }
}*/
