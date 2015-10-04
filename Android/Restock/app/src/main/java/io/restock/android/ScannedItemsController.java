package io.restock.android;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Daniel Thevessen on 10/2/2015.
 */
public class ScannedItemsController {

    private Context context;
    private int list_id;
    private ProductPollListener pollListener;

    private LinkedList<Product> archivedProducts;
    private Queue<Product> productQueue;

    private LinkedList<Product> recommendations;

    private static final int UNDO_TIME = 4000;
    private Timer undoTimer;

    public ScannedItemsController(Context context, int list_id, ProductPollListener pollListener) {
        this.context = context;
        this.list_id = list_id;
        this.pollListener = pollListener;

        archivedProducts = new LinkedList<>();
        productQueue = new LinkedList<>();
        recommendations = new LinkedList<>();
    }

    public void pushProduct(Product product) {
        productQueue.add(product);
        undoTimer = new Timer();
        undoTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                save();
            }
        }, UNDO_TIME);
    }

    public void undo() {
        if (pollListener != null)
            pollListener.onProductPolled(false);
        undoTimer.cancel();
        productQueue.poll();
    }

    public void save() {
        undoTimer.cancel();
        Product product = productQueue.poll();
        if (product != null) {
            if (pollListener != null)
                pollListener.onProductPolled(true);

            saveToWunderlist(product);
        }
    }

    public void saveToWunderlist(final Product product) {
        String name = product.getName();
        if (name == null)
            return;
        // Truncate for Wunderlist API
        name = name.substring(0, Math.min(name.length(), 256));

        JSONObject params = new JSONObject();
        try {
            params.put("list_id", list_id);
            params.put("title", name);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        JsonObjectRequest wunderlistRequest = new JsonObjectRequest(Request.Method.POST,
                Constants.WUNDERLIST_TASKURL, params,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        archivedProducts.add(0, product);
//                        Toast.makeText(context, context.getString(R.string.wunderlist_success), Toast.LENGTH_SHORT).show();
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Toast.makeText(context, context.getString(R.string.wunderlist_error), Toast.LENGTH_SHORT).show();
                    }
                }) {
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String, String> headers = new HashMap<>();
                headers.put("X-Access-Token", LoginActivity.wunderlistAccessToken);
                headers.put("X-Client-ID", Constants.WUNDERLIST_CLIENT_ID);

                return headers;
            }


        };
        LoginActivity.requestQueue.add(wunderlistRequest);

    }

    public LinkedList<Product> getArchivedProducts() {
        return archivedProducts;
    }

    public boolean hasRecent() {
        return productQueue.size() > 0;
    }

    public LinkedList<Product> getRecommendations() {
        return recommendations;
    }
}
