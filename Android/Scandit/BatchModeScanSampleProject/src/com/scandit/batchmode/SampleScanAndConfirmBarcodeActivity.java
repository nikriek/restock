package com.scandit.batchmode;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager.LayoutParams;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.mirasense.scanditsdk.ScanditSDKAutoAdjustingBarcodePicker;
import com.mirasense.scanditsdk.ScanditSDKBarcodePicker;
import com.mirasense.scanditsdk.ScanditSDKScanSettings;
import com.mirasense.scanditsdk.interfaces.*;

import java.lang.ref.WeakReference;
import java.util.List;

/**
 * Example for a full-screen barcode scanning activity using the Scandit
 * Barcode picker.
 *
 * The activity does the following:
 *
 *  - starting the picker full-screen mode
 *  - configuring the barcode picker with the settings defined in the
 *    SettingsActivity.
 *  - registering a listener to get notified whenever a barcode gets
 *    scanned. Upon a successful scan, the barcode scanner is paused and
 *    the recognized barcode is displayed in an overlay. When the user
 *    taps the screen, barcode recognition is resumed.
 *
 * For non-fullscreen barcode scanning take a look at the ScanditSDKDemo
 * class.
 *
 * Copyright 2014 Scandit AG
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class SampleScanAndConfirmBarcodeActivity
		extends Activity
		implements ScanditSDKOnScanListener,
		           ScanditSDKSearchBarListener,
		           ScanditSDKCaptureListener {

    // The main object for recognizing a displaying barcodes.
    private ScanditSDKBarcodePicker mBarcodePicker;
    private View barcodeView = null;
    private UIHandler mHandler = null;
    private Button laserScan = null;
    private TextView barcodeText;
    private Button confirmButton;
    private Button cancelButton;
    private Runnable mRunnable;

    // Enter your Scandit SDK App key here.
    // Your Scandit SDK App key is available via your Scandit SDK web account.
    public static final String sScanditSdkAppKey = "--- ENTER YOUR SCANDIT APP KEY HERE ---";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        setContentView(R.layout.barcode_confirm);
        mHandler = new UIHandler(this);
        // We keep the screen on while the scanner is running.
        getWindow().addFlags(LayoutParams.FLAG_KEEP_SCREEN_ON);

        // Initialize and start the bar code recognition.
        initializeAndStartBarcodeScanning();
    }

    @Override
    protected void onPause() {
		super.onPause();
        // When the activity is in the background immediately stop the
        // scanning to save resources and free the camera.
        mBarcodePicker.stopScanning();

    }

    @Override
    protected void onResume() {
		super.onResume();
        // Once the activity is in the foreground again, restart scanning.
        mBarcodePicker.startScanning();
    }

    /**
     * Initializes and starts the bar code scanning.
     */
    public void initializeAndStartBarcodeScanning() {

        barcodeView = findViewById(R.id.barcode_detected);
        barcodeText = (TextView) findViewById(R.id.barcode_text);

        cancelButton = (Button) findViewById(R.id.barcode_cancel);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mBarcodePicker.removeView(barcodeView);
            }
        });
        confirmButton = (Button) findViewById(R.id.barcode_confirm);
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                confirmButton.setVisibility(View.GONE);
                cancelButton.setVisibility(View.GONE);
                barcodeText.setText("Barcode added");
                mHandler.postDelayed(mRunnable, 3 * 1000);
            }
        });

        mRunnable = new Runnable() {
            @Override
            public void run() {
                mBarcodePicker.removeView(barcodeView);
            }
        };
        // Switch to full screen.
        getWindow().setFlags(LayoutParams.FLAG_FULLSCREEN,
                LayoutParams.FLAG_FULLSCREEN);
        
        SettingsActivity.setActivityOrientation(this);

		// Set all scan settings according to the settings activity. Typically
		// you will hard-code the settings for your app and do not need a settings
		// activity.
		ScanditSDKScanSettings settings = SettingsActivity.getSettings(this);

		// the following code caching and duplicate filter values are the
		// defaults, they are nevertheless listed here to introduce them.

		// keep codes forever
		settings.setCodeCachingDuration(-1);
		// classify codes as duplicates if the same data/symbology is scanned
		// within 500ms.
		settings.setCodeDuplicateFilter(500);

        // We instantiate the automatically adjusting barcode picker that will
        // choose the correct picker to instantiate. Be aware that this picker
        // should only be instantiated if the picker is shown full screen as the
        // legacy picker will rotate the orientation and not properly work in
        // a view hierarchy.
        mBarcodePicker = new ScanditSDKAutoAdjustingBarcodePicker(this, sScanditSdkAppKey,
											                      settings);
		// Apply UI settings to barcode picker
		SettingsActivity.applyUISettings(this, mBarcodePicker.getOverlayView());
		
		// Add listeners for scan events and search bar events (only needed if the bar is visible).
        mBarcodePicker.addOnScanListener(this);
        mBarcodePicker.getOverlayView().addSearchBarListener(this);

        // Add both views to activity, with the scan GUI on top.
        setContentView(mBarcodePicker);
        //! [Restrict Area]
        mBarcodePicker.restrictActiveScanningArea(true);
        mBarcodePicker.setScanningHotSpotHeight(0.1f);
        mBarcodePicker.getOverlayView().setViewfinderDimension(0.6f, 0.1f, 0.6f, 0.1f);
        mBarcodePicker.getOverlayView().drawViewfinder(false);
        //! [Restrict Area]
        mBarcodePicker.getOverlayView().setTorchEnabled(false);
        //! [Laser Added]
        laserScan = new Button(this);
        laserScan.setBackgroundResource(R.drawable.scan_line_white);
        RelativeLayout layout = (RelativeLayout)mBarcodePicker.getOverlayView();
        RelativeLayout.LayoutParams rParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 50);
        rParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        rParams.addRule(RelativeLayout.CENTER_VERTICAL);
        rParams.bottomMargin = 50;
        layout.addView(laserScan, rParams);
        //! [Laser Added]
        //! [Start]
        mBarcodePicker.startScanning();
        //! [Start]
        // If you want to process the individual frames yourself, add a capture
        // listener.
        // mBarcodePicker.setCaptureListener(this);
    }

	@Override
	public void didScan(ScanditSDKScanSession session) {
        List<ScanditSDKCode> newlyDecoded = session.getNewlyDecodedCodes();

        // because the callback is invoked inside the thread running the barcode
        // recognition, any UI update must be posted to the UI thread.
        // In this example, we want to show the first decoded barcode in a
        // splash screen covering the full display.
        mHandler.removeCallbacks(mRunnable);
        Message msg = mHandler.obtainMessage(UIHandler.SHOW_BARCODES,
                                             newlyDecoded);
        mHandler.sendMessage(msg);
	}

	@Override
    public void didCaptureImage(byte[] data, int width, int height) {
        // Here you can process the image frame contained in data. Frames are
        // always in a landscape right orientation and in YCrCb format.
    }
    
    public void didCancel() {
        mBarcodePicker.stopScanning();
        finish();
    }
    
    @Override
    public void onBackPressed() {
        mBarcodePicker.stopScanning();
        barcodeView = null;
        finish();
    }

    @Override
    public void didEnter(String entry) {

    }

    static private class UIHandler extends Handler {
        public static final int SHOW_BARCODES = 0;
        private WeakReference<SampleScanAndConfirmBarcodeActivity> mActivity;
        UIHandler(SampleScanAndConfirmBarcodeActivity activity) {
            mActivity = new WeakReference<SampleScanAndConfirmBarcodeActivity>(activity);
        }
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SHOW_BARCODES:
                    showSplash(createMessage((List<ScanditSDKCode>)msg.obj));
                    break;
            }
        }
        private String createMessage(List<ScanditSDKCode> codes) {
            String message = "";
            for (ScanditSDKCode code : codes) {
                String data = code.getData();
                // cleanup the data somewhat by replacing control characters contained in
                // some of the barcodes with hash signs and truncating long barcodes
                // to reasonable lengths.
                String cleanData = "";

                for (int i = 0; i < data.length(); ++i) {
                    char c = data.charAt(i);
                    cleanData += Character.isISOControl(c) ? '#' : c;
                }
                if (cleanData.length() > 30) {
                    cleanData = cleanData.substring(0, 25)+"[...]";
                }
                message += code.getSymbologyString() + " ";
                message += cleanData;

            }
            return message;
        }

        private void showSplash(String msg) {
            SampleScanAndConfirmBarcodeActivity activity = mActivity.get();
            RelativeLayout layout = activity.mBarcodePicker;
            if (activity.barcodeView != null)  {
                layout.removeView(activity.barcodeView);
                RelativeLayout.LayoutParams rParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
                rParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                layout.addView(activity.barcodeView, rParams);
                activity.confirmButton.setVisibility(View.VISIBLE);
                activity.cancelButton.setVisibility(View.VISIBLE);
                activity.barcodeText.setText(msg);
            }
        }
    }
}
