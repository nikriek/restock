//
//  RecommendationClient.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 03.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import Foundation
import Alamofire

class RecommendationClient: NSObject {
    static let url = "http://restock.nico.is/recommendations/"
/*
    class func addProduct(product: Product, completion: (Bool, ErrorType?) -> ()) {
        
        let parameters = [
            "user_id" : RecommendationClient.getUserID(),
            "upc" : product.upc
        ]
        Alamofire.request(.POST, RecommendationClient.url, parameters: parameters, encoding: .JSON, headers: nil).validate().responseJSON { (_, _, result) -> Void in
            switch result {
            case .Success(_):
                completion(true, nil)
            case .Failure(_, let error):
                completion(false, error)
            }
        }
    }
    
    
    
    private func getUserID() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var userID = userDefaults.stringForKey("user_id")
        if userID  == nil {
            userID = NSUUID().UUIDString
            userDefaults.setObject(userID, forKey: "user_id")
        }
        return userID!
    }*/
}
