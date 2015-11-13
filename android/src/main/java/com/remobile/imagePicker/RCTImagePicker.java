/**
 * An Image Picker Plugin for React-Native.
 */
package com.remobile.imagePicker;

import java.util.ArrayList;
import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.util.Log;

import com.facebook.react.bridge.*;


public class RCTImagePicker extends ReactContextBaseJavaModule {
	private Callback callback;
	private Context mActivityContext;

	public RCTImagePicker(ReactApplicationContext reactContext, Context activityContext) {
		super(reactContext);
		mActivityContext = activityContext;
	}

	@Override
	public String getName() {
		return "RCTImagePicker";
	}

	@ReactMethod
	public void getPictures(ReadableMap options, Callback callback) throws Exception {
		int max = 20;
		int desiredWidth = 0;
		int desiredHeight = 0;
		int quality = 100;

		this.callback = callback;

		if (options.hasKey("maximumImagesCount") && !options.isNull("maximumImagesCount")) {
			max = options.getInt("maximumImagesCount");
		}
		if (options.hasKey("width") && !options.isNull("width")) {
			desiredWidth = options.getInt("width");
		}
		if (options.hasKey("height") && !options.isNull("height")) {
			desiredWidth = options.getInt("height");
		}
		if (options.hasKey("quality") && !options.isNull("quality")) {
			quality = options.getInt("quality");
		}


		ReactApplicationContext context = getReactApplicationContext();
		Intent intent = new Intent(context, MultiImageChooserActivity.class);
		intent.putExtra("MAX_IMAGES", max);
		intent.putExtra("WIDTH", desiredWidth);
		intent.putExtra("HEIGHT", desiredHeight);
		intent.putExtra("QUALITY", quality);

		((Activity)mActivityContext).startActivityForResult(intent, 0);
	}

	public boolean handleActivityResult(final int requestCode, final int resultCode, final Intent data) {
		if (requestCode == 0) {
			WritableMap result = Arguments.createMap();
			result.putNull("error");

			if (resultCode == Activity.RESULT_OK && data != null) {
				ArrayList<String> fileNames = data.getStringArrayListExtra("MULTIPLEFILENAMES");
				WritableArray files = Arguments.createArray();
				for (String filename : fileNames) {
					files.pushString(filename);
				}
				result.putArray("files", files);
			} else if (resultCode == Activity.RESULT_CANCELED && data != null) {
				String error = data.getStringExtra("ERRORMESSAGE");
				result.putString("error", error);
			} else if (resultCode == Activity.RESULT_CANCELED) {
				result.putString("error", "cancel");
			} else {
				result.putString("error", "No images selected");
			}
			this.callback.invoke(result);
			return true;
		}
		return false;
	}
}