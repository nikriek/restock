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
// OtherExamplesViewController shows advanced usages of the Scandit Barcode Scanner SDK
//
// Any view controller that would like to scan barcodes using the Scandit Barcode Scanner, needs
// to instantiate the SBSBarcodePicker. The picker is a UIViewController and can therefore be used
// like any other view controller. It can be shown modally, directly as the starting view, in a
// tab bar controller, pushed on a navigation controller etc. The class that wants to listen to the
// picker's events needs to implement the SBSScanDelegate protocol.
//
// Examples for the most common usage scenarios are shown below.

#import "OtherExamplesViewController.h"

#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

#import "PickerResultViewController.h"
#import "InterfaceBuilderExampleViewController.h"


@interface OtherExamplesViewController ()

@property (nonatomic, strong) SBSBarcodePicker *scanditBarcodePicker;
@property (nonatomic, assign) BOOL modalStartAnimationDone;
@property (nonatomic, strong) NSArray *modalBufferedResult;
/* A button to show if the picker is presented as a subview of this controller's view. Clicking
 * the button will close the active picker. */
@property (nonatomic, weak) IBOutlet UIButton *backgroundButton;
@property (nonatomic, strong) PickerResultViewController *resultOverlay;

- (IBAction)overlayAsView;
- (IBAction)overlayAsScaledView;
- (IBAction)modallyShowScanView;
- (IBAction)showScanViewInNav;
@end


@implementation OtherExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalStartAnimationDone = NO;
    self.modalBufferedResult = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
		[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self closePickerSubview:self.backgroundButton];
}


#pragma mark - Showing the SBSBarcodePicker overlayed as a view

//! [SBSBarcodePicker overlayed as a view]
/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any other view.
 */
- (IBAction)overlayAsView {
    self.scanditBarcodePicker = [[SBSBarcodePicker alloc]
                                 initWithSettings:[SBSScanSettings pre47DefaultSettings]];
    
    /* Set the delegate to receive callbacks.
     * This is commented out here in the demo app since the result view with the scan results
     * is not suitable for this overlay view */
    // self.scanditBarcodePicker.scanDelegate = self;
    
    // Add a button behind the subview to close it.
    self.backgroundButton.hidden = NO;
    
    [self addChildViewController:self.scanditBarcodePicker];
    [self.view addSubview:self.scanditBarcodePicker.view];
    [self.scanditBarcodePicker didMoveToParentViewController:self];
    
    [self.scanditBarcodePicker.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add constraints to place the picker at the top of the controller with a height of 300 and
    // the same width as the controller. Since this is not the aspect ratio of the video preview
    // some of the video preview will be cut away on the top and bottom.
    UIView *pickerView = self.scanditBarcodePicker.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(pickerView);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        id topGuide = self.topLayoutGuide;
        views = NSDictionaryOfVariableBindings(pickerView, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide][pickerView(300)]"
                                                                          options:nil
                                                                          metrics:nil
                                                                            views:views]];
    } else {
        // There is no topLayoutGuide under iOS 6.
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[pickerView(300)]"
                                                                          options:nil
                                                                          metrics:nil
                                                                            views:views]];
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerView]|"
                                                                      options:nil
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.scanditBarcodePicker startScanning];
}
//! [SBSBarcodePicker overlayed as a view]

/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any other view. This example scales the view instead of cropping it.
 */
