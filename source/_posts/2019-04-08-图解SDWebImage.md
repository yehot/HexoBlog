---
title: 图解SDWebImage
date: 2019-04-08 14:21:39
tags: iOS
---

## 整理了一下 SDWebImage 的时序图：

![SDWebImage时序图](https://upload-images.jianshu.io/upload_images/332029-5fb37890ad0348d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

markdown 源码如下:

```mermaid
sequenceDiagram

    participant UIImageView
    participant UIImageView(WebCache)
    participant UIView(WebCache)
    participant SDWebImageManager
    participant SDImageCache
    participant SDWebImageDownloader
    participant SDWebImageDownloaderOperation

    UIImageView->>UIImageView(WebCache): sd_setImageWithURL()
        activate UIImageView(WebCache)
    UIImageView(WebCache)->>UIView(WebCache): sd_internalSetImageWithURL()
    UIView(WebCache)->>SDWebImageManager:loadImageWithURL()
    
    
    alt hit memery cache
        SDWebImageManager->>SDImageCache:queryCacheOperationForKey()
        SDImageCache-->>SDWebImageManager:memory image
    else hit disk cache
        SDWebImageManager->>SDImageCache:imageFromMemoryCacheForKey()
        SDImageCache-->>SDWebImageManager:diskImageForKey()
    end


    opt no cache
        SDWebImageManager->>SDWebImageDownloader:downloadImageWithURL()
    
    SDWebImageDownloader->>SDWebImageDownloaderOperation:initWithRequest()
    SDWebImageDownloaderOperation-->>SDWebImageDownloader:            SDWebImageDownloaderCompletedBlock()
    
    SDWebImageDownloader-->>SDWebImageManager:SDWebImageDownloaderCompletedBlock()
    SDWebImageManager->>SDImageCache:storeImage()
   end
   

    SDWebImageManager-->>UIView(WebCache):image
    UIView(WebCache)-->>UIImageView(WebCache):sd_setImage()
    UIImageView(WebCache)-->>UIImageView:setImage()

        deactivate UIImageView(WebCache) 
```

## 源码思维导图

这个思维导图来自 @雷纯锋 的一篇源码解析，整理得非常细致，推荐：

![SDWebImage](https://upload-images.jianshu.io/upload_images/332029-2aef2d6a91bb8928.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 源码解析

SDWebImage 源码分析的文章网上已经很多了，[iOS SDWebImage 源码分析及架构设计探索](https://www.jianshu.com/p/e95baecb36b6) 这篇里的几幅配图都很不错，推荐。
