//
//  RCTImagePicker.m
//  RCTImagePicker
//
//  Created by fangyunjiang on 15/11/12.
//  Copyright (c) 2015年 remobile. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "CDVCommandDelegateImpl.h"


@interface RCTImagePicker : NSObject <RCTBridgeModule, ELCImagePickerControllerDelegate>
@property (nonatomic, strong) ELCImagePickerController *imagePicker;
@property (nonatomic, strong) CDVCommandDelegateImpl* commandDelegate;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger quality;
@end

#define CRT_PHOTO_PREFIX @"crt_photo_"

@implementation RCTImagePicker

RCT_EXPORT_MODULE(ImagePicker)


RCT_EXPORT_METHOD(getPictures:(NSArray *)args success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)error) {
    CDVCommandDelegateImpl* commandDelegate = [[CDVCommandDelegateImpl alloc]initWithCallback:success error:error];
    NSDictionary *options = args[0];
    NSInteger maximumImagesCount = [[options objectForKey:@"maximumImagesCount"] integerValue];
    self.width = [[options objectForKey:@"width"] integerValue];
    self.height = [[options objectForKey:@"height"] integerValue];
    self.quality = [[options objectForKey:@"quality"] integerValue];
    
    // Create the an album controller and image picker
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    
    if (maximumImagesCount == 1) {
        albumController.immediateReturn = true;
        albumController.singleSelection = true;
    } else {
        albumController.immediateReturn = false;
        albumController.singleSelection = false;
    }
    
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    imagePicker.maximumImagesCount = maximumImagesCount;
    imagePicker.returnsOriginalImage = 1;
    imagePicker.imagePickerDelegate = self;
    
    albumController.parent = imagePicker;
    self.commandDelegate = commandDelegate;
    self.imagePicker = imagePicker;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CDVCommandDelegateImpl getTopPresentedViewController] presentViewController:imagePicker animated:YES completion:nil];
    });
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    CDVPluginResult* result = nil;
    NSMutableArray *resultStrings = [[NSMutableArray alloc] init];
    NSData* data = nil;
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSString* filePath;
    ALAsset* asset = nil;
    UIImageOrientation orientation = UIImageOrientationUp;;
    CGSize targetSize = CGSizeMake(self.width, self.height);
    for (NSDictionary *dict in info) {
        asset = [dict objectForKey:@"ALAsset"];
        // From ELCImagePickerController.m
        
        int i = 1;
        do {
            filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CRT_PHOTO_PREFIX, i++, @"jpg"];
        } while ([fileMgr fileExistsAtPath:filePath]);
        
        @autoreleasepool {
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = NULL;
            
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            if (picker.returnsOriginalImage) {
                imgRef = [assetRep fullResolutionImage];
                orientation = (UIImageOrientation)[assetRep orientation];
            } else {
                imgRef = [assetRep fullScreenImage];
            }
            
            UIImage* image = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:orientation];
            if (self.width == 0 && self.height == 0) {
                data = UIImageJPEGRepresentation(image, self.quality/100.0f);
            } else {
                UIImage* scaledImage = [self imageByScalingNotCroppingForSize:image toSize:targetSize];
                data = UIImageJPEGRepresentation(scaledImage, self.quality/100.0f);
            }
            
            if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                break;
            } else {
                [resultStrings addObject:[[NSURL fileURLWithPath:filePath] absoluteString]];
            }
        }
        
    }
    
    if (nil == result) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultStrings];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    });
    [self.commandDelegate sendPluginResult:result];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancel"];
    [self.commandDelegate sendPluginResult:pluginResult];
}

- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;
    
    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor == 0.0) {
            scaleFactor = heightFactor;
        } else if (heightFactor == 0.0) {
            scaleFactor = widthFactor;
        } else if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
    }
    
    UIGraphicsBeginImageContext(scaledSize); // this will resize
    
    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end