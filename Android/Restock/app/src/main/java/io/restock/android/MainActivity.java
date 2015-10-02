package io.restock.android;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import com.mirasense.scanditsdk.ScanditSDKAutoAdjustingBarcodePicker;
import com.mirasense.scanditsdk.interfaces.ScanditSDK;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOnScanListener;
import com.mirasense.scanditsdk.interfaces.ScanditSDKScanSession;

/**
 * Created by danth on 10/2/2015.
 */
public class MainActivity extends Activity implements ScanditSDKOnScanListener {

    private static final String APP_KEY = "DTnmLAOp91sca/0zi96hHkz7a7miKpPIh16NA5yidMc";

    private ScanditSDK barcodePicker;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set up fullscreen
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        ScanditSDKAutoAdjustingBarcodePicker specificPicker = new ScanditSDKAutoAdjustingBarcodePicker(
                this, APP_KEY, ScanditSDKAutoAdjustingBarcodePicker.CAMERA_FACING_BACK);

        // Set our specific type of picker as content, cast up for later.
        setContentView(specificPicker);
        barcodePicker = specificPicker;

        barcodePicker.addOnScanListener(this);

    }

    @Override
    protected void onPause() {
        barcodePicker.stopScanning();
        super.onPause();
    }

    @Override
    public void didScan(ScanditSDKScanSession scanditSDKScanSession) {

    }


}
