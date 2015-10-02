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


#import "SimpleSampleAppDelegate.h"
#import "Reachability.h"

#define kScanditBarcodeScannerAppKey    @"--- ENTER YOUR SCANDIT APP KEY HERE ---"


@implementation SimpleSampleAppDelegate

@synthesize window;
@synthesize picker;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [SBSLicense setAppKey:kScanditBarcodeScannerAppKey];
    
    // Scandit Barcode Scanner Integration
    // The following method calls illustrate how the Scandit Barcode Scanner can be integrated
    // into your app.
    // Hide the status bar to get a bigger area of the video feed. (optional)
	[[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    
    // Initialize the barcode picker - make sure you set the app key above
	picker = [[SBSBarcodePicker alloc] initWithSettings:[SBSScanSettings pre47DefaultSettings]];
	
    // only show camera switch button on tablets. For all other devices the switch button is
    // hidden, even if they have a front camera.
	[picker.overlayController setCameraSwitchVisibility:SBSCameraSwitchVisibilityOnTablet];
    // set the allowed interface orientations. The value UIInterfaceOrientationMaskAll is the
    // default and is only shown here for completeness.
    [picker setAllowedInterfaceOrientations:UIInterfaceOrientationMaskAll];
	// Set the delegate to receive scan event callbacks
	picker.scanDelegate = self;
	
    // Open the camera and start scanning barcodes
	[picker startScanning];
	
    // Show the barcode picker view
    [window setRootViewController:picker];
    [window makeKeyAndVisible];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

//! [SBSScanDelegate callback]
/**
 * This delegate method of the SBSScanDelegate protocol needs to be implemented by
 * every app that uses the Scandit Barcode Scanner and this is where the custom application logic 
 * goes. In the example below, we are just showing an alert view with the result.
 */
- (void)barcodePicker:(SBSBarcodePicker *)thePicker didScan:(SBSScanSession *)session {
	
    // call stopScanning on the session to immediately stop scanning and close the camera. This
    // is the preferred way to stop scanning barcodes from the SBSScanDelegate as it is made sure
    // that no new codes are scanned. When calling stopScanning on the picker, another code may be
    // scanned before stopScanning has completely stoppen the scanning process.
	[session stopScanning];
	
    SBSCode *code = [session.newlyRecognizedCodes objectAtIndex:0];
    // the barcodePicker:didScan delegate method is invoked from a picker-internal queue. To display
    // the results in the UI, you need to dispatch to the main queue. Note that it's not allowed
    // to use SBSScanSession in the dispatched block as it's only allowed to access the
    // SBSScanSession inside the barcodePicker:didScan callback. It is however safe to use results
    // returned by session.newlyRecognizedCodes etc.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *symbology = code.symbologyString;
        NSString *barcode = code.data;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"Scanned %@", symbology]
                              message:barcode
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    });

}

//! [SBSScanDelegate callback]

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.picker startScanning];
}


#pragma mark -
#pragma mark Network Check

- (BOOL)isNetworkAvailable {
	Reachability * reachability = [Reachability reachabilityForInternetConnection];
	if ([reachability currentReachabilityStatus] != NotReachable) {
        return YES;
    }
    NSString *text = @"The test version of Scandit requires network access. Connect and try again.";
    UIAlertView* alertView =
        [[UIAlertView alloc] initWithTitle:@"No Network"
                                   message:text
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
    [alertView show];
    return NO;
}

@end
