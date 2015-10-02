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
//  TableViewController shows how to use the Mirasense Scandit SDK.
//
//  Any view controller that triggers the ScanditSDK barcode scanning, needs to instantiate the
//  scanditBarcodePicker. The picker is a UIViewController and can therefor be used like any
//  other view controller. It can be shown modally, directly as the starting view, in a tab bar
//  controller, pushed on a navigation controller etc. The class that wants to listen to the
//  picker's events needs to implement the ScanditSDKOverlayControllerDelegate protocol.
//

#import "TableViewController.h"
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

#import <ScanditBarcodeScanner/SBSLicense.h>
#import "BatchModeScanAppDelegate.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "IASKAppSettingsViewController.h"

@implementation TableViewController

@synthesize appKey;
@synthesize settingsController;
@synthesize scanButton;
@synthesize timerStopScanning;
@synthesize bubble;
@synthesize cancelButton;
@synthesize confirmButton;
@synthesize dinamLabel;
@synthesize timerHideBubble;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    // Update the UI such that it fits the new dimension.
    [self adjustPickerToOrientation:toInterfaceOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    settingsController = [[IASKAppSettingsViewController alloc] init];
    //Disable volume view
    CGRect rect = CGRectMake(-500, -500, 0, 0);
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: rect];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:volumeView];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.timerStopScanning isValid]) {
        [self.timerStopScanning invalidate];
    }
    [self.scanditBarcodePicker stopScanning];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.appKey = nil;
    self.scanditBarcodePicker = nil;
    self.scanButton = nil;
    self.timerStopScanning = nil;
    self.bubble = nil;
    self.cancelButton = nil;
    self.confirmButton = nil;
    self.dinamLabel = nil;
    self.timerHideBubble = nil;
}

- (void)adjustPickerToOrientation:(UIInterfaceOrientation)orientation {
    
    // Adjust the picker's frame, bounds and the offset of the info banner to fit the new dimensions.
    CGRect screen = [[UIScreen mainScreen] bounds];
    if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight) {
        if (self.scanButton) {
            self.scanButton.frame = CGRectMake(10, screen.size.height - 55, screen.size.width - 20, 50);
        }
       
    } else {
        if (self.scanButton) {
            self.scanButton.frame = CGRectMake(10, screen.size.height - 55 , screen.size.width - 20, 50);
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.scanditBarcodePicker) {
        if ([timerStopScanning isValid]) {
            [self.timerStopScanning invalidate];
        }
        // Stop and dereference the picker.
        [self.scanditBarcodePicker stopScanning];
        self.scanditBarcodePicker = nil;
    }
    
    //Scan mode options
    if (indexPath.section == 0) {
        /**
         * Barcode Selection modes
         * selectionMode = 0: Aim and Scan mode
         * selectionMode = 1: Scan and Confirm mode
         */
        selectionMode = indexPath.row;
        [self showScanView];
    } else {
        //Settings
        if (indexPath.row == 0) {
            settingsController.showDoneButton = NO;
            [[self navigationController] pushViewController:settingsController animated:YES];
        }
    }
}

- (void)showScanView {
    [SBSLicense setAppKey:self.appKey];

    self.scanditBarcodePicker =
        [[SBSBarcodePicker alloc] initWithSettings:[self currentScanSettings]];

    // Set all the settings as they were set in the settings tab.
    [self setAllSettingsOnPicker:self.scanditBarcodePicker];
    [self.scanditBarcodePicker.overlayController showToolBar:NO];

    // Set the delegate to receive callbacks.
    self.scanditBarcodePicker.scanDelegate = self;
    
    //! [Laser]
    [self.scanditBarcodePicker.overlayController setGuiStyle:SBSGuiStyleLaser];
     //! [Laser]
    [self.scanditBarcodePicker.overlayController setViewfinderDecodedColor:1.0 green:0.0 blue:0.0];
   
    [self.scanditBarcodePicker.overlayController setTorchEnabled:NO];
    
    //Aim and Scan mode
    if (selectionMode == 0) {
        [self setAimScanMode];
        self.scanditBarcodePicker.title= @"Aim and Scan";
    } else {
        //Scan and Confirm mode
        [self setScanConfirmMode];
        self.scanditBarcodePicker.title= @"Scan and Confirm";
    }
    [self adjustPickerToOrientation:self.interfaceOrientation];
   
    // Show the navigation bar such that we can press the back button.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Push the picker on the navigation stack.
    [[self navigationController] pushViewController:self.scanditBarcodePicker animated:YES];
}


