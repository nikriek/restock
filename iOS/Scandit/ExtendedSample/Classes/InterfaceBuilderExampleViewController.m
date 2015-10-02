//
//  InterfaceBuilderExampleViewController.m
//  ExtendedSample
//
//  Created by Moritz Hartmeier on 15/06/15.
//
//

#import "InterfaceBuilderExampleViewController.h"

#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

#import "PickerResultViewController.h"


@interface InterfaceBuilderExampleViewController () <SBSScanDelegate>
@property (nonatomic, strong) IBOutlet SBSBarcodePickerView *scanditBarcodePickerView;
@property (nonatomic, strong) PickerResultViewController *resultOverlay;
@end

@implementation InterfaceBuilderExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"IB View Example";
    
    /* This is where you can set advanced settings on the view which are not exposed through the
     * interface builder. For those you can access the SBSBarcodePicker through the viewController
     * property and then have access to all options you would have when creating the picker through
     * code.
     */
    [self.scanditBarcodePickerView.viewController setRelativeZoom:0.2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* The SBSBarcodePickerView in the xib is set to start scanning when it is loaded but you might
     * not want to immediately start it, in that case you would start it this way:*/
    //[self.scanditBarcodePickerView startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    /* It is generally good practice to always stop the SBSBarcodePickerView when you know it should
     * no longer be scanning. This frees up resources as early as possible. */
    [self.scanditBarcodePickerView stopScanning];
}


#pragma mark - SBSScanDelegate

/**
 * The delegate of the SBSBarcodePickerView is set through the interface builder but has to be
 * implemented here in code.
 */
- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    NSArray* recognized = session.newlyRecognizedCodes;    
    [session pauseScanning];
    
    [self.resultOverlay hide];
    self.resultOverlay = [[PickerResultViewController alloc]
                          initWithNibName:@"PickerResultViewController" bundle:nil];
    
    [self.resultOverlay showCodes:recognized onPicker:self.scanditBarcodePickerView.viewController];
}

@end
