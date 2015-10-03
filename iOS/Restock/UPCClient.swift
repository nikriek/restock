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
    static let URL = "http://restock.nico.is/api.php"
    
    class func getProduct(upc: String, completion: (Product?, ErrorType?) -> ()) {
        let paramters = [
            "q" : upc
        ]
        Alamofire.request(.GET, UPCClient.URL, parameters: paramters, encoding: .URL, headers: nil)
            .responseJSON { (_, _, result) -> Void in
                switch result {
                case .Success(let JSON):
                    print(JSON)
                    let product = Product(upc: upc)
                    product.name = JSON.valueForKeyPath("title") as? String
                    product.imageUrl = JSON.valueForKeyPath("image") as? String
                    product.amount = JSON.valueForKeyPath("amount") as? String
                    completion(product, nil)
                case .Failure(_, let error):
                    print(error)
                    completion(nil, error)
                }
        }
    }
}
