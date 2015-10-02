//
//  Product.swift
//  Restock
//
//  Created by Niklas Riekenbrauck on 02.10.15.
//  Copyright © 2015 Niklas Riekenbrauck. All rights reserved.
//

import Foundation

class Product: NSObject {
    var upc: String!
    
    init(upc: String) {
        super.init()
        self.upc = upc
    }
    
}
