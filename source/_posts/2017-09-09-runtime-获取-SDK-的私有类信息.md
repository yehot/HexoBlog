---
title: runtime 获取 SDK 的私有类信息
date: 2017-09-09 14:27:22
tags: iOS runtime
description: 
---
<meta name="referrer" content="no-referrer" />
<!-- toc -->

近期的一个项目里，我们自己开发的埋点模块和友盟 SDK 在兼容上发生了点问题，定位问题的过程中，想看看友盟 SDK 里有哪些类，但是友盟 SDK 只提供了 3 个 public header：

![uimeng-sdk](http://upload-images.jianshu.io/upload_images/332029-63ff2c26ab3e3bbd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

办法其实也很简单，用 runtime 很容易 get 到当前项目里都有哪些类文件被编译进来了，即使打包成 `.a` `.framework` 的 SDK 也不例外

> 更新：runtime 的方式在文末，先说简单的方式：

## 一、获取 SDK 里的私有类名

使用 lipo + ar 命令：

```
cd UMMobClick.framework
// 拆分出单个架构
lipo UMMobClick   -thin arm64 -output UMMobClick_arm64

mkdir Objects
cd Objects

ar -x ../UMMobClick_arm64
```

以下是输出结果

```
DplusMobClick.o                 TException.o                    UMAggregatedValue.o
MobClick.o                      TMemoryBuffer.o                 UMCachedDB.o
MobClickApp.o                   TProtocolException.o            UMDeflated.o
MobClickConfig.o                TProtocolUtil.o                 UMEventMgr.o
MobClickEnvelope.o              TTransportException.o           UMGameLevel.o
MobClickEvent.o                 UMADplus.o                      UMHelper.o
MobClickGameAnalytics.o         UMANBaseEvent.o                 UMOpenUDID.o
MobClickInternal.o              UMANEkv.o                       UMPayloadBuild.o
MobClickJob.o                   UMANError.o                     UMProtocolData.o
MobClickLocation.o              UMANEvent.o                     UMUaDB.o
MobClickSession.o               UMANTerminate.o                 UMWorkDispatch.o
MobClickSocialAnalytics.o       UMANUtil.o                      UmengUncaughtExceptionHandler.o
MobClickSocialOperation.o       UMANWorker.o                    __.SYMDEF
MobClickUtility.o               UMANetWork.o                    umeng_analytics.o
TBinaryProtocol.o               UMAOCTools.o                    umeng_envelope.o
```

## 二、使用 LLDB 命令打印一个类的全部属性、方法

在上一步获取到类名的情况下，使用简单的一行 LLDB 命令，就可以获取到一个类的属性、方法，不用写一行代码，且打印内容也便于阅读：

在运行着的项目任意位置打断点，在控制台 `po` 需要打印的类名 + `_shortMethodDescription:`，eg：

```
 po [MobClickSession _shortMethodDescription]
```

输出：

```
<MobClickSession: 0x108788af8>:
in MobClickSession:
    Class Methods:
        + (void) profileSignInPUID:(id)arg1; (0x108755da6)
        + (void) profileSignInPUID:(id)arg1 withProvider:(id)arg2; (0x108755dc6)
        + (void) profileSignOff; (0x108755e21)
        + (void) signInPUID:(id)arg1 provider:(id)arg2; (0x108755c74)
        + (void) startWithAppkey:(id)arg1 reportPolicy:(int)arg2 channelId:(id)arg3; (0x1087563b1)
        + (void) startWithAppkey:(id)arg1; (0x108756994)
        + (id) sharedInstance; (0x108755b76)
    Properties:
        @property (nonatomic) BOOL observerRegistered;  (@synthesize observerRegistered = _observerRegistered;)
        @property (nonatomic) BOOL appInBackGround;  (@synthesize appInBackGround = _appInBackGround;)
        @property (nonatomic) BOOL appBeKilling;  (@synthesize appBeKilling = _appBeKilling;)
        @property (nonatomic) BOOL appCrashed;  (@synthesize appCrashed = _appCrashed;)
        @property (nonatomic) int sessionStatus;  (@synthesize sessionStatus = _sessionStatus;)
        @property (nonatomic) double lastLaunchTime;  (@synthesize lastLaunchTime = _lastLaunchTime;)
    Instance Methods:
        - (void) setObserverRegistered:(BOOL)arg1; (0x1087569be)
        - (void) setAppCrashed:(BOOL)arg1; (0x108756a1e)
        - (void) setAppBeKilling:(BOOL)arg1; (0x1087569fe)
        - (void) setSessionStatus:(int)arg1; (0x108756a3e)
        - (void) setLastLaunchTime:(double)arg1; (0x108756a60)
        - (void) beginSessionTime; (0x108755fd4)
        - (double) endSessionTime; (0x108756340)
        - (void) appActivate:(id)arg1; (0x108755e41)
        - (BOOL) observerRegistered; (0x1087569ae)
        - (void) appInactivate:(id)arg1; (0x108755ea0)
        - (void) ensureSessionLaunch; (0x10875638e)
        - (BOOL) appInBackGround; (0x1087569ce)
        - (void) setAppInBackGround:(BOOL)arg1; (0x1087569de)
        - (BOOL) appBeKilling; (0x1087569ee)
        - (BOOL) appCrashed; (0x108756a0e)
        - (int) sessionStatus; (0x108756a2e)
        - (double) lastLaunchTime; (0x108756a4e)
(NSObject ...)
```

> 当然使用 runtime 的方式，也可以实现以上需求，以下是探索过程：

## 三、使用 runtime 的方式获取 SDK 的私有类名

执行以下代码：

```ObjC
#import <objc/runtime.h>

- (void)showAllClassNameInProject {
    int allClasses = objc_getClassList(NULL,0);
    Class *classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * allClasses);
    allClasses = objc_getClassList(classes, allClasses);
    
    for (int i = 0; i < allClasses; i++) {
        Class clazz = classes[i];
        NSLog(@"当前项目中全部 class: %@", NSStringFromClass(clazz));
    }
    free(classes);
}
```

输出：

```c
2017-09-09 14:42:20.248  当前项目中全部 class WKObject
2017-09-09 14:42:20.248  当前项目中全部 class WKNSURLRequest
2017-09-09 14:42:20.249  当前项目中全部 class WKNSURLAuthenticationChallenge
2017-09-09 14:42:20.249  当前项目中全部 class WKNSURL
2017-09-09 14:42:20.249  当前项目中全部 class WKNSString
2017-09-09 14:42:20.249  当前项目中全部 class WKNSError
2017-09-09 14:42:20.249  当前项目中全部 class JSExport
2017-09-09 14:42:20.249  当前项目中全部 class NSLeafProxy
2017-09-09 14:42:20.249  当前项目中全部 class NSProxy
2017-09-09 14:42:20.250  当前项目中全部 class _UITargetedProxy
2017-09-09 14:42:20.250  当前项目中全部 class _UIViewServiceReplyControlTrampoline
2017-09-09 14:42:20.250  当前项目中全部 class _UIViewServiceReplyAwaitingTrampoline
2017-09-09 14:42:20.290  当前项目中全部 class _UIViewServiceUIBehaviorProxy
2017-09-09 14:42:20.290  当前项目中全部 class _UIViewServiceImplicitAnimationDecodingProxy
2017-09-09 14:42:20.290  当前项目中全部 class _UIViewServiceImplicitAnimationEncodingProxy
……
// 以下省略 5000 多行
```

可以看到，把项目中导入的系统的 `UIKit.framework` `Foundation.framework` 都打出来了，如果我们再人肉排除 `UI`、`_UI`、`NS` 打头的类:

```c
   Class clazz = classes[i];
   NSString *className = NSStringFromClass(clazz);
   if (![className hasPrefix:@"UI"] && ![className hasPrefix:@"_UI"] && ![className hasPrefix:@"NS"]) {
       NSLog(@"当前项目中全部 class: %@", className);
   }
```

结果如下：

``` c
2017-09-09 15:06:35.995  当前项目中全部 class: WKObject
2017-09-09 15:06:35.995  当前项目中全部 class: WKNSURLRequest
2017-09-09 15:06:35.995  当前项目中全部 class: WKNSURLAuthenticationChallenge
2017-09-09 15:06:35.995  当前项目中全部 class: WKNSURL
2017-09-09 15:06:35.996  当前项目中全部 class: WKNSString
2017-09-09 15:06:35.996  当前项目中全部 class: WKNSError
2017-09-09 15:06:35.996  当前项目中全部 class: JSExport
2017-09-09 15:06:35.996  当前项目中全部 class: WebMainThreadInvoker
2017-09-09 15:06:35.996  当前项目中全部 class: BSZeroingWeakReferenceProxy
2017-09-09 15:06:35.996  当前项目中全部 class: __NSGenericDeallocHandler
// 省略 2000 多行
```

系统框架类名前缀也是五花八门，if else 的排除是不可能了，得换个思路。

那么，到底怎么区分一个类是系统的，还是用户自定义的呢？查了一下，`还真没有办法区分`，因为**这个问题根本就不成立**:
所谓`系统的类`，说白了就是苹果提供的 framework 里的类，也都是苹果自己`自定义`的。

中文搜不到，找了一圈在 `stackoverflow` 找到了这个：[How to judge a class whether System's or Custom's?](https://stackoverflow.com/questions/20534140/how-to-judge-a-class-whether-systems-or-customs)

简单点说就是，虽然区分不了什么系统不系统的类，但是 Framework 是分动态库和静态库的。而苹果开发的 Framework 都是以动态库的形式参与编译打包，只链接到 app 里，不会打包到 App 的 Bundle 中。但所有除了苹果以外的开发者，都只能以静态库 Framework 打包 SDK（上架），代码都会被打包到 App 的 Bundle 中，那么问题就简单了：

```ObjC
- (void)showCustomClassNameOnly {
    int allClasses = objc_getClassList(NULL,0);
    Class *classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * allClasses);
    allClasses = objc_getClassList(classes, allClasses);
    
    for (int i = 0; i < allClasses; i++) {
        Class clazz = classes[i];
        NSBundle *b = [NSBundle bundleForClass:clazz];
        if (b == [NSBundle mainBundle]) {
            NSLog(@"自定义 class: %@", NSStringFromClass(clazz));
        }
    }
    free(classes);
}
```

输出结果如下：

```c
2017-09-09 14:43:27.291  自定义 class: UMTMemoryBuffer
2017-09-09 14:43:27.291  自定义 class: UMTProtocolUtil
2017-09-09 14:43:27.292  自定义 class: UMTBinaryProtocol
2017-09-09 14:43:27.292  自定义 class: UMTBinaryProtocolFactory
2017-09-09 14:43:27.292  自定义 class: MobClickApp
2017-09-09 14:43:27.292  自定义 class: MobClickUtility
2017-09-09 14:43:27.292  自定义 class: UMEventMgr
2017-09-09 14:43:27.293  自定义 class: MobClickSocialAnalytics
2017-09-09 14:43:27.293  自定义 class: MobClickSocialWeibo
2017-09-09 14:43:27.293  自定义 class: MobClick
2017-09-09 14:43:27.293  自定义 class: UMAnalyticsConfig
2017-09-09 14:43:27.294  自定义 class: UMANDeflated
2017-09-09 14:43:27.294  自定义 class: UmengUncaughtExceptionHandler
2017-09-09 14:43:27.330  自定义 class: MobClickEvent
2017-09-09 14:43:27.330  自定义 class: MobClickInternal
2017-09-09 14:43:27.330  自定义 class: UMANUtil
2017-09-09 14:43:27.331  自定义 class: MobClickConfig
2017-09-09 14:43:27.331  自定义 class: MobClickSession
2017-09-09 14:43:27.332  自定义 class: umeng_envelopeConstants
2017-09-09 14:43:27.332  自定义 class: UMEnvelope
2017-09-09 14:43:27.332  自定义 class: MobClickGameAnalytics
2017-09-09 14:43:27.333  自定义 class: MobClickLocation
// 省略
```

这样，排除 Demo 项目里的 `AppDelegate`、`ViewController` 这两个类，我们就能看到友盟 SDK 里的全部类名了。

### Note

1、在 [FLEX](https://github.com/Flipboard/FLEX) 源码中，发现了更简单的实现方式：

```ObjC
- (void)flexShowClassNames {
    unsigned int classNamesCount = 0;
    
    // 用 executablePath 获取当前 app image
    NSString *appImage = [NSBundle mainBundle].executablePath;

    // objc_copyClassNamesForImage 获取到的是 image 下的类，直接排除了系统的类
    const char **classNames = objc_copyClassNamesForImage([appImage UTF8String], &classNamesCount);
    if (classNames) {
        NSMutableArray *classNameStrings = [NSMutableArray array];
        for (unsigned int i = 0; i < classNamesCount; i++) {
            const char *className = classNames[i];
            NSString *classNameString = [NSString stringWithUTF8String:className];
            [classNameStrings addObject:classNameString];
        }
        NSArray *allClassNames = [classNameStrings sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSLog(@"---%@", allClassNames);
        free(classNames);
    }
}
```

2、[objc_getClassList 和 objc_copyClassList 用法区别](http://www.jianshu.com/p/bf6c81fc2434)

-  `objc_getClassList` 需要两次才能获取，较麻烦

```ObjC
    // int objc_getClassList(Class *buffer, int bufferCount) 获取已经注册的类
    // 第一个参数 buffer ：已分配好内存空间的数组，
    // 第二个参数 bufferCount ：数组中可存放元素的个数，返回值是注册的类的总数
    int allClasses = objc_getClassList(NULL,0);
    Class *classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * allClasses);
    allClasses = objc_getClassList(classes, allClasses);
```

- `objc_copyClassList` 代码相对简单：

```ObjC
    // Class *objc_copyClassList(unsigned int *outCount)
    // 该函数的作用是获取所有已注册的类，和上述函数 objc_getClassList 参数传入 NULL 和  0 时效果一样
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
```

## 四、使用 runtime 打印一个类的全部属性、方法

在获取到 SDK 私有类的文件名后，还需要进一步获取类的属性、方法、遵守的协议。

简单的调用几个 `runtime` 的 API 就可以做到 ，代码参见 Demo
，效果如下：

```
ivar[0] ----  B : _observerRegistered
ivar[1] ----  B : _appInBackGround
ivar[2] ----  B : _appBeKilling
ivar[3] ----  B : _appCrashed
ivar[4] ----  i : _sessionStatus
ivar[5] ----  d : _lastLaunchTime
instance method[0] ---- setObserverRegistered:
instance method[1] ---- setAppCrashed:
instance method[2] ---- setAppBeKilling:
instance method[3] ---- setSessionStatus:
instance method[4] ---- setLastLaunchTime:
instance method[5] ---- beginSessionTime
instance method[6] ---- endSessionTime
instance method[7] ---- appActivate:
instance method[8] ---- observerRegistered
instance method[9] ---- appInactivate:
instance method[10] ---- ensureSessionLaunch
instance method[11] ---- appInBackGround
instance method[12] ---- setAppInBackGround:
instance method[13] ---- appBeKilling
instance method[14] ---- appCrashed
instance method[15] ---- sessionStatus
instance method[16] ---- lastLaunchTime
class method[0] ---- profileSignInPUID:
class method[1] ---- profileSignInPUID:withProvider:
class method[2] ---- profileSignOff
class method[3] ---- signInPUID:provider:
class method[4] ---- startWithAppkey:reportPolicy:channelId:
class method[5] ---- startWithAppkey:
class method[6] ---- sharedInstance
```
### Demo

[Demo 戳这里](https://github.com/yehot/RunTime-Practise)

注：runtime 的方案，无法打印出 SDK 里的 Category 类
