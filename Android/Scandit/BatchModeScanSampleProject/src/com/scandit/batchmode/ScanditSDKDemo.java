package com.scandit.batchmode;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.*;
import android.view.View.OnClickListener;
import android.widget.Button;
import com.mirasense.scanditsdk.ScanditSDKBarcodePicker;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOnScanListener;
import com.mirasense.scanditsdk.interfaces.ScanditSDKScanSession;

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

		Button activityAimButton = (Button) findViewById(R.id.aim_scan_button);
		activityAimButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if (mPaused) {
					return;
				}
				startActivity(new Intent(ScanditSDKDemo.this,
						SampleAimAndScanBarcodeActivity.class));
			}
		});

		Button activityConfirmButton = (Button) findViewById(R.id.scan_confirm_button);
		activityConfirmButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if (mPaused) {
					return;
				}
				startActivity(new Intent(ScanditSDKDemo.this,
						SampleScanAndConfirmBarcodeActivity.class));
			}
		});
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
