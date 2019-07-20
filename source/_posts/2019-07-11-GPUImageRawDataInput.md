---
title: GPUImageRawDataInput 使用示例
tags: iOS
toc: true
date: 2019-07-12 09:52:49
description:
---
<meta name="referrer" content="no-referrer" />


全网找了一圈也没有看到一个 GPUImageRawDataInput 的完整 Demo，这里提供一个简单的使用示例：

```ObjC
#import "RawDataViewController.h"
#import "GPUImage.h"

@interface RawDataViewController ()

@property (nonatomic, strong) GPUImageRawDataInput *rawDataInput;
@property (nonatomic, strong) GPUImageRawDataOutput *rawDataOutput;

@property (nonatomic, strong) GPUImageBrightnessFilter *filter;
@property (nonatomic, strong) GPUImageView *filterView;

@end


@implementation RawDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    [self.view addSubview:self.filterView];
    
    
    // 1. UIImage -> CGImage -> CFDataRef -> UInt8 * data
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    CGImageRef newImageSource = [image CGImage];
    CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
    GLubyte* imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    // 2. UInt8 * data -> GPUImageRawDataInput
    self.rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:image.size pixelFormat:GPUPixelFormatRGBA];
    
    self.filter = [[GPUImageBrightnessFilter alloc] init];
    self.filter.brightness = 0.1;
    

    [self.rawDataInput addTarget:self.filter];
    // 3. 输出到 GPUImageView
    [self.filter addTarget:self.filterView];

    
    // 4. 同时输出到 raw data output
    self.rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:image.size resultsInBGRAFormat:YES];
    [self.filter addTarget:self.rawDataOutput];
    
    // important
    [self.filter useNextFrameForImageCapture];
    [self.rawDataInput processData];
    
    
    // 5. read data from GPUImageRawDataOutput
    [self.rawDataOutput lockFramebufferForReading];
    
    GLubyte *outputBytes = [self.rawDataOutput rawBytesForImage];
    NSInteger bytesPerRow = [self.rawDataOutput bytesPerRowInOutput];

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, outputBytes, bytesPerRow * image.size.height, NULL);
    CGImageRef cgImage = CGImageCreate(image.size.width, image.size.height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
    
    [self.rawDataOutput unlockFramebufferAfterReading];

    // 断点到这一行，查看 outImage
    UIImage *outImage = [UIImage imageWithCGImage:cgImage];
    NSLog(@"%@", outImage);
}

@end

```

## 使用场景

这个示例的使用场景：

- 用 ffmpeg 将视频流的一帧读取成 RGBA 数据；
- 将数据传入 GPUImageRawDataInput -> 添加滤镜 -> 输出到 GPUImageRawDataOutput
- 从 GPUImageRawDataOutput 中取出 RGBA 数据，再交给 ffmpeg 编码，写入新的视频文件

注：

- 这个流程使用 GPUImage 完全可以完成，不需要 ffmpeg；需要跨平台的编解码并加滤镜时，可以使用 OpenGL 对视频流加滤镜；
- 在 Xcode 里断点查看 UIImage 的方法如下：


![](https://upload-images.jianshu.io/upload_images/332029-738e3b8c4ba387ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
