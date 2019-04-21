---
title: iOS查看屏幕帧数工具--YYFPSLabel
date: 2016-04-05 23:23:36
tags: iOS
categories: Tool
---
学习 **[YYKit](https://github.com/ibireme/YYKit)** 代码时，发现 [ibireme](https://github.com/ibireme) 在项目里加入的一个查看当前屏幕帧数的小工具，效果如下：

![](http://upload-images.jianshu.io/upload_images/332029-36fb1bdbfb423531.gif?imageMogr2/auto-orient/strip)

挺实用，实现方法也很简单，但是思路特别棒。

> Demo： **[YYFPSLabel](https://github.com/yehot/YYFPSLabel)**

这里是我在学习 `YYKit` 大牛代码的过程中的收货，顺便**做个笔记**：

### 一、FPSLabel 实现思路：

- `CADisplayLink` 默认每秒 60次；
- 将 `CADisplayLink`  add 到 `mainRunLoop` 中；
- 使用 `CADisplayLink` 的 `timestamp` 属性，在 `CADisplayLink` 每次 tick 时，记录上一次的 `timestamp`；
- 用 _count 记录 `CADisplayLink` tick 的执行次数;
- 计算此次 tick 时， `CADisplayLink` 的当前 timestamp 和 _lastTimeStamp 的差值；
- 如果差值大于1，fps = _count / delta，计算得出 FPS 数；

详见 [代码](https://github.com/yehot/YYFPSLabel/blob/master/YYFPSLabel/YYFPSLabel/YYFPSLabel.m)。

### 二、NSTimer、CADisplayLink 常见问题：

#### 2.1 问题一： UIScrollView 在滑动时，timer 会被暂停的问题。

- 原因：`runloop mode` 导致。iOS处理滑动时，`mainloop` 中UIScrollView 的 mode 是 `UITrackingRunLoopMode`，会优先保证界面流畅，而 timer 默认的 model是 `NSDefaultRunLoopMode`，所以会出现被暂停。
- 解决办法：将 timer 加到 `NSRunLoopCommonModes` 中。

```ObjC
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
```

详见：[深入理解RunLoop](http://blog.ibireme.com/2015/05/18/runloop/) 一文中关于 [定时器](http://blog.ibireme.com/2015/05/18/runloop/#timer)  和 [RunLoop 的 Mode](http://blog.ibireme.com/2015/05/18/runloop/#mode) 的部分

#### 2.2 问题二：NSTimer 对于 target 的循环引用问题：

以下代码很常见：

```ObjC
    CADisplayLink *_link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];

    [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
```

- 原因：以上两种用法，都会对 self 强引用，此时 timer持有 self，self 也持有 timer，循环引用导致页面 dismiss 时，双方都无法释放，造成循环引用。此时使用 __weak 也不能有效解决:

```ObjC
    __weak typeof(self) weakSelf = self;
    _link = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(tick:)];
```

效果如下：

![](http://upload-images.jianshu.io/upload_images/332029-6b2957fc2ff9cc8b.gif?imageMogr2/auto-orient/strip)

**可以看到 页面 dismiss 后，计时器仍然在打印**

#### 2.3 解决办法1：`在页面退出前，或者合适的时候，手动停止 timer，结束循环引用。`

注意：在 dealloc 方法中是肯定不行的！由于循环引用，dealloc 方法不会进。

![](http://upload-images.jianshu.io/upload_images/332029-90b68a2f2381e4f0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2.4 解决办法：2：`YYFPSLabel` 作者提供的 [YYWeakProxy](https://github.com/yehot/YYFPSLabel/blob/master/YYFPSLabel/YYFPSLabel/YYWeakProxy.m)

```ObjC
@interface YYWeakProxy : NSProxy
@end

// 使用方式：
    _link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(tick:)];

```
代码很少，有兴趣可以自己看下源码。

**Tips：** OC 中 `NSProxy` 是不继承自 `NSObject` 的。

### 三、探索环节：iOS中子线程检测主线程

> 在和小伙伴分享这个小工具的时候，潘神抛出了这样一个**问题**：这里组件是在主线程绘制的label，如果主线程阻塞了还能用吗？结果是不能。

 以下是探索：

#### 3.1、模拟主线程阻塞，将 link 放在子线程，发现 timer 不能启动

```ObjC
    // 模拟 主线程阻塞 （不应该模拟主线程卡死，模拟卡顿即可）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{  
        NSLog(@"即将阻塞");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"同步阻塞主线程");
        });
        NSLog(@"不会执行");
    });
```

#### 3.2、使用 `CFRunLoopAddObserver` 检测主线程是否卡顿：

```ObjC
//将观察者添加到主线程runloop的common模式下的观察中 
CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
```

这里是能检测到主线程是否卡顿了，但是 timer 在子线程中还是跑不起来。

参考 [Starming星光社](https://www.google.com.hk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0ahUKEwjx0Zjw4_fLAhWVj44KHdkUAvwQFggbMAA&url=%68%74%74%70%3a%2f%2f%77%77%77%2e%73%74%61%72%6d%69%6e%67%2e%63%6f%6d%2f&usg=AFQjCNF2xjShwXV0aXfKo1yXQHN95DRCAA&sig2=C_ywHG5vt8byOOqA6x-bOw) 的 [检测iOS的APP性能的一些方法](http://www.starming.com/index.php?v=index&view=91)

#### 3.3、在子线程手动创建一个 `runloop`，提供给 timer。

```ObjC
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        // NOTE: 子线程的runloop默认不创建； 在子线程获取 currentRunLoop 对象的时候，就会自动创建RunLoop
        // 这里不加到 main loop，必须创建一个 runloop
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [_link addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        // 必须 timer addToRunLoop 后，再run
        [runloop run];
    });
```

这样，就可以在子线程中使用 timer 了，但是此时只能 log，无法获通知主线程更新UI： (这里先不在主线程更新UI了)

```ObjC
// 尝试1：主线程阻塞， 这里就不能获取到主线程了
//    dispatch_async(dispatch_get_main_queue(), ^{
//        阻塞时，想通过 在主线程更新UI 来查看是不可行了
//        label_.text = text;
//    });
    
    // 尝试2：不在主线程操作 UI ，界面会发生变化
    label_.text = text;
```

参考: [【iOS程序启动与运转】- RunLoop个人小结](http://www.jianshu.com/p/37ab0397fec7)


以上是学习 YYFPSLabel 时的收获，和对于在子线程中检测主线程的探索。详情可以戳代码：**[YYFPSLabel](https://github.com/yehot/YYFPSLabel)**

### 四、补充：

`@beychen` 同学提问：`为什么__weak typeof(self) weakSelf = self; 不能解决 displayLinkWithTarget 循环引用的问题？` 

`之前给的解释是：`

普通的 VC 持有 block，在 block 外 weakSelf 后再传入，block 中持有的是 weakSelf 就能正常释放了。但是 NSTimer 的 target 传 weakSelf 却不行。由于 NSTimer 是闭源的，猜测原因可能如下：

1、 NSTimer 在子线程执行，需要线程保活，会被加入到 RunLoop 中，被 Runloop 强引用；
2、 Block 和 Timer ，对于 self 的持有方式不同， block 是捕获了变量，进行了值拷贝。但是 NSTimer 需要一直调用 target 的 selector，如果 target 先于 NSTimer 释放了，NSTimer 会调不到 selector，会崩溃。所以猜测  NSTimer 的 tagrget 中，对 weakSelf 又进行了类似 StrongSelf 操作，eg:

```Objective-C
    __weak typeof(self) weakSelf = self;
    self.myBlock = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 永远不会主动停止的动作
    };
```

3、 由于上述 1，NSTimer 本身不会被释放（相当于一个单例），传入 NSTimer 的 taget，被 Timer 加到集合中的话，即使传 weakSelf 也不能释放。这个也是之前 debug 一个内存泄露时发现的类似现象。

可以参考下：

- [http://blog.callmewhy.com/2015/07/06/weak-timer-in-ios/](http://blog.callmewhy.com/2015/07/06/weak-timer-in-ios/)
- [http://www.cocoachina.com/ios/20160204/15226.html](http://www.cocoachina.com/ios/20160204/15226.html)
