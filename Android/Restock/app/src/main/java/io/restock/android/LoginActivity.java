package io.restock.android;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.net.Uri;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.os.Handler;
import android.text.Html;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Daniel Thevessen on 10/3/2015.
 */
public class LoginActivity extends Activity {

    // Json requests via Android Volley
    public static RequestQueue requestQueue;

    public static String wunderlistAccessToken;

    private ProgressBar progress;
    private RelativeLayout loginView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_login);

        // set up request queue for JSON requests
        requestQueue = Volley.newRequestQueue(this);
        requestQueue.start();

        progress = (ProgressBar) findViewById(R.id.login_progress);
        loginView = (RelativeLayout) findViewById(R.id.login_view);

        Intent intent = getIntent();
        SharedPreferences prefs = getSharedPreferences("Restock", Context.MODE_PRIVATE);
        String access_token = prefs.getString("access_token", null);
        if (access_token != null) {
            progress.setVisibility(View.VISIBLE);
            loginView.setVisibility(View.GONE);

            wunderlistAccessToken = access_token;

            loadListID();
        } else if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri uri = intent.getData();
            String code = uri.getHost();

            login(code);
        }

        Button loginWunderlist = (Button) loginView.findViewById(R.id.login_wunderlist_button);
        loginWunderlist.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.wunderlist.com/oauth/authorize?client_id=" +
                        Constants.WUNDERLIST_CLIENT_ID + "&redirect_uri=http://restock.thinkcarl.com/redirect&state=NOTRANDOM"));
                startActivity(browserIntent);
            }
        });

    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri uri = intent.getData();
            String code = uri.getHost();

            login(code);

        }
    }

    private void login(String code) {

        progress.setVisibility(View.VISIBLE);
        loginView.setVisibility(View.GONE);

        JSONObject params = new JSONObject();
        try {
            params.put("client_id", Constants.WUNDERLIST_CLIENT_ID);
            params.put("client_secret", Constants.WUNDERLIST_CLIENT_SECRET);
            params.put("code", code);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        JsonObjectRequest loginRequest = new JsonObjectRequest(Request.Method.POST,
                "https://www.wunderlist.com/oauth/access_token", params.toString(),
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            wunderlistAccessToken = response.getString("access_token");

                            SharedPreferences.Editor editor = getSharedPreferences("Restock", Context.MODE_PRIVATE).edit();
                            editor.putString("access_token", wunderlistAccessToken);
                            editor.apply();

                            loadListID();
                        } catch (JSONException e) {
                            Toast.makeText(LoginActivity.this, getString(R.string.login_error), Toast.LENGTH_LONG).show();
                            finish();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Toast.makeText(LoginActivity.this, getString(R.string.login_error), Toast.LENGTH_LONG).show();
                        finish();
                    }
                });
        requestQueue.add(loginRequest);

    }

    private void loadListID() {

        JSONObject params = new JSONObject();
        try {
            params.put("access_token", wunderlistAccessToken);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        JsonObjectRequest loadListRequest = new JsonObjectRequest(Request.Method.GET,
                "http://restock.thinkcarl.com/listId?access_token=" + wunderlistAccessToken,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            Log.e("LIST", wunderlistAccessToken + "" + response.toString());
                            int list_id = response.getInt("id");
                            Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                            intent.putExtra("wunderlist_list_id", list_id);
                            startActivity(intent);
                            finish();
                        } catch (JSONException e) {
                            Toast.makeText(LoginActivity.this, getString(R.string.login_error), Toast.LENGTH_LONG).show();
                            Log.e("LIST", e.getMessage());
                            finish();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Toast.makeText(LoginActivity.this, getString(R.string.login_error), Toast.LENGTH_LONG).show();
                        error.printStackTrace();
                        finish();
                    }
                });
        requestQueue.add(loadListRequest);

    }

}