- (IBAction)overlayAsScaledView {
    self.scanditBarcodePicker = [[SBSBarcodePicker alloc]
                                 initWithSettings:[SBSScanSettings pre47DefaultSettings]];
    
    /* Set the delegate to receive callbacks.
     * This is commented out here in the demo app since the result view with the scan results
     * is not suitable for this overlay view */
    // self.scanditBarcodePicker.scanDelegate = self;
    
    // Add a button behind the subview to close it.
    self.backgroundButton.hidden = NO;
    
    [self addChildViewController:self.scanditBarcodePicker];
    [self.view addSubview:self.scanditBarcodePicker.view];
    [self.scanditBarcodePicker didMoveToParentViewController:self];
    
    [self.scanditBarcodePicker.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add constraints to scale the view and place it in the center of the controller.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    // Add constraints to set the width to 200 and height to 400. Since this is not the aspect ratio
    // of the camera preview some of the camera preview will be cut away on the left and right.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:200.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:400.0]];
	[self.scanditBarcodePicker startScanning];
}

- (IBAction)closePickerSubview:(id)sender {
    if (!self.backgroundButton.hidden) {
        [self.scanditBarcodePicker removeFromParentViewController];
        [self.scanditBarcodePicker.view removeFromSuperview];
        [self.scanditBarcodePicker didMoveToParentViewController:nil];
        self.scanditBarcodePicker = nil;
        
        self.backgroundButton.hidden = YES;
    }
}


#pragma mark - Showing the SBSBarcodePicker as a modal UIViewController

//! [SBSBarcodePicker as a modal view]
/**
 * Configure and show barcode picker modally
 */
- (IBAction)modallyShowScanView {
	self.scanditBarcodePicker = [[SBSBarcodePicker alloc]
                                 initWithSettings:[SBSScanSettings pre47DefaultSettings]];
    
	// Always show a toolbar (with cancel button) so we can navigate out of the scan view.
	[self.scanditBarcodePicker.overlayController showToolBar:YES];
	
	// Show a button to switch the camera from back to front and vice versa but only when using
	// a tablet.
	[self.scanditBarcodePicker.overlayController setCameraSwitchVisibility:SBSCameraSwitchVisibilityOnTablet];
    
	// Set the delegate to receive callbacks.
	self.scanditBarcodePicker.scanDelegate = self;
    self.scanditBarcodePicker.overlayController.cancelDelegate = self;
	
	// Present the barcode picker modally and start scanning. We buffer the result if the code was
    // already recognized while the modal view is still animating.
    self.modalStartAnimationDone = NO;
    [self presentViewController:self.scanditBarcodePicker animated:YES completion:^{
        if (self.modalBufferedResult != nil) {
            [self.scanditBarcodePicker pauseScanning];
            [self performSelector:@selector(returnBuffer) withObject:nil afterDelay:0.01];
        }
        self.modalStartAnimationDone = YES;
    }];
	
	[self.scanditBarcodePicker performSelector:@selector(startScanning) withObject:nil afterDelay:0.1];
}
//! [SBSBarcodePicker as a modal view]

- (void)returnBuffer {
	if (self.modalBufferedResult != nil) {
        [self.resultOverlay hide];
        self.resultOverlay = [[PickerResultViewController alloc]
                              initWithNibName:@"PickerResultViewController" bundle:nil];
    
        [self.resultOverlay showCodes:self.modalBufferedResult onPicker:self.scanditBarcodePicker];
        
        self.modalBufferedResult = nil;
	}
}


#pragma mark - Showing the SBSBarcodePicker in a UINavigationController

//! [SBSBarcodePicker in a navigation controller]
/**
 * This is a simple example of how one can push the SBSBarcodePicker in a navigation controller.
 */
- (IBAction)showScanViewInNav {
    SBSScanSettings *settings = [SBSScanSettings pre47DefaultSettings];
    if ([self isMinOSVersion:@"7.0"]) {
        [settings setScanningHotSpot:CGPointMake(0.5, 0.5)];
    } else {
        [settings setScanningHotSpot:CGPointMake(0.5, 0.35)];
    }
    
	// We allocate a picker without keeping a reference and don't set a delegate. The picker will
	// simply track barcodes that have been recognized.
    SBSBarcodePicker *barcodePicker = [[SBSBarcodePicker alloc] initWithSettings:settings];
    
	// Show the navigation bar such that we can press the back button.
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Show a button to switch the camera from back to front and vice versa but only when using
	// a tablet.
	[barcodePicker.overlayController setCameraSwitchVisibility:SBSCameraSwitchVisibilityOnTablet];
	
    // Set the delegate to receive callbacks.
    // This is commented out here in the demo app since the result view with the scan results
    // is not suitable for this navigation view
	
    // self.scanditBarcodePicker.scanDelegate = self;
    
    // Push the picker on the navigation stack and start scanning.
    [self.navigationController pushViewController:barcodePicker animated:YES];
	[barcodePicker startScanning];
}
//! [SBSBarcodePicker in a navigation controller]


#pragma mark - Showing the SBSBarcodePicker through an Interface Builder View

- (IBAction)showInterfaceBuilderViewController {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    InterfaceBuilderExampleViewController *nextController = [[InterfaceBuilderExampleViewController alloc]
                                                             initWithNibName:@"InterfaceBuilderExampleViewController"
                                                             bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}


#pragma mark - Utility

/**
 * Returns YES if the device runs at least the specified OS version.
 */
- (BOOL)isMinOSVersion:(NSString *)version {
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:version options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    
    // Be sure to close all pickers that might still be open.
    if (tabBarController.selectedIndex != 2) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}


#pragma mark - SBSScanDelegate

- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    NSArray* recognized = session.newlyRecognizedCodes;

    if (!self.modalStartAnimationDone) {
        // If the initial animation hasn't finished yet we buffer the result and return it as soon
        // as the animation finishes.
        self.modalBufferedResult = recognized;
        return;
    } else {
        self.modalBufferedResult = nil;
    }

    [session pauseScanning];
    
    [self.resultOverlay hide];
    self.resultOverlay = [[PickerResultViewController alloc]
                          initWithNibName:@"PickerResultViewController" bundle:nil];
    
    [self.resultOverlay showCodes:recognized onPicker:self.scanditBarcodePicker];
}


#pragma mark - SBSOverlayControllerDidCancelDelegate

- (void)overlayController:(SBSOverlayController *)overlayController
      didCancelWithStatus:(NSDictionary *)status {
    [self.scanditBarcodePicker stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
