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
    static let URL = "https://api.outpan.com/v1/products/"
    
    class func getProduct(upc: String) {
        Alamofire.request(.GET, UPCClient.URL + upc)
            .responseJSON { (_, _, result) -> Void in
                print(result)
        }
    }
}
