package com.remobile.imagePicker;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import android.content.Intent;
import android.content.Context;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import com.remobile.imagePicker.RCTImagePicker;


public class RCTImagePickerPackage implements ReactPackage {

	private Context mContext;
	private RCTImagePicker mModuleInstance;

	public RCTImagePickerPackage(Context ctx) {
		super();
		mContext = ctx;
	}


	@Override
	public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
		mModuleInstance = new RCTImagePicker(reactContext, mContext);
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

	public boolean handleActivityResult(final int requestCode, final int resultCode, final Intent data) {
		if (mModuleInstance == null) {
			return false;
		}

		return mModuleInstance.handleActivityResult(requestCode, resultCode, data);
	}
}