//Set Aim and Scan mode
-(void) setAimScanMode {

    //! [StartPause]
    [self.scanditBarcodePicker startScanningInPausedState:YES];
    //! [StartPause]

    if (!volumeButtonEnable) {
        //! [Button Added]
        //Add scan button
        self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.scanButton setTitle:@"Scan barcode" forState:UIControlStateNormal];
        CGFloat red = 58/255.0, green = 194/255.0, blue = 205/255.0;
        [self.scanButton setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
        self.scanButton.layer.cornerRadius = 4.0f;
        [self.scanButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:20.0]];
        self.scanButton.frame = CGRectMake(0, 0, 0, 0);

        [self.scanditBarcodePicker.overlayController.view addSubview:self.scanButton];
        //! [Button Added]
        
         //! [Button Action]
        [self.scanButton addTarget:self
                            action:@selector(startScanWithButton)
                  forControlEvents:UIControlEventTouchUpInside];
          //! [Button Action]
    } else {
        //enable volume buttons notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangedToStart:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
}

- (void)volumeChangedToStart:(NSNotification *)notification {
    [self startScanWithButton];
}

- (void) startScanWithButton {
    if (!volumeButtonEnable) {
        [self.scanButton removeFromSuperview];
    }
     //! [Resume]
    [self.scanditBarcodePicker resumeScanning];
    //! [Resume]
    
    //Timer to stop scanner if no barcode is detected after 8 seconds
    self.timerStopScanning = [NSTimer scheduledTimerWithTimeInterval:8.0
                                                      target:self
                                                    selector:@selector(barcodeNotFound)
                                                    userInfo:nil
                                                    repeats:NO];
}

-(void) barcodeNotFound {
    [self.scanditBarcodePicker pauseScanning];
    [self restartAimAndScanMode];
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
    
    if ([settings boolForKey:@"twoDigitAddOnEnabled"] ||
        [settings boolForKey:@"fiveDigitAddOnEnabled"]) {
        scanSettings.maxNumberOfCodesPerFrame = MAX(2, scanSettings.maxNumberOfCodesPerFrame);
    }
    
    //! [Restrict Area]
    //Enable restrict area
    [scanSettings setActiveScanningArea:CGRectMake(0, 0.48, 1, 0.04)];
    //! [Restrict Area]
    
    return scanSettings;
    
}

- (void)setAllSettingsOnPicker:(SBSBarcodePicker *)picker {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    volumeButtonEnable = [settings boolForKey:@"enableVolumeButton"];
}

//Set Scan and Confirm mode
-(void) setScanConfirmMode {
    //! [Start]
    [self.scanditBarcodePicker startScanning];
    //! [Start]
}

#pragma mark -
#pragma mark ScanditSDKOverlayControllerDelegate methods

/**
 * This delegate method of the SBSScanDelegate protocol needs to be implemented by
 * every app that uses the Scandit Barcode Scanner and this is where the custom application logic 
 * goes. 
 */
- (void)barcodePicker:(SBSBarcodePicker*)thePicker didScan:(SBSScanSession*)session {
     [session pauseScanning];
    if (selectionMode == 0) {
        if ([timerStopScanning isValid]) {
            [self.timerStopScanning invalidate];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showBarcodeBubble:session.newlyRecognizedCodes];
        });
    }
    else {
        //if Scan and Confirm mode is enabled, the barcode detected with cancel and confirm buttons
        // are shown on the screen and the scanner continues recognizing codes.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConfirmBubble:session.newlyRecognizedCodes];
        });
    }
}

