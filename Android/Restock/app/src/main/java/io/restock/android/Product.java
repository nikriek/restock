package io.restock.android;

/**
 * Created by danth on 10/2/2015.
 */
public class Product {

    private String upc;
    private String name;
    private String imageUrl;

    public Product(String upc, String name, String imageUrl) {
        this.upc = upc;
        this.name = name;
        this.imageUrl = imageUrl;
    }

    public String getUPC() {
        return upc;
    }

    public String getName() {
        return name;
    }

    public String getImageUrl() {
        return imageUrl;
    }

}
