'use strict';

const ReactNative = require('react-native');
const {
    NativeModules,
} = ReactNative;

const RCTImagePicker = NativeModules.ImagePicker;

const ImagePicker = {
    getPictures:function (options, successCallback, errorCallback) {
        options = options || {};
        successCallback = successCallback || (() => {});
        errorCallback = errorCallback || (() => {});
        const params = {
            maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 15,
            width: options.width ? options.width : 0,
            height: options.height ? options.height : 0,
            quality: options.quality ? options.quality : 100,
        };
        RCTImagePicker.getPictures([params], successCallback, errorCallback);
    },
};

module.exports = ImagePicker;
