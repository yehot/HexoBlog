---
title: Python新浪博客爬虫：sina-blog-spider
date: 2017-03-27 20:38:08
tags: spider
categories: Python
---

> 大学的时候用新浪写了4年的流水账 blog，某天突然翻到，感慨还是留了不少记忆在里边的，就想着要不迁移或者备份下。搜了一圈发现了 [bfishadow/SBB](https://github.com/bfishadow/SBB) 这个 Python 写的备份工具，试用了下还不错。刚好借着这个机会学习一下 Python 和爬虫。

在学习代码的过程中，自己也敲了一遍，发现了一些问题：不支持 Python3.x，代码可读性太差。代码敲完了发现，作者原来不是程序员啊我摔！被坑了（代码实在太烂了，差点摧毁我对 Python 的认知）。

所以特意花了一下午时间对代码进行了一个重写：

### 新特性：

- 适配 Python3.x；
- 进行了封装、重构，提高代码可读性；
- 添加了踩坑注释；
- 吐槽归吐槽，原 po 思路还是非常赞的，鸣谢 @bfishadow；

### 功能简介

- 用于下载并归档指定新浪博客作者全部文章的 Python 脚本；
- 抓取后整理生成本地 html 文件，以及一个 indxe 入口；
- 支持到 Python3.x
- 源码戳 [sina-blog-spider](https://github.com/yehot/sina-blog-spider)

### Usage:

```python
# 排序开关是可选的，默认为按发表时间顺序排列（即 asc）
$ sina_blog_crawler.py http://blog.sina.com.cn/gongmin desc
$ sina_blog_crawler.py http://blog.sina.com.cn/u/1239657051
```

### TODO:
* [ ] 添加可选参数：指定抓取页数支持
* [ ] 网络库从 urllib 替换为 requests
* [ ] 字符串匹配改用正则
* [ ] 不够 Pythonic，优化编码规范

### DEMO:

> 万万没想到韩寒 17 年还有两篇博客，试爬了一下韩寒的 10 篇 blog，效果如图：

![sina-demo](https://upload-images.jianshu.io/upload_images/332029-bd965150a0c3fdf3.gif)
