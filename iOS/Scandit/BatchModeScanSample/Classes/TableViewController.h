//
//  Copyright 2010 Mirasense AG
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  TableViewController shows how to use the Mirasense ScanDK.
//
//  Any view controller that triggers the ScanDK barcode scanning needs to implement the
//  ScanDKOverlayControllerDelegate protocol. It also needs to instantiate the ScanDKBarcodePicker
//  and present the ScanDKBarcodePicker modally. See showScanView method of TableViewController for
//  more details.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

@class ScanDKBarcodePicker;
@class IASKAppSettingsViewController;

@interface TableViewController : UITableViewController<SBSScanDelegate> {

    NSString *appKey;

    CLLocationManager *locationManager;
    
    UIButton *scanButton;
    NSInteger selectionMode;
    BOOL volumeButtonEnable;
    UIImage *blueLine;
    UIImage *whiteLine;
    NSTimer *timerStopScanning;
    NSTimer *timerHideBubble;
    UIView *bubble;
    UILabel *dinamLabel;
    UIButton *cancelButton;
    UIButton *confirmButton;
    IASKAppSettingsViewController *settingsController;
    
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) SBSBarcodePicker *scanditBarcodePicker;
@property (nonatomic, retain) IASKAppSettingsViewController *settingsController;


@property (nonatomic, retain) UIView *bubble;
@property (nonatomic, retain) NSTimer *timerStopScanning;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *confirmButton;
@property (nonatomic, retain) UIButton *scanButton;
@property (nonatomic, retain) UILabel *dinamLabel;
@property (nonatomic, retain) NSTimer *timerHideBubble;

@end