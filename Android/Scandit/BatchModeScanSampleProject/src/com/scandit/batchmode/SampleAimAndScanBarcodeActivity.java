package com.scandit.batchmode;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.*;
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
public class SampleAimAndScanBarcodeActivity
		extends Activity
		implements ScanditSDKOnScanListener,
		           ScanditSDKSearchBarListener,
		           ScanditSDKCaptureListener {

    // The main object for recognizing a displaying barcodes.
    private ScanditSDKBarcodePicker mBarcodePicker;
    private UIHandler mHandler = null;
    private Button laserScan = null;
    private Button buttonScan = null;
    private View barcodeView = null;
    private TextView barcodeText = null;
    private Runnable mRunnable = null;

    // Enter your Scandit SDK App key here.
    // Your Scandit SDK App key is available via your Scandit SDK web account.
    public static final String sScanditSdkAppKey = "--- ENTER YOUR SCANDIT APP KEY HERE ---";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        setContentView(R.layout.barcode);
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
        mBarcodePicker.pauseScanning();
    }

    /**
     * Initializes and starts the bar code scanning.
     */
    public void initializeAndStartBarcodeScanning() {
        // Switch to full screen.
        getWindow().setFlags(LayoutParams.FLAG_FULLSCREEN,
                LayoutParams.FLAG_FULLSCREEN);
        
        SettingsActivity.setActivityOrientation(this);
        barcodeView = findViewById(R.id.barcode_detected);
        barcodeText = (TextView) findViewById(R.id.barcode_text);
        mRunnable = new Runnable() {
            @Override
            public void run() {
                mBarcodePicker.removeView(barcodeView);
            }
        };

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
        // reduce the size of white viewfinder rectangle (this only affects the size of rectangle - not the active scanning area
        mBarcodePicker.getOverlayView().setViewfinderDimension(0.6f, 0.1f, 0.6f, 0.1f);
        mBarcodePicker.getOverlayView().drawViewfinder(false);
        //! [Restrict Area]
        mBarcodePicker.getOverlayView().setTorchEnabled(false);
        //! [Laser Button Added]
        //Set laser and button
        laserScan = new Button(this);
        laserScan.setBackgroundResource(R.drawable.scan_line_blue);
        RelativeLayout layout = (RelativeLayout)mBarcodePicker.getOverlayView();
        RelativeLayout.LayoutParams rParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 50);
        rParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        rParams.addRule(RelativeLayout.CENTER_VERTICAL);
        rParams.bottomMargin = 50;
        layout.addView(laserScan, rParams);
        if(!SettingsActivity.enabledVolumeButton(this))
        {
            buttonScan = new Button(this);
            buttonScan.setTextColor(Color.WHITE);
            buttonScan.setTextColor(Color.WHITE);
            buttonScan.setTextSize(20);
            buttonScan.setGravity(Gravity.CENTER);
            buttonScan.setText("Scan barcode");
            buttonScan.setBackgroundColor(0xFF39C1CC);
            addScanButton();
            buttonScan.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    resumeScanning();
                }
            });
        }
        //! [Laser Button Added]
    }

    private void addScanButton()
    {
        RelativeLayout layout = (RelativeLayout)mBarcodePicker.getOverlayView();
        RelativeLayout.LayoutParams rParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, 160);
        rParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        rParams.bottomMargin = 50;
        rParams.leftMargin = 50;
        rParams.rightMargin = 50;
        layout.addView(buttonScan, rParams);
    }

	@Override
	public void didScan(ScanditSDKScanSession session) {
		List<ScanditSDKCode> newlyDecoded = session.getNewlyDecodedCodes();
        /*
        because the callback is invoked inside the thread running the barcode
        recognition, any UI update must be posted to the UI thread.
        In this example, we want to show the first decoded barcode in a
        splash screen covering the full display.
        */
        Message msg = mHandler.obtainMessage(UIHandler.SHOW_BARCODES,
                                             newlyDecoded);
        mHandler.removeCallbacks(mRunnable);
        mHandler.sendMessage(msg);
        mHandler.postDelayed(mRunnable, 3 * 1000);
        // pause scanning and clear the session. The scanning itself is resumed
        // when the user taps the screen.
        session.pauseScanning();
        session.clear();
	}
	
	@Override
	public void didEnter(String entry) {
        Message msg = mHandler.obtainMessage(UIHandler.SHOW_SEARCH_BAR_ENTRY, entry);
        mHandler.sendMessage(msg);
        
        mBarcodePicker.pauseScanning();
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
        finish();
    }

    //Volume buttons control
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {

        int action = event.getAction();
        int keyCode = event.getKeyCode();
            switch (keyCode) {
            case KeyEvent.KEYCODE_VOLUME_UP:
                if (action == KeyEvent.ACTION_DOWN) {
                    if(SettingsActivity.enabledVolumeButton(this))
                        resumeScanning();
                }
                return true;
            case KeyEvent.KEYCODE_VOLUME_DOWN:
                if (action == KeyEvent.ACTION_DOWN) {
                    if(SettingsActivity.enabledVolumeButton(this))
                        resumeScanning();
                }
                return true;
            default:
                return super.dispatchKeyEvent(event);
            }
    }

    private void resumeScanning() {
        //! [Resume]
        mBarcodePicker.resumeScanning();
        laserScan.setBackgroundResource(R.drawable.scan_line_white);
        //! [Resume]
        ((RelativeLayout)mBarcodePicker.getOverlayView()).removeView(buttonScan);
    }

    static private class UIHandler extends Handler {
        public static final int SHOW_BARCODES = 0;
        public static final int SHOW_SEARCH_BAR_ENTRY = 1;
        private WeakReference<SampleAimAndScanBarcodeActivity> mActivity;
        UIHandler(SampleAimAndScanBarcodeActivity activity) {
            mActivity = new WeakReference<SampleAimAndScanBarcodeActivity>(activity);
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
                message += "Scanned " + code.getSymbologyString() + " Code: \n";
                message += cleanData;

            }
            return message;
        }

        private void showSplash(String msg) {
            SampleAimAndScanBarcodeActivity activity = mActivity.get();
            RelativeLayout layout = activity.mBarcodePicker;
            layout.removeView(activity.barcodeView);
            RelativeLayout.LayoutParams rParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, 200);
            rParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            layout.addView(activity.barcodeView, rParams);
            activity.barcodeText.setText(msg);
            activity.laserScan.setBackgroundResource(R.drawable.scan_line_blue);
            if(!SettingsActivity.enabledVolumeButton(activity))
                activity.addScanButton();
        }
    }
}
