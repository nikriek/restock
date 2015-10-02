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


#import "PickerResultViewController.h"
#import <ScanditBarcodeScanner/SBSCode.h>

@interface PickerResultViewController ()
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) SBSBarcodePicker *picker;
@end


@implementation PickerResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}


- (void)showCodes:(NSArray *)codes onPicker:(SBSBarcodePicker *)picker {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* text = [codes count] != 1 ? @"Scanned codes" : @"Scanned code";
        self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.infoLabel.numberOfLines = [codes count] * 4;
        for (SBSCode *code in codes) {
            text = [text stringByAppendingFormat:@"\n\n%@\n%@",
                                                 code.symbologyString, code.data];
        }
        self.picker = picker;
        if (self.view) {
            self.infoLabel.text = text;
        }
        
        [picker.overlayController.view addSubview:self.view];
        
        // Match the superview's dimensions.
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|[overlay]|"
                                          options:0
                                          metrics:nil
                                          views:@{@"overlay":self.view}]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[overlay]|"
                                          options:0
                                          metrics:nil
                                          views:@{@"overlay":self.view}]];
        [picker.overlayController.view addConstraints:constraints];
        
        // Add a tap recognizer to the picker itself to continue scanning on tap.
        self.tapRecognizer = [[UITapGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(hideAndStart)];
        [picker.view addGestureRecognizer:self.tapRecognizer];
    });
}

- (void)hide {
    if (self.picker) {
        // If the picker exist, we remove the view before releasing it and also remove the tap
        // recognizer.
        [self.view removeFromSuperview];
        [self.picker.view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)hideAndStart {
    [self hide];
    [self.picker performSelector:@selector(startScanning)
                      withObject:nil
                      afterDelay:0.01];
    self.picker = nil;
}

@end
