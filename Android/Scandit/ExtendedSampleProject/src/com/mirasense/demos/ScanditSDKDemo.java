package com.mirasense.demos;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.*;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.mirasense.scanditsdk.ScanditSDKAutoAdjustingBarcodePicker;
import com.mirasense.scanditsdk.ScanditSDKBarcodePicker;
import com.mirasense.scanditsdk.ScanditSDKScanSettings;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOnScanListener;
import com.mirasense.scanditsdk.interfaces.ScanditSDKScanSession;
import com.mirasense.scanditsdkdemo.R;

/**
 * A slightly more sophisticated activity illustrating how to embed the
 * Scandit SDK into your app.
 *
 * This activity shows 3 different ways to use the Scandit Barcode Picker:
 *
 *   - as a full-screen barcode picker in a separate activity (see
 *     SampleFullScreenBarcodeActivity).
 *   - as a cropped-view picker, only showing a small part of the video
 *     feed running
 *   - as a scaled-view picker showing a down-scaled version of the video
 *     feed.
 *
 * Copyright 2014 Scandit AG
 */

/*
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
public class ScanditSDKDemo extends Activity implements ScanditSDKOnScanListener {
	// The main object for scanning barcodes.
	private ScanditSDKBarcodePicker mBarcodePicker;
	private boolean mPaused = true;
	@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
		
		if (Build.VERSION.SDK_INT >= 14) {
			super.setTheme(android.R.style.Theme_DeviceDefault);
		} else if (Build.VERSION.SDK_INT >= 11) {
			super.setTheme(android.R.style.Theme_Holo);
		} else {
			super.setTheme(android.R.style.Theme_Black_NoTitleBar);
		}

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.main);
        final RelativeLayout rootView = (RelativeLayout) findViewById(R.id.root);

        Button settingsButton = (Button) findViewById(R.id.settings);
        settingsButton.setOnClickListener(new OnClickListener() {
        	@Override
        	public void onClick(View v) {
				if (mPaused) {
					return;
				}
                startActivity(new Intent(ScanditSDKDemo.this, SettingsActivity.class));
        	}
        });

        /* Here we show how to start a new Activity that implements the Scandit
         * SDK as a full screen scanner. The Activity can be found in the
         * SampleFullScreenBarcodeActivity in this demo project. The old and
         * new GUIs can both be easily opened this way, which is also shown in 
         * the aforementioned activity. */
        Button activityButton = (Button) findViewById(R.id.fullscreen_button);
        activityButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
				if (mPaused) {
					return;
				}
                startActivity(new Intent(ScanditSDKDemo.this, 
                        SampleFullScreenBarcodeActivity.class));
            }
        });
        
        /* Creates a button that shows how to add a view that is a scaled down 
         * version of the full screen Scandit SDK scanner. To only see part of
         * the scanner, check out the third example. */
        Button scaledButton = (Button) findViewById(R.id.scaled_button);
        scaledButton.setOnClickListener(new OnClickListener() {
			@Override
            public void onClick(View v) {
                if (mBarcodePicker != null || mPaused){
                    return;
                }
				showScaledPicker(rootView);
            }
        });
        
        /*
         * Creates a button that shows how to add a cropped version of the full
         * screen Scandit SDK scanner. The cropping is accomplished by overlaying
         * parts of the scanner with an opaque view.
         */
        Button croppedButton = (Button) findViewById(R.id.cropped_button);
        croppedButton.setOnClickListener(new OnClickListener() {
			@Override
            public void onClick(View v) {
                if (mBarcodePicker != null|| mPaused){
                    return;
                }
				showCroppedPicker(rootView);
            }
        });
        
        // Must be able to run the portrait version for this button to work.
        if (!ScanditSDKAutoAdjustingBarcodePicker.canRunPortraitPicker()) {
            scaledButton.setEnabled(false);
            croppedButton.setEnabled(false);
        }
	}
	@SuppressWarnings("deprecation")
	private void showCroppedPicker(final RelativeLayout rootView) {
        ScanditSDKScanSettings settings = SettingsActivity.getSettings(this);
        settings.setScanningHotSpot(0.5f, 0.25f);
		mBarcodePicker = createPicker(settings);
		RelativeLayout.LayoutParams rParams;


		rParams = new RelativeLayout.LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		rParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
		rParams.bottomMargin = 20;
		rootView.addView(mBarcodePicker, rParams);

		WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
		Display display = wm.getDefaultDisplay();

		TextView overlay = new TextView(this);
		rParams = new RelativeLayout.LayoutParams(
				LayoutParams.MATCH_PARENT, display.getHeight() / 2);
		rParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		overlay.setBackgroundColor(0xFF000000);
		rootView.addView(overlay, rParams);
		overlay.setText("Touch to close");
		overlay.setGravity(Gravity.CENTER);
		overlay.setTextColor(0xFFFFFFFF);
		overlay.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				rootView.removeView(v);
				rootView.removeView(mBarcodePicker);
				mBarcodePicker.stopScanning();
				mBarcodePicker = null;
			}
		});
		mBarcodePicker.startScanning();
	}

	private ScanditSDKBarcodePicker createPicker(ScanditSDKScanSettings settings) {
		ScanditSDKBarcodePicker picker;
		picker = new ScanditSDKBarcodePicker(this,
				SampleFullScreenBarcodeActivity.sScanditSdkAppKey, settings);

		// Set UI settings according to the settings activity. To get a
		// short overview and explanation of the most used settings please
		// check the SampleFullScreenBarcodeActivity.
		SettingsActivity.applyUISettings(this, picker.getOverlayView());

		// Register listener, in order to be notified whenever a new code is
		// scanned
		picker.addOnScanListener(this);
		return picker;

	}
	@SuppressWarnings("deprecation")
	private void showScaledPicker(final RelativeLayout rootView) {
        ScanditSDKScanSettings settings = SettingsActivity.getSettings(this);
		mBarcodePicker = createPicker(settings);

		RelativeLayout.LayoutParams rParams;

		RelativeLayout r = new RelativeLayout(this);
		rParams = new RelativeLayout.LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		r.setBackgroundColor(0x00000000);
		rootView.addView(r, rParams);
		r.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				rootView.removeView(v);
				rootView.removeView(mBarcodePicker);
				mBarcodePicker.stopScanning();
				mBarcodePicker = null;
			}
		});

		WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
		Display display = wm.getDefaultDisplay();

		rParams = new RelativeLayout.LayoutParams(
				display.getWidth() * 3 / 4, display.getHeight() * 3 / 4);
		rParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
		rParams.bottomMargin = 20;
		rootView.addView(mBarcodePicker, rParams);
		mBarcodePicker.startScanning();
	}

	@Override
	protected void onPause() {
		mPaused = true;
	    // When the activity is in the background immediately stop the 
	    // scanning to save resources and free the camera.
	    if (mBarcodePicker != null) {
	        mBarcodePicker.stopScanning();
	    }

		super.onPause();
	}
	
	@Override
	protected void onResume() {
		mPaused = false;
	    // Once the activity is in the foreground again, restart scanning.
        if (mBarcodePicker != null) {
            mBarcodePicker.startScanning();
        }
	    super.onResume();
	}

	@Override
	public void onBackPressed() {
	    if (mBarcodePicker != null) {
	        mBarcodePicker.stopScanning();
	    }
	    finish();
	}

	@Override
	public void didScan(ScanditSDKScanSession session) {
		// We let the scanner continuously scan without showing results.
        Log.e("ScanditSDK", session.getNewlyDecodedCodes().get(0).getData());
	}
}
