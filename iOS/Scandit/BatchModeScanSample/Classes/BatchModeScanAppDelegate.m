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

#import "BatchModeScanAppDelegate.h"
#import "TableViewController.h"
#import "Reachability.h"
#import <MessageUI/MessageUI.h>

#import "IASKAppSettingsViewController.h"
#import "IASKSettingsReader.h"

// Enter your Scandit SDK App key here.
// Note: Your app key is available from your Scandit SDK web account.
#define kScanditBarcodeScannerAppKey    @"--- ENTER YOUR SCANDIT APP KEY HERE ---"

@implementation BatchModeScanAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize settingsController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [self registerDefaultsFromSettingsBundle];
    
    // Setup UI
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if (navigationController.viewControllers) {
        for (UINavigationController *view in navigationController.viewControllers) {
            if ([view isKindOfClass:[TableViewController class]]) {
                viewController = (TableViewController *) view;
                self.viewController.appKey = kScanditBarcodeScannerAppKey;
                return;
            }
        }
    }
    settingsController = [[IASKAppSettingsViewController alloc] init];
    settingsController.showDoneButton = NO;
  
    [window makeKeyAndVisible];
    
    [self updateHiddenSettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingChanged:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];
}

- (void)dealloc {
    self.viewController = nil;
    self.window = nil;
    self.settingsController = nil;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)settingChanged:(NSNotification *)notification {
    
    NSArray *hideSettings = [[NSArray alloc] initWithObjects:@"msiPlesseyEnabled",@"enableSelectionMode",
                             @"dataMatrixEnabled", nil];
    if ([hideSettings containsObject:notification.object]) {
        [self updateHiddenSettings];
    }
}

- (void)updateHiddenSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSMutableSet *newHidden = [[NSMutableSet alloc] init];
    if (![settings boolForKey:@"msiPlesseyEnabled"]) {
        [newHidden addObject:@"msiPlesseyChecksum"];
    }
    if (![settings boolForKey:@"dataMatrixEnabled"]) {
        [newHidden addObject:@"microDataMatrixEnabled"];
        [newHidden addObject:@"inverseDetectionEnabled"];
    }
    
    if (![settings boolForKey:@"enableSelectionMode"]) {
        [newHidden addObject:@"selectionMode"];
        [newHidden addObject:@"enableVolumeButton"];
        
    }
    
    [settingsController setHiddenKeys:newHidden animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Network Check

- (BOOL)isNetworkAvailable {
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == NotReachable) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Network"
                                                            message:@"The development version of Scandit requires network access. Connect and try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}


@end
