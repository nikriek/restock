//
// Copyright 2015 Scandit AG
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing permissions and
// limitations under the License.
//

//
// MainExampleViewController shows how to use the Scandit Barcode Scanner SDK
//
// Any view controller that would like to scan barcodes using the Scandit Barcode Scanner, needs
// to instantiate the SBSBarcodePicker. The picker is a UIViewController and can therefore be used
// like any other view controller. It can be shown modally, directly as the starting view, in a
// tab bar controller, pushed on a navigation controller etc. The class that wants to listen to the
// picker's events needs to implement the SBSScanDelegate protocol.
//
// Examples for the most common usage scenarios are shown below.
//


#import "MainExampleViewController.h"

#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

#import "PickerResultViewController.h"


@interface MainExampleViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) SBSBarcodePicker *scanditBarcodePicker;
@property (nonatomic, strong) PickerResultViewController *resultOverlay;
@end


@implementation MainExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Location tracking to demonstrate Scandit's Scanalytics feature (optional)
    // The Scandit Barcode Scanner will only gather the location if the user already allowed
    // the app using the SDK to gather it.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}


#pragma mark - Showing the SBSBarcodePicker in a UITabBarController

//! [SBSBarcodePicker in its own tab]
/**
 * This is a simple example of how one can start the SBSBarcodePicker in its own tab.
 */
- (IBAction)showScanViewInTab {
    
	// Instantiate the barcode picker using the settings defined by the user.
    
	// To change the allowed orientations you will have to set those in the TabBarController
	// (which contains the picker as a tab)
    self.scanditBarcodePicker = [[SBSBarcodePicker alloc]
                                 initWithSettings:[self currentScanSettings] ];
    
	// Set all the settings as they were set in the settings tab.
    [self setAllSettingsOnPicker:self.scanditBarcodePicker];
    
	// Set the delegate to receive "barcode scanned" callbacks.
	self.scanditBarcodePicker.scanDelegate = self;
    
    // Create a tab item for the picker, possibly with an icon.
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"Scan" 
                                                          image:[UIImage imageNamed:@"icon_barcode.png"]
                                                            tag:3];
    self.scanditBarcodePicker.tabBarItem = tabItem;
	
    // Add the picker to the array of view controllers that make up the tabs.
    NSMutableArray *tabControllers = (NSMutableArray *) [[self tabBarController] viewControllers];
    [tabControllers addObject:self.scanditBarcodePicker];
    // And set the array as the tab bar controllers source of tabs again.
    [[self tabBarController] setViewControllers:tabControllers];
    
    // Switch to the fourth tab, where the picker is located and start scanning.
    [[self tabBarController] setSelectedIndex:3];
	[self.scanditBarcodePicker startScanning];
}
//! [SBSBarcodePicker in its own tab]


- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
	
    if (tabBarController.selectedIndex != 3) {
        // Stop and dereference the picker.
        [self.scanditBarcodePicker stopScanning];
        self.scanditBarcodePicker = nil;
        
        // We close the scan tab whenever the user goes to any other tab because we can at no point
		// have two pickers up at once (as only one camera instance can run).
        NSMutableArray *tabControllers = (NSMutableArray *) tabBarController.viewControllers;
        if ([tabControllers count] > 3) {
            [tabControllers removeLastObject];
            tabBarController.viewControllers = tabControllers;
        }
    }
}

/**
 * Constructs and returns SBSScanSettings instance based on the current user settings.
 */
