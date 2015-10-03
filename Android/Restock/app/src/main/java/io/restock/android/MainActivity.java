package io.restock.android;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.media.Image;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.mirasense.scanditsdk.ScanditSDKAutoAdjustingBarcodePicker;
import com.mirasense.scanditsdk.interfaces.ScanditSDK;
import com.mirasense.scanditsdk.interfaces.ScanditSDKCode;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOnScanListener;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOverlay;
import com.mirasense.scanditsdk.interfaces.ScanditSDKScanSession;
import com.mirasense.scanditsdk.internal.gui.ScanditSDKOverlayView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

/**
 * Created by danth on 10/2/2015.
 */
public class MainActivity extends Activity implements ScanditSDKOnScanListener, ProductPollListener {

    private ScanditSDK barcodePicker;
    private ScanditSDKOverlay sdkOverlay;

    private static final long SCAN_INTERVAL = (long) 2e9;
    private long lastScanTime = 0;

    // Json requests via Android Volley
    public static RequestQueue requestQueue;

    private ScannedItemsController itemsController;

    // UI content
    private RelativeLayout defaultOverlay;

    private View customOverlay;
    private RelativeLayout topOverlay;
    private ImageButton menuButton;

    private ScrollView undoMenu;
    private Button undoButton;
    private TextView recentItemTextView;
    private ImageView recentItemThumbnail;

    private View overviewOverlay;

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
        sdkOverlay = barcodePicker.getOverlayView();
        sdkOverlay.setBeepEnabled(true);
        sdkOverlay.setVibrateEnabled(false);
        sdkOverlay.setTorchEnabled(false);

        defaultOverlay = (RelativeLayout) sdkOverlay;
        customOverlay = View.inflate(this, R.layout.scandit_custom_overlay, null);
        defaultOverlay.addView(customOverlay);

        // save references to UI elements
        topOverlay = (RelativeLayout) defaultOverlay.findViewById(R.id.overlay_main);
        menuButton = (ImageButton) defaultOverlay.findViewById(R.id.menu_button);

        undoMenu = (ScrollView) defaultOverlay.findViewById(R.id.undo_menu);
        undoButton = (Button) undoMenu.findViewById(R.id.undo_button);
        recentItemTextView = (TextView) undoMenu.findViewById(R.id.product_info_text);
        recentItemThumbnail = (ImageView) undoMenu.findViewById(R.id.product_thumbnail);

        // set up request queue for JSON requests
        requestQueue = Volley.newRequestQueue(this);
        requestQueue.start();

        int wunderlist_list_id = -1;
        // TODO init wunderlist and get "groceries" list

        itemsController = new ScannedItemsController(this, wunderlist_list_id, this);

        undoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                itemsController.undo();
            }
        });

        setupOverviewOverlay();

        menuButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                topOverlay.setVisibility(View.GONE);
//                if (undoMenu.getVisibility() == View.VISIBLE)
//                    undoMenu.setVisibility(View.INVISIBLE);
//
//                overviewOverlay.setVisibility(View.VISIBLE);

                defaultOverlay.removeView(customOverlay);
                defaultOverlay.addView(overviewOverlay);

//                sdkOverlay.setTorchEnabled(false);
                sdkOverlay.drawViewfinder(false);
            }
        });


    }

    private void setupOverviewOverlay() {

        overviewOverlay = View.inflate(this, R.layout.view_overview, null);

        ImageButton closeButton = (ImageButton) overviewOverlay.findViewById(R.id.overview_close);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                topOverlay.setVisibility(View.VISIBLE);
//                if (undoMenu.getVisibility() == View.INVISIBLE)
//                    undoMenu.setVisibility(View.VISIBLE);
//
//                overviewOverlay.setVisibility(View.GONE);

                defaultOverlay.removeView(overviewOverlay);
                defaultOverlay.addView(customOverlay);

//                sdkOverlay.setTorchEnabled(true);
                sdkOverlay.drawViewfinder(true);
            }
        });

        // Populating for testing purposes. So, TODO.
        LinearLayout recentList = (LinearLayout) overviewOverlay.findViewById(R.id.recent_scans_list);
        for (int i = 0; i < 2; i++) {
            View recentScan = View.inflate(this, R.layout.view_scan_overview, null);
            TextView recentName = (TextView) recentScan.findViewById(R.id.scan_description);
            recentName.setText("Ein ganz tolles Produkt");
            recentList.addView(recentScan);
        }

        LinearLayout recommendationList = (LinearLayout) overviewOverlay.findViewById(R.id.recommendation_list);
        for (int i = 0; i < 2; i++) {
            View recommendationScan = View.inflate(this, R.layout.view_scan_overview, null);
            Button recommendationAction = (Button) recommendationScan.findViewById(R.id.scan_action);
            recommendationAction.setText(R.string.add_to_list);

            TextView recommendationName = (TextView) recommendationScan.findViewById(R.id.scan_description);
            recommendationName.setText("Ein ganz tolles Produkt");
            recommendationList.addView(recommendationScan);
        }

//        overviewOverlay.setVisibility(View.GONE);
//        defaultOverlay.addView(overviewOverlay);

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

        if (System.nanoTime() - lastScanTime < SCAN_INTERVAL)
            return;
        else
            lastScanTime = System.nanoTime();

        if (itemsController.hasRecent())
            itemsController.save();

        List<ScanditSDKCode> codes = session.getNewlyDecodedCodes();
        if (codes != null && codes.size() > 0) {
            final ScanditSDKCode selectedCode = codes.get(codes.size() - 1);

            if (itemsController != null) {
                JsonObjectRequest productRequest = new JsonObjectRequest(Request.Method.GET,
                        Constants.UPC_URL + "?q=" + selectedCode.getData(),
                        new Response.Listener<JSONObject>() {
                            @Override
                            public void onResponse(JSONObject response) {
                                try {
                                    String upc = !response.isNull("upc") ? response.getString("upc") : null;
                                    String title = !response.isNull("title") ? response.getString("title") : null;
                                    String imageUrl = !response.isNull("image") ? response.getString("image") : null;
                                    String amount = !response.isNull("amount") ? response.getString("amount") : null;

                                    if (upc != null && title != null) {
                                        Product product = new Product(upc, title, imageUrl, amount);
                                        itemsController.pushProduct(product);

                                        recentItemTextView.setText(Html.fromHtml("<b>" + product.getProductDescription() + "</b> " + getString(R.string.added)));
                                        if (imageUrl != null) {
                                            ImageRequest thumbnailRequest = new ImageRequest(imageUrl,
                                                    new Response.Listener<Bitmap>() {
                                                        @Override
                                                        public void onResponse(Bitmap bitmap) {
                                                            recentItemThumbnail.setImageBitmap(bitmap);
                                                            recentItemThumbnail.setVisibility(View.VISIBLE);
                                                        }
                                                    }, 0, 0, ImageView.ScaleType.CENTER_INSIDE, null,
                                                    new Response.ErrorListener() {
                                                        public void onErrorResponse(VolleyError error) {
                                                        }
                                                    });
                                            requestQueue.add(thumbnailRequest);
                                        }
                                        undoMenu.setVisibility(View.VISIBLE);

                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        },
                        new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                                // No error output in here (for now)
                            }
                        });
                requestQueue.add(productRequest);
            }

        }

    }


    @Override
    public void onProductPolled(boolean saved) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                recentItemTextView.setText("");
                recentItemThumbnail.setBackground(null);
                recentItemThumbnail.setVisibility(View.GONE);
                undoMenu.setVisibility(View.GONE);
            }
        });
    }


}
