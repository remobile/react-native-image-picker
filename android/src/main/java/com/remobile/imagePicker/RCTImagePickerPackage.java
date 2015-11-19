package com.remobile.imagePicker;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;


public class RCTImagePickerPackage implements ReactPackage {

    private Activity activity;
    private RCTImagePicker mModuleInstance;

    public RCTImagePickerPackage(Activity activity) {
        super();
        this.activity = activity;
    }


    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        mModuleInstance = new RCTImagePicker(reactContext, activity);
        return Arrays.<NativeModule>asList(
                mModuleInstance
        );
    }

    @Override
    public List<Class<? extends JavaScriptModule>> createJSModules() {
        return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Arrays.<ViewManager>asList();
    }

    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        if (mModuleInstance != null) {
            mModuleInstance.onActivityResult(requestCode, resultCode, data);
        }
    }
}
