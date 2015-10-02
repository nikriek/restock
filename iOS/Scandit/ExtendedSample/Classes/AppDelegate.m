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



#import "AppDelegate.h"
#import "MainExampleViewController.h"
#import "OtherExamplesViewController.h"
#import "Reachability.h"

#import <MessageUI/MessageUI.h>

#import "IASKAppSettingsViewController.h"
#import "IASKSettingsReader.h"


// Enter your Scandit SDK App key here.
// Note: Your app key is available from your Scandit SDK web account.
#define kScanditBarcodeScannerAppKey    @"--- ENTER YOUR SCANDIT APP KEY HERE ---"

@interface AppDelegate ()
@property (nonatomic, strong) MainExampleViewController *mainExampleController;
@property (nonatomic, strong) OtherExamplesViewController *otherExamplesController;
@property (nonatomic, strong) IASKAppSettingsViewController *settingsController;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Provide the app key for your scandit license.
    [SBSLicense setAppKey:kScanditBarcodeScannerAppKey];
	
	[self registerDefaultsFromSettingsBundle];
	
    // Setting up the tab and navigation controller.
    self.mainExampleController = [[MainExampleViewController alloc]
                                  initWithNibName:@"MainExampleViewController" bundle:nil];
    
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"Main" 
                                                          image:[UIImage imageNamed:@"icon_lists.png"]
                                                            tag:0];
	self.mainExampleController.tabBarItem = tabItem;
    
	self.settingsController = [[IASKAppSettingsViewController alloc] init];
    self.settingsController.showDoneButton = NO;
    UITabBarItem *tabItem1 = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                           image:[UIImage imageNamed:@"icon_history.png"]
                                                             tag:1];
	
    UINavigationController *settingsNavController = [[UINavigationController alloc]
													 initWithRootViewController:self.settingsController];
    settingsNavController.tabBarItem = tabItem1;
    
    self.otherExamplesController = [[OtherExamplesViewController alloc]
                                    initWithNibName:@"OtherExamplesViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self.otherExamplesController];
    
    UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:@"Other Examples" 
                                                           image:[UIImage imageNamed:@"icon_history.png"]
                                                             tag:2];
    navController.tabBarItem = tabItem2;
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    [tabController setViewControllers:@[self.mainExampleController, settingsNavController, navController]];
    tabController.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:tabController];
    [self.window makeKeyAndVisible];
	
	[self updateHiddenSettings];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(settingChanged:)
												 name:kIASKAppSettingChanged
											   object:nil];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)vController {
	
    [self.mainExampleController tabBarController:tabBarController didSelectViewController:vController];
    [self.otherExamplesController tabBarController:tabBarController didSelectViewController:vController];
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
	NSArray *floatSliders = [[NSArray alloc] initWithObjects:@"scanningHotSpotX", @"scanningHotSpotY",
						@"scanningHotSpotHeight", @"viewfinderWidth", @"viewfinderHeight",
						@"viewfinderLandscapeWidth", @"viewfinderLandscapeHeight", nil];
	if ([floatSliders containsObject:notification.object]) {
		float value = roundf([notification.userInfo[notification.object] floatValue] * 100) / 100.0;
		if ([[NSUserDefaults standardUserDefaults] floatForKey:notification.object] != value) {
			[[NSUserDefaults standardUserDefaults] setFloat:value forKey:notification.object];
		}
		[[NSUserDefaults standardUserDefaults] setFloat:value
												 forKey:[NSString stringWithFormat:@"%@Label",
														 notification.object]];
	}
    
    NSArray *intSliders = [[NSArray alloc] initWithObjects:@"torchButtonLeftMargin", @"torchButtonTopMargin",
                           @"cameraSwitchButtonRightMargin", @"cameraSwitchButtonTopMargin", nil];
    if ([intSliders containsObject:notification.object]) {
        NSInteger value = (NSInteger) round([notification.userInfo[notification.object] doubleValue]);
        if ([[NSUserDefaults standardUserDefaults] integerForKey:notification.object] != value) {
            [[NSUserDefaults standardUserDefaults] setInteger:value forKey:notification.object];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:value
                                                   forKey:[NSString stringWithFormat:@"%@Label",
                                                           notification.object]];
    }

	NSArray *hideSettings = [[NSArray alloc] initWithObjects:@"msiPlesseyEnabled",
							 @"restrictActiveScanningArea", @"searchBar", @"drawViewfinder",
							 @"torchEnabled", @"cameraSwitchVisibility", @"dataMatrixEnabled", nil];
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
	if (![settings boolForKey:@"restrictActiveScanningArea"]) {
		[newHidden addObject:@"scanningHotSpotHeightLabel"];
		[newHidden addObject:@"scanningHotSpotHeight"];
	}
	if (![settings boolForKey:@"searchBar"]) {
		[newHidden addObject:@"searchBarActionButtonCaption"];
		[newHidden addObject:@"searchBarCancelButtonCaption"];
		[newHidden addObject:@"searchBarPlaceholderText"];
		[newHidden addObject:@"searchBarKeyboardType"];
	}
	if (![settings boolForKey:@"drawViewfinder"]) {
		[newHidden addObject:@"viewfinderWidthLabel"];
		[newHidden addObject:@"viewfinderWidth"];
		[newHidden addObject:@"viewfinderHeightLabel"];
		[newHidden addObject:@"viewfinderHeight"];
		[newHidden addObject:@"viewfinderLandscapeWidthLabel"];
		[newHidden addObject:@"viewfinderLandscapeWidth"];
		[newHidden addObject:@"viewfinderLandscapeHeightLabel"];
		[newHidden addObject:@"viewfinderLandscapeHeight"];
	}
	if (![settings boolForKey:@"torchEnabled"]) {
		[newHidden addObject:@"torchButtonLeftMarginLabel"];
		[newHidden addObject:@"torchButtonLeftMargin"];
		[newHidden addObject:@"torchButtonTopMarginLabel"];
		[newHidden addObject:@"torchButtonTopMargin"];
	}
	if ([settings integerForKey:@"cameraSwitchVisibility"] == 0) {
		[newHidden addObject:@"cameraSwitchButtonRightMarginLabel"];
		[newHidden addObject:@"cameraSwitchButtonRightMargin"];
		[newHidden addObject:@"cameraSwitchButtonTopMarginLabel"];
		[newHidden addObject:@"cameraSwitchButtonTopMargin"];
	}
	[self.settingsController setHiddenKeys:newHidden animated:YES];
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
