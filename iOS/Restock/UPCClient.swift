//
//  UPCClient.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import Foundation
import Alamofire

class UPCClient: NSObject {
    static let URL = "http://eandata.com/feed/"
    
    class func getProduct(upc: String, completion: (Product?, ErrorType?) -> ()) {
        let paramters = [
            "v" : "3",
            "keycode": Constants.EandataKeycode,
            "mode" : "json",
            "find" : upc
        ]
        Alamofire.request(.GET, UPCClient.URL, parameters: paramters, encoding: .URL, headers: nil)
            .responseJSON { (_, _, result) -> Void in
                switch result {
                case .Success(let JSON):
                    let product = Product(upc: upc)
                    product.name = JSON.valueForKeyPath("product")?.valueForKeyPath("attributes")?.valueForKeyPath("product") as? String
                    product.customDescription = JSON.valueForKeyPath("product")?.valueForKeyPath("attributes")?.valueForKeyPath("description") as? String
                    completion(product, nil)
                case .Failure(_, let error):
                    completion(nil, error)
                }
        }
    }
}
