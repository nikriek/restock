package io.restock.android;

import android.animation.LayoutTransition;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.media.SoundPool;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.Result;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Daniel Thevessen on 10/2/2015.
 */
public class MainActivity extends Activity implements ProductPollListener, ZXingScannerView.ResultHandler {

    private ZXingScannerView scannerView;

    private SoundPool soundPool;
    private int beepID;

    private static final int SCAN_INTERVAL = 2500;

    private Timer timer;

    private ScannedItemsController itemsController;

    // UI content
    private FrameLayout defaultOverlay;

    private View customOverlay;

    private ScrollView undoMenu;
    private TextView recentItemTextView;
    private ImageView recentItemThumbnail;

    private View overviewOverlay;

    private boolean paused = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set up fullscreen
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        scannerView = new ZXingScannerView(this);
        setContentView(scannerView);

        scannerView.setAutoFocus(true);
        scannerView.setFormats(Arrays.asList(BarcodeFormat.values()));

        soundPool = new SoundPool.Builder().build();
        beepID = soundPool.load(this, R.raw.beep, 1);

        defaultOverlay = scannerView;
        customOverlay = View.inflate(this, R.layout.scandit_custom_overlay, null);
        defaultOverlay.addView(customOverlay);
        defaultOverlay.setLayoutTransition(new LayoutTransition());

        // save references to UI elements
        RelativeLayout topOverlay = (RelativeLayout) defaultOverlay.findViewById(R.id.overlay_main);
        ImageButton menuButton = (ImageButton) defaultOverlay.findViewById(R.id.menu_button);
        final ImageButton flashlightButton = (ImageButton) defaultOverlay.findViewById(R.id.flashlight_button);
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)) {
            flashlightButton.setVisibility(View.GONE);
        } else {
            flashlightButton.setOnClickListener(new View.OnClickListener() {

                private boolean on = false;

                @Override
                public void onClick(View v) {
                    if (!on) {
                        flashlightButton.setImageResource(R.drawable.flashlight_turn_off_icon);
                    } else {
                        flashlightButton.setImageResource(R.drawable.flashlight_turn_on_icon);
                    }
                    on = !on;
                    scannerView.setFlash(on);
                }
            });
        }

        undoMenu = (ScrollView) defaultOverlay.findViewById(R.id.undo_menu);
        Button undoButton = (Button) undoMenu.findViewById(R.id.undo_button);
        recentItemTextView = (TextView) undoMenu.findViewById(R.id.product_info_text);
        recentItemThumbnail = (ImageView) undoMenu.findViewById(R.id.product_thumbnail);

        int wunderlist_list_id = getIntent().getIntExtra("wunderlist_list_id", -1);

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

                populateOverview();
                defaultOverlay.removeView(customOverlay);
                defaultOverlay.addView(overviewOverlay);

                paused = true;
                if (timer != null)
                    timer.cancel();
            }
        });


    }

    private void setupOverviewOverlay() {

        overviewOverlay = View.inflate(this, R.layout.view_overview, null);

        ImageButton closeButton = (ImageButton) overviewOverlay.findViewById(R.id.overview_close);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                defaultOverlay.removeView(overviewOverlay);
                defaultOverlay.addView(customOverlay);

                paused = false;
            }
        });

        final AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);
        dialog.setTitle(R.string.install_wunderlist);
        dialog.setMessage(R.string.wunderlist_not_found);
        dialog.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.wunderkinder.wunderlistandroid")));
                } catch (ActivityNotFoundException e) {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=com.wunderkinder.wunderlistandroid")));
                }
            }
        });

        Button gotoButton = (Button) overviewOverlay.findViewById(R.id.goto_wunderlist_button);
        gotoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent launchIntent = getPackageManager().getLaunchIntentForPackage("com.wunderkinder.wunderlistandroid");
                if (launchIntent != null) {
                    startActivity(launchIntent);
                } else {
                    dialog.show();
                }
            }
        });

        final Button logoutButton = (Button) overviewOverlay.findViewById(R.id.logout_button);
        logoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SharedPreferences.Editor editor = getSharedPreferences("Restock", Context.MODE_PRIVATE).edit();
                editor.remove("access_token");
                editor.commit();

                Intent logoutIntent = new Intent(MainActivity.this, LoginActivity.class);
                startActivity(logoutIntent);
                finish();
            }
        });

    }

    private void populateOverview() {
        LinearLayout recentList = (LinearLayout) overviewOverlay.findViewById(R.id.recent_scans_list);
        if (itemsController.getArchivedProducts().size() > 0)
            recentList.removeAllViews();
        int i = 0;
        for (Iterator<Product> iter = itemsController.getArchivedProducts().iterator(); iter.hasNext() && i < 5; i++) {
            Product product = iter.next();

            View recentScan = View.inflate(this, R.layout.view_scan_overview, null);
            TextView recentName = (TextView) recentScan.findViewById(R.id.scan_description);
            recentName.setText(product.getProductDescription());
            recentList.addView(recentScan);

            Button recentAction = (Button) recentScan.findViewById(R.id.scan_action);
            final Product finalProduct = product;
            recentAction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    itemsController.saveToWunderlist(finalProduct);
                    populateOverview();
                }
            });
        }

