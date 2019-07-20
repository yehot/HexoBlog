---
title: 让 UIView 像 UINavigationController 一样支持 push 和 pop
tags: UIView 转场、UIView push pop、CATransition
toc: true
date: 2019-07-20 14:35:18
description:
---
<meta name="referrer" content="no-referrer" />
<!-- toc -->


`VLog` 这个 App 里，有一个 `UIView` 之间的转场动效做的挺不错，是参照 iOS 系统 `UINavigationController` 的 `push` 和 `pop` 动画，对两个 `UIView` 之间的切换实现了和 系统的 `push、pop` 类似的动效，如下：

![](https://upload-images.jianshu.io/upload_images/332029-5e282cfd2499539f.gif?imageMogr2/auto-orient/strip)


iOS 里实现一个这样的动效还是比较容易的，只需要用 `CAAnimation` 的子类 `CATransition` 即可。

[具体实现见 Demo](https://github.com/yehot/YHPageView)

## 简单版本

原理很简单：封装一个 `PageView` ，初始化时传入一个 `fromView`，然后提供一个接口可以 动画的 `push` 到 `toView` ，以及动画的移除 `toView` 的 `pop` 方法，以下是个简单的实现的接口：

```ObjC
// 具体实现见 Demo 链接
#import <UIKit/UIKit.h>

@interface PageView : UIView

@property (nonatomic, assign, readonly, getter=isInPushing) BOOL inPushing;

// PageA 必须和 self frame 一致
- (void)setupPageA:(UIView *)view1;
// PageB 必须和 self frame 一致
- (void)pushToPageB:(UIView *)view2;
- (void)pop;

@end
```


用法示例：

```ObjC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.pageView];
    [self.pageView setupPageA:self.view1];
}

- (void)demo1Action {
    if (self.pageView.isInPushing) {
        [self.pageView pop];
    } else {
        [self.pageView pushToPageB:self.view2];
    }
}
```

## 进阶版本

当然，这样的实现和系统的 `UINavigationController` 比，还是难用了太多，可以借助 OC 的 `Category` 机制，对 `UIView` 做个 `page able` 的扩展，这样，任何 `UIView` 就都能够 push 和 pop 了，这里是进阶版的简单实现：

```ObjC
// UIView (Pageable).h
#import <UIKit/UIKit.h>

@interface UIView (Pageable)
@property (nonatomic, assign, readonly) BOOL yh_inPushing;
- (void)yh_pushView:(UIView *)toView;
- (void)yh_pop;
@end


// UIView (Pageable).m
#import "UIView+Pageable.h"
#import <objc/runtime.h>

static NSString* const kPageAnimateKey = @"YHPageable";

@interface UIView ()
@property (nonatomic, weak) UIView *yh_toView;
@property (nonatomic, assign, readwrite) BOOL yh_inPushing;
@end

@implementation UIView (Pageable)

- (void)yh_pushView:(UIView *)toView {
    NSAssert(CGSizeEqualToSize(toView.frame.size, self.frame.size), @"toView.frame.size != self.frame.size");
    
    // 不支持连续 push 同一个 view
    if ([self.subviews containsObject:self.yh_toView]) {
        return;
    }
    
    self.yh_toView = toView;
    [self yh_switchAnimation];
    self.yh_inPushing = YES;
}


- (void)yh_pop {
    // 无 toView 可 pop
    if (![self.subviews containsObject:self.yh_toView]) {
        return;
    }
    [self yh_switchAnimation];
    self.yh_inPushing = NO;
}

#pragma mark - private

- (void)yh_switchAnimation {
    if (self.yh_inPushing) {    // pop
        [self yh_addTransitionWithType:kCATransitionMoveIn
                               subtype:kCATransitionFromLeft
                              duration:0.25];
        [self.yh_toView removeFromSuperview];
    } else {    // push
        [self yh_addTransitionWithType:kCATransitionMoveIn
                               subtype:kCATransitionFromRight
                              duration:0.5];
        [self addSubview:self.yh_toView];
    }
}

- (void)yh_addTransitionWithType:(CATransitionType)type
                         subtype:(CATransitionSubtype)subtype
                        duration:(CFTimeInterval)duration {
    [self.layer removeAnimationForKey:kPageAnimateKey];
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.type = type;
    transition.subtype = subtype;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:transition forKey:kPageAnimateKey];
}

#pragma mark - associate

- (UIView *)yh_toView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYh_toView:(UIView *)view {
    objc_setAssociatedObject(self, @selector(yh_toView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)yh_inPushing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setYh_inPushing:(BOOL)inPushing {
    objc_setAssociatedObject(self, @selector(yh_inPushing), @(inPushing), OBJC_ASSOCIATION_RETAIN);
}
@end

```

用法示例：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.view1];
}

- (void)demoAction {
    if (self.view1.yh_inPushing) {
        [self.view1 yh_pop];
    } else {
        [self.view1 yh_pushView:self.view2];
    }
}
```

效果如下：

![](https://upload-images.jianshu.io/upload_images/332029-1068815cd5cb21f1.gif?imageMogr2/auto-orient/strip)


## 动画实现原理

- 通过给 view.layer 加自定义的 `CAAnimation`，以替换掉 `[view addSubview:]` 和 `[view removeFromSuperview]` 时的默认动画。
- 按照这个思路，只需要修改这里的 `CATransitionType` 即可实现各种转场动画；
- 更多的 `CATransitionType` 效果示例，可以参见 @青玉伏案 的 [iOS开发之各种动画各种页面切面效果](https://www.cnblogs.com/ludashi/p/4160208.html)


## 参照 UINavigationController 的版本

以上两种实现，其实都没有真正做到像 `UINavigationController` 一样，能随意的 push 和 pop。如果要完全实现一套能像 `UINavigationController` 一样使用的 `UIView`，用法上的限制会增大很多：

首先，假定我们最终的可导航的 UIView 的类为 `UIViewNavigationController`

1、 `UIViewController` 持有一个 `UINavigationController` 类型的属性；
所以，我们就不能直接使用 `UIView`, 而需要封装一个 `UINavigationView`, 持有一个 `UIViewNavigationController` 属性，便于 `UIView` 调用 `[self.navigationView popView]`

2、 `UINavigationController` 是继承自 `UIViewController` 的。
所以，`UINavigationController` 需要继承自 `UIView`, 至少有 `initWithRootView:`, `pushView:(UINavigationView *)view`, `popView` 等接口，内部还需要维护一个 stack，管理一层一层 push 入的 views

3、由于很少有这么复杂的使用场景，这里仅提供简单的 API 接口，需要的可以自行实现

```ObjC
#import <UIKit/UIKit.h>

@class UIViewNavigationController;
@interface UINavigationView : UIView
@property (nonatomic, strong, readonly) UIViewNavigationController *viewNavigation;
@end


@interface UIViewNavigationController : UIView

@property(nonatomic,readonly,strong) UINavigationView *topView; // The top view on the stack.
@property(nonatomic,readonly,strong) UINavigationView *visibleView;
@property(nonatomic,copy) NSArray<__kindof UINavigationView *> *subNavigationViews; // The current navview stack.

- (instancetype)initWithRootView:(UINavigationView *)rootView;
- (void)pushView:(UINavigationView *)view animated:(BOOL)animated;
- (UINavigationView *)popView:(BOOL)animated;
- (NSArray<__kindof UINavigationView *> *)popToView:(UINavigationView *)view animated:(BOOL)animated;
- (NSArray<__kindof UINavigationView *> *)popToRootView:(BOOL)animated;
@end

```


> keyword：

UIView 转场、UIView转场动画、UIView push pop、UIView CATransition

