package com.phonegap.reserve;


import android.os.Bundle;

import com.phonegap.*;


public class App extends DroidGap {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.loadUrl("http://loris-7.ddns.comp.nus.edu.sg/reserve");
    }
}