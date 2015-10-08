package io.restock.android;

/**
 * Created by Daniel Thevessen on 10/3/2015.
 */
public interface ProductPollListener {

    // Notify listener when the most recent product has either been saved to Wunderlist or undone
    public void onProductPolled(boolean saved);

    public void onProductSaved();

}
