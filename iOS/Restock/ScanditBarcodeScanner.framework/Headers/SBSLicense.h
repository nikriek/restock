//
//  SBSLicense.h
//  ScanditBarcodeScanner
//
//  Created by Moritz Hartmeier on 28/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSLicense : NSObject

/**
 * \brief Set the Barcode Scanner application key to be used for this application
 *
 * Call this static method with the Scandit Barcode Scanner application key you downloaded 
 * from the Scandit website.  
 *
 * \param appKey the application key.
 * \since 4.7.0
 */
+ (void)setAppKey:(NSString *)appKey;

@end