//        LinearLayout recommendationList = (LinearLayout) overviewOverlay.findViewById(R.id.recommendation_list);
//        recommendationList.removeAllViews();
//        for (Product product : itemsController.getRecommendations()) {
//            View recommendationScan = View.inflate(this, R.layout.view_scan_overview, null);
//            Button recommendationAction = (Button) recommendationScan.findViewById(R.id.scan_action);
//            recommendationAction.setText(R.string.add_to_list);
//
//            TextView recommendationName = (TextView) recommendationScan.findViewById(R.id.scan_description);
//            recommendationName.setText(product.getProductDescription());
//            recommendationList.addView(recommendationScan);
//        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        scannerView.stopCamera();
    }

    @Override
    protected void onResume() {
        super.onResume();
        scannerView.setResultHandler(this);
        scannerView.startCamera();
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

    @Override
    public void onProductSaved() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                populateOverview();
            }
        });

    }


    @Override
    public void handleResult(Result result) {
        Log.i("RESULT", "Test, paused: " + paused);
        if (!paused && result != null) {

            if (itemsController.hasRecent())
                itemsController.save();

            final String code = result.getText();

            scannerView.stopCamera();
            scannerView.startCamera();

            if (itemsController != null) {
                soundPool.play(beepID, 1, 1, 0, 0, 0.8f);

                paused = true;
                timer = new Timer();
                timer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        Log.i("PAUSED", "NO MORE");
                        paused = false;
                    }
                }, SCAN_INTERVAL);

                JsonObjectRequest productRequest = new JsonObjectRequest(Request.Method.GET,
                        Constants.UPC_URL + "?q=" + code,
                        new Response.Listener<JSONObject>() {
                            @Override
                            public void onResponse(JSONObject response) {
                                try {
                                    String upc = !response.isNull("upc") ? response.getString("upc") : null;
                                    String title = !response.isNull("title") ? response.getString("title") : null;
                                    String imageUrl = !response.isNull("image") ? response.getString("image") : null;
                                    String amount = !response.isNull("amount") ? response.getString("amount") : null;

                                    Log.i("SCAN", "Scanned image: " + imageUrl);

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
                                            LoginActivity.requestQueue.add(thumbnailRequest);
                                        }
                                        undoMenu.setVisibility(View.VISIBLE);
                                    } else {
                                        Toast.makeText(MainActivity.this, getString(R.string.not_in_database), Toast.LENGTH_SHORT).show();
                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();

                                    Toast.makeText(MainActivity.this, getString(R.string.not_in_database), Toast.LENGTH_SHORT).show();
                                }
                            }
                        },
                        new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                                Toast.makeText(MainActivity.this, getString(R.string.not_in_database), Toast.LENGTH_SHORT).show();
                            }
                        });
                LoginActivity.requestQueue.add(productRequest);
            }

        }
    }
}