- (SBSScanSettings*)currentScanSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // Configure the barcode picker through a scan settings instance by defining which
    // symbologies should be enabled.
    SBSScanSettings* scanSettings = [SBSScanSettings defaultSettings];
    
    // prefer backward facing camera over front-facing cameras.
    scanSettings.cameraFacingPreference = SBSCameraFacingDirectionBack;
    
    // enable/disable 1D symbologies based on the current settings
    [scanSettings setSymbology:SBSSymbologyEAN13
                       enabled:[settings boolForKey:@"ean13AndUpc12Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyUPC12
                       enabled:[settings boolForKey:@"ean13AndUpc12Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyEAN8
                       enabled:[settings boolForKey:@"ean8Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyUPCE
                       enabled:[settings boolForKey:@"upceEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyTwoDigitAddOn
                       enabled:[settings boolForKey:@"twoDigitAddOnEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyFiveDigitAddOn
                       enabled:[settings boolForKey:@"fiveDigitAddOnEnabled"]];

    [scanSettings setSymbology:SBSSymbologyCode39
                       enabled:[settings boolForKey:@"code39Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyCode93
                       enabled:[settings boolForKey:@"code93Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyCode128
                       enabled:[settings boolForKey:@"code128Enabled"]];
    
    [scanSettings setSymbology:SBSSymbologyMSIPlessey
                       enabled:[settings boolForKey:@"msiPlesseyEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyITF
                       enabled:[settings boolForKey:@"itfEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyCodabar
                       enabled:[settings boolForKey:@"codabarEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyGS1Databar
                       enabled:[settings boolForKey:@"dataBarEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyGS1DatabarExpanded
                       enabled:[settings boolForKey:@"dataBarExpandedEnabled"]];
    
    // enable/disable 2D symbologies based on the current settings
    [scanSettings setSymbology:SBSSymbologyQR
                       enabled:[settings boolForKey:@"qrEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyAztec
                       enabled:[settings boolForKey:@"aztecEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyDatamatrix
                       enabled:[settings boolForKey:@"dataMatrixEnabled"]];
    
    [scanSettings setSymbology:SBSSymbologyPDF417
                       enabled:[settings boolForKey:@"pdf417Enabled"]];
    
    NSInteger selectedChecksum = [settings integerForKey:@"msiPlesseyChecksum"];
    
    SBSChecksum checksum = SBSChecksumMod10;
    if (selectedChecksum == 0) {
        checksum = SBSChecksumNone;
    } else if (selectedChecksum == 2) {
        checksum = SBSChecksumMod11;
    } else if (selectedChecksum == 3) {
        checksum = SBSChecksumMod1010;
    } else if (selectedChecksum == 4) {
        checksum = SBSChecksumMod1110;
    }
    NSSet *checksums = [NSSet setWithObject:[NSNumber numberWithInteger:checksum]];
    [scanSettings settingsForSymbology:SBSSymbologyMSIPlessey].checksums = checksums;
    
    if ([settings boolForKey:@"dataMatrixEnabled"]) {
        SBSSymbologySettings *dataMatrixSettings =
        [scanSettings settingsForSymbology:SBSSymbologyDatamatrix];
        dataMatrixSettings.colorInvertedEnabled = [settings boolForKey:@"inverseDetectionEnabled"];
        [dataMatrixSettings setExtension:SBSSymbologySettingsExtensionTiny
                                 enabled:[settings boolForKey:@"microDataMatrixEnabled"]];
    }
    scanSettings.restrictedAreaScanningEnabled = [settings boolForKey:@"restrictActiveScanningArea"];
    CGPoint hotSpot = CGPointMake([settings floatForKey:@"scanningHotSpotX"],
                                  [settings floatForKey:@"scanningHotSpotY"]);
    scanSettings.scanningHotSpot = hotSpot;
    if (scanSettings.restrictedAreaScanningEnabled) {
        float height = [settings floatForKey:@"scanningHotSpotHeight"];
        CGRect activeScanArea = CGRectMake(0.0f, hotSpot.y - height * 0.5f, 1.0f, height);
        [scanSettings setActiveScanningArea:activeScanArea];
    }
    if ([settings boolForKey:@"twoDigitAddOnEnabled"] ||
        [settings boolForKey:@"fiveDigitAddOnEnabled"]) {
        scanSettings.maxNumberOfCodesPerFrame = MAX(2, scanSettings.maxNumberOfCodesPerFrame);
    }
    return scanSettings;

}

- (void)setAllSettingsOnPicker:(SBSBarcodePicker *)picker {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[picker.overlayController drawViewfinder:[settings boolForKey:@"drawViewfinder"]];
	[picker.overlayController setViewfinderHeight:[settings floatForKey:@"viewfinderHeight"]
											width:[settings floatForKey:@"viewfinderWidth"]
								  landscapeHeight:[settings floatForKey:@"viewfinderLandscapeHeight"]
								   landscapeWidth:[settings floatForKey:@"viewfinderLandscapeWidth"]];
	
	[picker.overlayController setBeepEnabled:[settings boolForKey:@"beepEnabled"]];
	[picker.overlayController setVibrateEnabled:[settings boolForKey:@"vibrateEnabled"]];
	
	[picker.overlayController setTorchEnabled:[settings boolForKey:@"torchEnabled"]];
	[picker.overlayController setTorchButtonLeftMargin:[settings integerForKey:@"torchButtonLeftMargin"]
                                             topMargin:[settings integerForKey:@"torchButtonTopMargin"]
                                                 width:40
                                                height:40];
	
    SBSCameraSwitchVisibility cameraSwitchVisibility = SBSCameraSwitchVisibilityNever;
	if ([settings integerForKey:@"cameraSwitchVisibility"] == 1) {
		cameraSwitchVisibility = SBSCameraSwitchVisibilityOnTablet;
	} else if ([settings integerForKey:@"cameraSwitchVisibility"] == 2) {
		cameraSwitchVisibility = SBSCameraSwitchVisibilityAlways;
	}
	[picker.overlayController setCameraSwitchVisibility:cameraSwitchVisibility];
	[picker.overlayController setCameraSwitchButtonRightMargin:[settings integerForKey:@"cameraSwitchButtonRightMargin"]
                                                     topMargin:[settings integerForKey:@"cameraSwitchButtonTopMargin"]
                                                         width:40
                                                        height:40];
}
	

#pragma mark - SBSScanDelegate

- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    [session pauseScanning];
    [self.resultOverlay hide];
    self.resultOverlay = [[PickerResultViewController alloc]
                          initWithNibName:@"PickerResultViewController" bundle:nil];
    
    [self.resultOverlay showCodes:session.newlyRecognizedCodes onPicker:self.scanditBarcodePicker];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];
}

@end
