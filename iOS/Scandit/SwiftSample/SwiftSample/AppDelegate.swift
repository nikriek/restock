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

import UIKit


let kScanditBarcodeScannerAppKey = "--- ENTER YOUR SCANDIT APP KEY HERE ---";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SBSScanDelegate, UIAlertViewDelegate {

    var window: UIWindow?

    var picker : SBSBarcodePicker?

    func application(application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [NSObject: AnyObject]?) -> Bool {

        SBSLicense.setAppKey(kScanditBarcodeScannerAppKey);
        
        // Scandit Barcode Scanner Integration
        // The following method calls illustrate how the Scandit Barcode Scanner can be integrated
        // into your app.
        // Hide the status bar to get a bigger area of the video feed. (optional)
        application.setStatusBarHidden(true, withAnimation:UIStatusBarAnimation.None);
        picker = SBSBarcodePicker(settings:SBSScanSettings.pre47DefaultSettings());
        
        // set the allowed interface orientations. The value UIInterfaceOrientationMaskAll is the
        // default and is only shown here for completeness.
        picker?.allowedInterfaceOrientations = UIInterfaceOrientationMask.All;
        // Set the delegate to receive scan event callbacks
        picker?.scanDelegate = self;
        picker?.startScanning();
        window?.rootViewController = picker;
        window?.makeKeyAndVisible();
        return true
    }
    
    // This delegate method of the SBSScanDelegate protocol needs to be implemented by
    // every app that uses the Scandit Barcode Scanner and this is where the custom application logic
    // goes. In the example below, we are just showing an alert view with the result.
    func barcodePicker(picker: SBSBarcodePicker!, didScan session: SBSScanSession!) {
        // call stopScanning on the session to immediately stop scanning and close the camera. This
        // is the preferred way to stop scanning barcodes from the SBSScanDelegate as it is made 
        // sure that no new codes are scanned. When calling stopScanning on the picker, another code 
        // may be scanned before stopScanning has completely stoppen the scanning process.
        session.stopScanning();
        
        var code = session.newlyRecognizedCodes[0] as! SBSCode;
        // the barcodePicker:didScan delegate method is invoked from a picker-internal queue. To 
        // display the results in the UI, you need to dispatch to the main queue. Note that it's not 
        // allowed to use SBSScanSession in the dispatched block as it's only allowed to access the
        // SBSScanSession inside the barcodePicker(picker:didScan:) callback. It is however safe to
        // use results returned by session.newlyRecognizedCodes etc.
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertView();
            alert.delegate = self;
            alert.title = String(format:"Scanned code %@", code.symbologyString);
            alert.message = code.data;
            alert.addButtonWithTitle("OK");
            alert.show();
        };
    }
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        picker?.startScanning();
    }
}

