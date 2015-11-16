# React Native ImagePicker (remobile)
A image picker for react-native, supprt for ios and android

## Installation
```sh
npm install @remobile/react-native-image-picker --save
```
### Installation (iOS)
* Drag RCTImagePicker.xcodeproj to your project on Xcode.
* Click on your main project file (the one that represents the .xcodeproj) select Build Phases and drag libRCTImagePicker.a from the Products folder inside the RCTImagePicker.xcodeproj.
* Look for Header Search Paths and make sure it contains both $(SRCROOT)/../react-native/React as recursive.

### Installation (Android)
```gradle
...
include ':react-native-image-picker'
project(':react-native-image-picker').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-image-picker/android/RCTImagePicker')
```

* In `android/app/build.gradle`

```gradle
...
dependencies {
    ...
    compile project(':react-native-image-picker')
}
```

* register module (in MainActivity.java)

```java
import com.remobile.imagePicker.*;  // <--- import

public class MainActivity extends Activity implements DefaultHardwareBackBtnHandler {
  ......
  private RCTImagePickerPackage mImagePickerPackage; // <--- declare package
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    mReactRootView = new ReactRootView(this);
    mImagePickerPackage = new RCTImagePickerPackage(this);// <--- alloc package

    mReactInstanceManager = ReactInstanceManager.builder()
      .setApplication(getApplication())
      .setBundleAssetName("index.android.bundle")
      .setJSMainModuleName("index.android")
      .addPackage(new MainReactPackage())
      .addPackage(mImagePickerPackage)              // <------ add here
      .setUseDeveloperSupport(BuildConfig.DEBUG)
      .setInitialLifecycleState(LifecycleState.RESUMED)
      .build();

    mReactRootView.startReactApplication(mReactInstanceManager, "ExampleRN", null);

    setContentView(mReactRootView);
  }

  ......

  // <----- add start
  @Override
  public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
      super.onActivityResult(requestCode, resultCode, data);
      mImagePickerPackage.onActivityResult(requestCode, resultCode, data);
  }
  // <----- add end
}
```

### Screencasts
* ios
![ios](https://github.com/remobile/react-native-image-picker/blob/master/screencasts/ios.gif)
* android
![android](https://github.com/remobile/react-native-image-picker/blob/master/screencasts/android.png)

## Usage

### Example
```js
var React = require('react-native');
var {
    StyleSheet,
    View,
} = React;

var ImagePicker = require('react-native-image-picker');
var Button = require('react-native-simple-button');

module.exports = React.createClass({
    onOpen() {
        var options = {maximumImagesCount: 10, width: 400};
        ImagePicker.getPictures(options, (result) => {
            console.log('result = ', result);
        });
    },
    render() {
        return (
            <View style={styles.container}>
                <Button onPress={this.onOpen}>Photo</Button>
            </View>
        );
    },
});


var styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'transparent',
    },
});
```

### method
- `getPictures(options, callback)`
* options = {maximumImagesCount:Int, width: Int, height: Int, quality:Int}
* callback(result) result={error:String, files:Array<String>}


### thanks
* this project come from https://github.com/wymsee/cordova-imagePicker
