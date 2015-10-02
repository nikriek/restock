//
//  WunderlistClient.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import UIKit
import Alamofire

class WunderlistClient: NSObject {
    
    var groceryListId : String
    var accessToken : String = ""
    
    var loginParameters = ["X-Access-Token": accessToken, "X-Client-ID": Constants.WunderlistClientId]
    
    func findGroceriesList()    {
        Alamofire.request(.GET, "http://restock.thinkcarl.com/listId", parameters: loginParameters)
            .responseJSON { response in
                if let idString = response["id"], id = Int(idString)    {
                    groceryListId = id
                }   else {
                    print("Error parsing list id")
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
            response in
            if let token = response["access_token"] as? String  {
                accessToken = token
            }
        }
    }
    
    func addProduct(product: Product) {
        
    }
    
    func removeLastAddedProduct() {
        
    }
}
