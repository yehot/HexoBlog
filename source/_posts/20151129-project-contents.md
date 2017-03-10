---
title: iOS工程目录结构的思考
date: 2015-11-29 14:18:43
tags:
---

#一、前言
  在 [@汉斯哈哈哈](http://www.jianshu.com/users/368a8cd349af/latest_articles) 的 [iOS 项目的目录结构能看出你的开发经验](http://www.jianshu.com/p/77a948bcbc38) 这篇博客里提到一点：
> - 面试iOS开发，面试官竟然问他『**怎么分目录结构**』的，而且还具体问到每个子目录的文件名。

> - 清晰的目录结构，可让人一眼知道对应目录的职能，这也能体现开发者的经验和架构能力。

  恰巧，有一次我参加面试，也被问到过类似的问题。
  在日常工作中我自己对此也深有感触，《代码大全》里有个观点：
> **代码首先是给人看的**

  我觉得，一个项目的目录结构也是如此。以下是我个人的一些看法。

  
#二、不合理的目录结构
  我想应该没人觉得一个项目的 「**工程目录结构**」这个东西不重要。
  没人讨论这个可能是因为项目不同、团队风格不一样、目录结构没有个通用的标准，不太好下个结论。
  而且项目**工程目录结构**这个东西，除非开始一个新项目，其它时候大多都是沿用旧项目里已有的目录结构。真正从无到有的完整搭一个新项目，除了软件外包公司，我想机会不是很多。

  我因为非科班出身，刚入行时不是很懂，为了先找到一份工作，同时想着快速接触更多的项目（靠数量增加经验），所以在软件外包公司待过一段时间，接触了不少新开始的项目，也接手了不少旧项目的版本升级、维护等工作。
###这是我接触过的一些项目的结构目录：
![](http://upload-images.jianshu.io/upload_images/332029-9184199c95735d49.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###为什么不合理：
  我觉得普遍**存在以下几个问题**：
**1 、目录结构没有层次性：**
  有的工程，一级目录展开后就是十几个二级目录的文件夹。
![](http://upload-images.jianshu.io/upload_images/332029-a4cca08c1fe89985.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
**2 、目录结构层次过深：**
  文件夹过多、层级过深，会增加点击的成本。
**3、单个目录下文件数过多**
  某级目录内文件数量过多，展开后超过一屏。出现这种情况，我觉得就是目录结构设置不合理导致的。
**4、目录命名不能够「见名知意」：**
  大量的 **Common**、**Tool**、**Helper**、**Other**这样的文件夹名。
**5、没有项目目录结构的ReadMe说明；**
  这个属于代码文档中不容忽视的一点。
**6、目录存在使用中文命名的情况；**
**7、结虚拟文件夹与实体文件夹没有一一对应：**
![](http://upload-images.jianshu.io/upload_images/332029-c642553bee09d282.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###可能导致的问题：

  **1、**一个糟糕的目录会让人对工程瞬间失去兴趣。
  **2、**如果打开一个工程，没办法通过阅读目录结构获得对整个项目结构的大致的了解，这样的目录结构就是不够合理的。这样会导致在不熟悉项目的情况下，很难明白各个模块、各个文件夹里的类的作用。
  **3、**目录结构如果没有统一的规范，类文件的命名也很难有相应的规则来进行约束；
  **4、**对于新加入项目的人，如果需要新增一些类文件，会不知道究竟该放在哪个目录下合适，只能先"凭感觉"随便找个地方一放。这样的工程维护起来，只会越来越乱。


#三、我的个人经验

**1、** 简叔在 [iOS 项目的目录结构能看出你的开发经验](http://www.jianshu.com/p/77a948bcbc38) 一文下的评论：
> ![](http://upload-images.jianshu.io/upload_images/332029-ef0bc5110921e153.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  看到这条评论不胜赞同。
  我自己就很喜欢整理，不论是电脑上的盘符目录，还是印象笔记下的笔记本目录，我都习惯于编个号、定期整理。

![](http://upload-images.jianshu.io/upload_images/332029-296141c755a00794.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  这样一般我要找一个存在自己电脑上的东西，在找之前，头脑里就已经基本想到它会在那个大目录、哪个子目录下。配合搜索功能，很少会找不到文件。
  同时，存的时候也不会随便找个地方一放，乱七八糟。基本已经形成一套自己熟悉的规则了。

**2、** [高质量iOS开发系列之(一)－iOS项目工程及目录结构](http://mtydev.net/?p=1) 中提高的几个基本原则：
> - 一个合理的目录结构应该是清晰的，让人一眼就能了解目录职责，并且是容易扩展的。
> - 不管是第三方库还是自己的库，尽量用CocoPods来管理/区分不同层次的通用组件。
    - General Level, 最通用的组件，可以在不同项目里复用。
    - Project Level, 可以在该项目里复用。
    - Section Level, 可以在某个功能模块里复用。
> - 对于General Level的组件，以Library的形式分出来，不要放在主工程。
> - 对于基础库，保证质量，通用性，可扩展性，易用性，可以不断迭代

  此外，该文章中讲到的各模块注意事项，非常切合iOS开发的实际。建议[阅读原文](http://mtydev.net/?p=1)，我就不在这里搬运了。

**3、**  [@汉斯哈哈哈](http://www.jianshu.com/users/368a8cd349af/latest_articles) 提到的两种常用目录结构的分法：
>1.主目录按照业务分类，内目录按照模块分类
>2.主目录按照模块分类，内目录按照业务分类

  我个人偏向于第二种：按照业务模块划分。因为：
> 1> 第一种如果项目较大，经常会出现找个控制器对应的tableviewcell找半天。如果不是自己写的，更难找。
2> 开发某一具体功能的时候，涉及到的类基本都是该业务模块里面的类，很少会出现跨目录的情况。而第一种情况则需要经常会跨目录。
3> 从文件耦合度来讲，各业务模块里的文件耦合度相对来说比较高。放在一个目录内，也符合软件设计中的高内聚低耦合思想。


**4、一个简单的工程结构目录的Demo**
- 一级目录如下：（中文备注是为了便于理解，实际项目中不要加）
![](http://upload-images.jianshu.io/upload_images/332029-908a1195b32b770e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 二级目录如下：
![](http://upload-images.jianshu.io/upload_images/332029-63f11bd45bc0c94f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**5、公用的类、模块放在哪里：**
  一般的做法是遇到共用模块单独建一个模块叫common，都放到这里。（这样其实也不是很好，Common也是属于定义模糊的命名）
**6、多个Target的情况：**
  可以单独出一个Project文件夹，按Target名分各个子目录，内放各个Target中独有的文件。
**7、图片资源**最好都用 **Images.xcassets** 去管理。
  **Images.xcassets** 文件里边也按业务模块分子文件夹，这样可以方便的预览图片。


#四、Tips
  **在定位项目中的文件**时，善用以下快捷键可以节省大量时间：

**1、Xcode左下角的搜索框 （不支持模糊搜索、会展开对应目录）**

![](http://upload-images.jianshu.io/upload_images/332029-c747563290d2b596.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 快捷键: Command + option + j

![](http://upload-images.jianshu.io/upload_images/332029-7705e2a055900eb8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**2、工程全局搜索**（支持模糊搜索、不会展开对应目录）
> 快捷键: Command + shift + O
![](http://upload-images.jianshu.io/upload_images/332029-56a1f25146ea0cba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###注：
  以上只是我个人的一些经验，总结的不是很完善。同时有很多地方借鉴了以下文章的观点。有什么能改进的地方，欢迎在评论区讨论！

</br>

>###参考：
>[高质量iOS开发系列之(一)－iOS项目工程及目录结构](http://mtydev.net/?p=1)
>[iOS项目的目录结构和开发流程](http://limboy.me/ios/2013/09/23/build-ios-application.html)
>[iOS 项目的目录结构能看出你的开发经验](http://www.jianshu.com/p/77a948bcbc38)