-(void)showBarcodeBubble:(NSArray *)codes {
    CGRect screen = [[UIScreen mainScreen] bounds];
    if ([timerHideBubble isValid]) {
        [timerHideBubble invalidate];
    }
    [self.bubble removeFromSuperview];
    
    self.bubble = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, screen.size.width, 150)];
    self.bubble.backgroundColor = [UIColor blackColor];
    int position = 0;
    for (SBSCode *code in codes) {
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * position, screen.size.width, 50)];
        NSString *barcode = code.data;
        NSString *symbology = code.symbologyString;
        NSString *text = [NSString stringWithFormat:@"Scanned %@ Code:", symbology];
        tmpLabel.text = text;
        tmpLabel.textAlignment = NSTextAlignmentCenter;
        tmpLabel.font = [UIFont boldSystemFontOfSize:20];
        tmpLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        tmpLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.bubble addSubview:tmpLabel];
    
        UILabel *barcodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * position + 30, screen.size.width, 50)];
        NSString *barcodeText = [NSString stringWithFormat:@"%@", barcode];
        barcodeLabel.textAlignment = NSTextAlignmentCenter;
        barcodeLabel.font = [UIFont boldSystemFontOfSize:20];
        barcodeLabel.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        barcodeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        barcodeLabel.text = barcodeText;
        [self.bubble addSubview:barcodeLabel];
        position++;
    }
    [self.scanditBarcodePicker.overlayController.view addSubview:self.bubble];
    
    self.timerHideBubble = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(removeBarcodeBubble)
                                                userInfo:nil
                                                 repeats:NO];
    [self restartAimAndScanMode];
}

-(void) restartAimAndScanMode {
       if (!volumeButtonEnable) {
        [self.scanditBarcodePicker.overlayController.view addSubview:self.scanButton];
    }
}

-(void) removeBarcodeBubble {
    [self.bubble removeFromSuperview];
}

//Create bubble showing the barcode detected with confirm buttons
-(void) showConfirmBubble:(NSArray *)codes {
    if ([timerHideBubble isValid]) {
        [timerHideBubble invalidate];
    }
    CGRect screen = [[UIScreen mainScreen] bounds];
    	
    [self.bubble removeFromSuperview];
    
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screen.size.width, 50)];
    self.dinamLabel = tmpLabel;
    NSString* text = @"";
    for (SBSCode *code in codes) {
        text = [text stringByAppendingFormat:@"%@ %@\n",
                code.symbologyString, code.data];
    }
    
    self.bubble = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2 * screen.size.height / 3, screen.size.width, 110)];
    self.bubble.backgroundColor = [UIColor whiteColor];
    self.bubble.layer.cornerRadius = 4.0f;
    self.dinamLabel.text = text;
    self.dinamLabel.textAlignment = NSTextAlignmentCenter;
    self.dinamLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.dinamLabel.numberOfLines = [codes count];
    self.dinamLabel.font = [UIFont boldSystemFontOfSize:20];
    self.dinamLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.bubble addSubview:dinamLabel];
    
    //Confirm button
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    [self.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.confirmButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.confirmButton.layer.cornerRadius = 4.0f;
    self.confirmButton.frame = CGRectMake(screen.size.width / 2 + 5, 60, screen.size.width / 2 - 15, 30);
    self.confirmButton.layer.borderWidth = 1.0f;
    
    //Cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    self.cancelButton.frame = CGRectMake(10, 60, screen.size.width / 2 - 15, 30);
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancelButton.layer.borderWidth = 1.0f;
    self.cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.cancelButton.layer.cornerRadius = 4.0f;
    
    [self.bubble addSubview:self.confirmButton];
    [self.bubble addSubview:self.cancelButton];
    [self.scanditBarcodePicker.overlayController.view addSubview:self.bubble];
    
    self.bubble.userInteractionEnabled = YES;
    [self.confirmButton addTarget:self
                           action:@selector(confirmBarcodeSelection)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self
                          action:@selector(cancelBarcodeSelection)
                forControlEvents:UIControlEventTouchUpInside];
    [self.scanditBarcodePicker resumeScanning];
}

-(void) cancelBarcodeSelection {
    //Cancel barcode selection actions
    [self removeConfirmBubble];
}

-(void) confirmBarcodeSelection {
    //Confirm barcode selection actions
    if (self.bubble) {
        self.dinamLabel.text = @"Barcode added";
        [self.cancelButton removeFromSuperview];
        [self.confirmButton removeFromSuperview];
        self.timerHideBubble = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                 target:self
                                                               selector:@selector(removeConfirmBubble)
                                                               userInfo:nil
                                                                repeats:NO];
    }
}

-(void) removeConfirmBubble {
    if ([timerHideBubble isValid]) {
        [timerHideBubble invalidate];
    }
    if (self.bubble) {
        [self.bubble removeFromSuperview];
    }
}

@end
