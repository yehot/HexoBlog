---
title: 为什么iOS项目应该用CocoaPods
date: 2015-11-28 16:02:56
tags: CocoaPods
categories: iOS组件化
---
<meta name="referrer" content="no-referrer" />

**为什么iOS项目中应该使用CocoaPods作为第三方依赖管理工具？**

![](http://upload-images.jianshu.io/upload_images/332029-76f5038a773b7863.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>**目录：**
     > - 从一个bug说起
     > - 分析需求及解决方案
     > - 确定方案
     > - CocoaPods学习资料


#一、从一个bug说起：
1、公司的项目里统一使用SVG格式的图片；
2、GitHub上只有一个star数超过一千的SVG解析库，叫SVGKit。（对，就是这个坑爹的库）
         **坑1：** 这个库一直使用非ARC，有100多个类；</a>
         **坑2：** 这个库还依赖另外一个库CocoaLumberjack；
         **坑3：** 把这个库配置到项目中就会报一种错误：
![](http://upload-images.jianshu.io/upload_images/332029-41102bc3ee4544b1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3、公司的项目是直接以源码的形式使用的该库。
        结果就是 **Build Phase** 中成了这样：
   （我不知道当初加这些 -fno-objc-arc 标记的人是否崩溃，我光看着就觉得淡淡的忧桑：这么多得加多久？加漏了或者多加了，都是坑。）
![](http://upload-images.jianshu.io/upload_images/332029-e085b55b305df854.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


4、因为用的源码，项目里的SVGKit版本很久都不会更新。导致在iPhone6S以上设备时，由于旧版本的库没有适配6S，必崩。现在必须要更新到这个库的最新版本。

#**二、解决方案的探索：**
##方案一：
>**用最新源码替换掉旧版源码文件**
  问题：1、类文件太多，麻烦，容易出错；
     2、还是会有大量的 -fno-objc-arc 标记，很烦；
       结论：**否决**

##方案二：
>**SVGKit作者推荐——静态库**（该库的GitHub页面也只介绍了这一种用法）
  问题：1、只有.h 头文件，出错没法定位和修改。
     2、静态库里使用了category必须要加 -ObjC 标记。
     3、静态库.a文件需要区分device版本和simulator版本，或者合并后使用。
  结论：**否决**


关于**问题2**这里要解释下，本来是没什么问题的，但我不幸遇到了**这个坑**：
  1、静态库里如果使用了 **category**，需要加 **-ObjC** 标记。否则在使用的时会崩溃：
![](http://upload-images.jianshu.io/upload_images/332029-83821f8d987a4e16.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  2、当时花了好久没解决这个问题的原因是，我记得自己设置了呀。
     后来才想起来为毛还是崩，这是我们的项目target，你们感受下：

![](http://upload-images.jianshu.io/upload_images/332029-a4084793b6c2f4ef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    有任何一个target忘了设置，就又埋了个坑。
  3、关于 **为什么要加 -ObjC 标记** 的问题，以前是有查过资料的，这里完全是因为target太多遗漏导致的。
>####笔记如下：  
**-ObjC 标记的作用:**
     > - 用到一个第三方库，这个库的使用向导里面特别说明，在添加完该库后，需要在Xcode的Build Settings下Other Linker Flags里面加入-ObjC标志。之所以使用该标志，和Objective-C的一个重要特性：类别（category)有关。根据[这里](https://developer.apple.com/library/mac/qa/qa1490/_index.html)的解释，Unix的标准静态库实现和Objective-C的动态特性之间有一些冲突：Objective-C没有为每个函数（或者方法）定义链接符号，它只为每个类创建链接符号。
> - 这样当在一个静态库中使用类别来扩展已有类的时候，链接器不知道如何把类原有的方法和类别中的方法整合起来，就会导致你调用类别中的方法时，出现"selector not recognized"，也就是找不到方法定义的错误。
> - 为了解决这个问题，引入了-ObjC标志，它的作用就是将静态库中所有的和对象相关的文件都加载进来。
> - 本来这样就可以解决问题了，不过在64位的Mac系统或者iOS系统下，链接器有一个bug，会导致只包含有类别的静态库无法使用-ObjC标志来加载文件。变通方法是使用-all_load 或者-force_load标志，它们的作用都是加载静态库中所有文件，不过all_load作用于所有的库，而-force_load后面必须要指定具体的文件。

##方案三：
>**使用 CocoaPods **
问题：作者没有说明这个库**是否支持CocoaPods**
   这也是我最开始没有考虑改用 CocoaPods 的原因）

- 这里提示大家，可以使用以下命令，测试某个库是否支持CocoaPods
```$ pod try XXX```

     鉴于这里不是介绍如何使用 CocoaPods，这里只讨论下使用 CocoaPods 的好处，以及一些使用经验（我会在后文列一些 CocoaPods 的资料）。

>优点：
1、解决了方案一中，需要在项目里 **大量标记 -fno-objc-arc **的问题：
—— CocoaPods自动生成的关联库会在关联工程中自动标记好，原始项目中只管用就行
2、解决了方案二中，只有.h 头文件，**没有源码**、出错没法定位和修改的问题：
—— CocoaPods也是使用静态库依赖，但是保留全部.m文件
3、解决了方案二中，静态库使用时的一些坑，和**需要打包.a文件的麻烦操作**。
—— CocoaPods自动完成
4、极大的简化了**操作**：
  1> cd进入.xcodeproj文件所在的目录
  ```$ pod init```
  2> 在自动生成的Podfile文件中，加入要pod的库名
  ```$ pod install```
  3> 搞定。
     5、最重要的一点：以后再遇到这次的升级第三方库版本的需求时，只需一行命令即可：
  ```$ pod update```
结论：**就是这个了！**

#确定方案
> CocoaPods 一劳永逸的解决了第三方库版本升级的问题。

#就酱~

#干货部分
>CocoaPods学习资料

####CocoaPods入门：
1、[CocoaPods安装和使用教程](http://code4app.com/article/cocoapods-install-usage)
（入门看这一篇就够了）
2、CocoaPods pod install/pod update**更新慢的问题**
  最近使用CocoaPods来添加第三方类库，无论是执行pod install还是pod update都卡在了Analyzing dependencies不动
  原因在于当执行以上两个命令的时候会升级CocoaPods的spec仓库，加一个参数可以省略这一步，然后速度就会提升不少。命令如下：
```
pod install --verbose --no-repo-update
pod update --verbose --no-repo-update
```
3、mac升级到10.11，**cocoapods没了**
  使用命令行sudo gem install cocoa pods出错，换成sudo gem install -n /usr/local/bin cocoa pods即可，详见： http://t.cn/Ry8tZAs
4、**使用经验：**
  1> pods install 时，可以不加版本号（默认下载对应库的**最新版本**）
![](http://upload-images.jianshu.io/upload_images/332029-9293ed3a288b838e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  但是，下载完依赖后，最好**加上版本号**，避免在添加了新的库，或者pod update时，由于某些第三方库频繁升级而带来的不稳定。
![](http://upload-images.jianshu.io/upload_images/332029-22cd97e2d756cb04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  2> 多人合作的较大项目，Podfile文件可以设置权限，只由一个人来修改、添加依赖的库。
  3 > SVN或者Git做版本管理时，不要上传 Pods 、workspace 目录：
（可以设置ignore）
![](http://upload-images.jianshu.io/upload_images/332029-4e55d2d3a6b9d29f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###CocoaPods高阶用法：

1、[即使你不使用第三方库，CocoaPods仍然是一个管理代码相关性的绝佳工具](
     http://nshipster.cn/cocoapods/#%E4%BD%BF%E7%94%A8cocoapods)
2、[借助GitHub托管Category,利用CocoaPods集成到项目中](
     https://github.com/Damonvvong/DWCategory)
3、[Cocoapods创建私有podspec](http://blog.wtlucky.com/blog/2015/02/26/create-private-podspec/)
4、[写一个Pod发布到CocoaPods](http://blog.csdn.net/becomedragonlong/article/details/45933345#0-tsina-1-22915-397232)
5、[CocoaPods的一些略为高级一丁点的使用](http://supermao.cn/cocoapodsde-xie-lue-wei-gao-ji-ding-dian-de-shi-yong/)

```
//TODO:1、利用多个 project 做本地依赖管理
       2、私有仓库的使用尝试
```
