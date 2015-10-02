package io.restock.android;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.mirasense.scanditsdk.ScanditSDKAutoAdjustingBarcodePicker;
import com.mirasense.scanditsdk.interfaces.ScanditSDK;
import com.mirasense.scanditsdk.interfaces.ScanditSDKCode;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOnScanListener;
import com.mirasense.scanditsdk.interfaces.ScanditSDKScanSession;

import org.json.JSONObject;

import java.util.List;

/**
 * Created by danth on 10/2/2015.
 */
public class MainActivity extends Activity implements ScanditSDKOnScanListener {

    private ScanditSDK barcodePicker;

    public static RequestQueue requestQueue;

    private ScannedItemsController itemsController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set up fullscreen
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        ScanditSDKAutoAdjustingBarcodePicker specificPicker = new ScanditSDKAutoAdjustingBarcodePicker(
                this, Constants.SCANDIT_APP_KEY, ScanditSDKAutoAdjustingBarcodePicker.CAMERA_FACING_BACK);

        // Set our specific type of picker as content, cast up for later.
        setContentView(specificPicker);
        barcodePicker = specificPicker;

        barcodePicker.addOnScanListener(this);

        // inflate custom overlay and add it to Scandit's overlay
        RelativeLayout defaultOverlay = (RelativeLayout) barcodePicker.getOverlayView();
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        View customOverlay = inflater.inflate(R.layout.scandit_custom_overlay, null);
        defaultOverlay.addView(customOverlay);

        requestQueue = Volley.newRequestQueue(this);
        requestQueue.start();

        int wunderlist_list_id = -1;
        // TODO init wunderlist and get "groceries" list

        itemsController = new ScannedItemsController(this, wunderlist_list_id);

    }

    @Override
    protected void onPause() {
        barcodePicker.stopScanning();
        super.onPause();
    }

    @Override
    protected void onResume() {
        barcodePicker.startScanning();
        super.onResume();
    }


    @Override
    public void didScan(ScanditSDKScanSession session) {

        List<ScanditSDKCode> codes = session.getNewlyDecodedCodes();
        if (codes != null && codes.size() > 0) {
            ScanditSDKCode selectedCode = codes.get(codes.size() - 1);

            if (itemsController != null) {
                JsonObjectRequest productRequest = new JsonObjectRequest(Request.Method.GET,
                        "",
                        new Response.Listener<JSONObject>() {
                            @Override
                            public void onResponse(JSONObject response) {
                                // TODO
                            }
                        },
                        new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                            }
                        });
            }

        }

    }


}
