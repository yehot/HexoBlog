---
title: 新浪云搭建简单的 Node.js Web 应用
date: 2016-12-18 00:43:45
tags: node.js
categories: Node.js
---

> 阅读本文前，需要对 node.js 、npm、常用 Git 操作、express 有基本的掌握

## 一、准备工作：

###  注册号新浪云账号

进入 http://www.sinacloud.com/sae.html

![](http://ob7o39x9f.bkt.clouddn.com/14819076463405.jpg)

使用微博账号即可直接登录

### 创建云应用空间

> 所谓云应用空间其实就相当于一个 web 站点 + 一个有完整服务器环境的代码仓库

云应用空间的创建可以参考新浪的文档：[如何创建一个云空间应用](http://www.sinacloud.com/home/index/faq_detail/doc_id/83.html)

当然这里需要选择开发语言为 Node.js。


登陆，然后进入控制台 -> 云应用SAE -> 代码管理

![](http://ob7o39x9f.bkt.clouddn.com/14819077010650.jpg)

![](http://ob7o39x9f.bkt.clouddn.com/14819077499116.jpg)

以上步骤完成后，我们就有了一个 web 应用站点，这个站点是用来放我们的 html 页面的。准备工作做好了，接下来该配置 Node.js 服务器环境，部署 web 页面上去。

## 二、Node.js 服务器配置

新浪云比较方便的是，即使你对 Node.js 服务器开发没有深入接触过也没关系，新浪云的 Node.js 环境基本是傻瓜式的，即开即用。所以服务器配置，过。

### node.js 简单教程

安利个 [30分钟 Node.js 入门](http://www.nodebeginner.org/index-zh-cn.html) 的教程，完全没有接触过 Node.js 的同学可以快速入门一下。

## 三、编写 Node.js 服务代码并部署

1、先在本地创建一个代码目录，从新浪的 Git 仓库里 clone 出空项目。拉代码的过程很简单，具体可以参考 [新浪的代码部署手册](http://www.sinacloud.com/doc/sae/tutorial/code-deploy.html) 文档

![](http://ob7o39x9f.bkt.clouddn.com/14819889441764.jpg)

2、在本地代码路径下创建一个 server.js 文件，这里我们先使用入门教程里最简单的 Node.js 代码：

```js
// server.js
var http = require('http');

http.createServer(function (request, response) {

    // 发送 HTTP 头部
    // HTTP 状态值: 200 : OK
    // 内容类型: text/plain
    response.writeHead(200, {'Content-Type': 'text/plain'});

    // 发送响应数据 "Hello World"
    response.end('Hello World\n');
}).listen(8888);

// 终端打印如下信息
console.log('Server running at http://127.0.0.1:8888/');

```

3、由于新浪的 Node.js 构建环境需要从 package.json 文件中读取配置信息，我们需要创建一个package.json 文件。

这里我们直接使用 `npm init` 命令生成一个。 NPM 是 Node Package Manager 的缩写，也就是 Node 包管理器，类似于 iOS 开发中的 CocoaPods，而 `npm init` 就相当于`pod init`了.

在 server.js 文件所在目录上，执行 `npm init`,按照命令行里的提示一步一步直接敲回车即可。

![](http://ob7o39x9f.bkt.clouddn.com/14819079662795.jpg)


4、部署

这里的所谓部署 == 提交代码到新浪云 Git 服务器……

所以，使用 Git 命令打 commit log，push 代码，等待云端编译即可：

```c
// 提交代码
➜  yehot git:(master) ✗ git add .
➜  yehot git:(master) ✗ git commit -m "添加package.json"
[master a6b0d8f] 添加package.json
 1 file changed, 20 insertions(+)
 create mode 100644 package.json

// push 代码后，自动开始构建
➜  yehot git:(master) ✗ git push sae master
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 377 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: 导出 Git 代码中...
remote: 构建程序中...
-----> Node.js app detected

-----> Creating runtime environment

       NPM_CONFIG_LOGLEVEL=error
       NPM_CONFIG_PRODUCTION=true
       NODE_ENV=production
       NODE_MODULES_CACHE=true

-----> Installing binaries
       engines.node (package.json):  unspecified
       engines.npm (package.json):   unspecified (use default)

       Resolving node version (latest stable) via semver.io...
       Downloading and installing node 7.2.1...
       Using default npm version: 3.10.10

-----> Restoring cache
       Loading 2 from cacheDirectories (default):
       - node_modules
       - bower_components (not cached - skipping)
       - nodegyp_lib (not cached - skipping)

-----> Building dependencies
       Pruning any extraneous modules
       Installing node modules (package.json)
       yehot@1.0.0 /tmp/build
       `-- formidable@1.0.17


-----> Caching build
       Clearing previous node cache
       Saving 2 cacheDirectories (default):
       - node_modules
       - bower_components (nothing to cache)
       - nodegyp_lib (nothing to cache)

-----> Build succeeded!
       `-- formidable@1.0.17

-----> Discovering process types
       Default types for  -> web
-----> Compiled slug size is 16M
remote: Generating docker image...
remote: Pushing image registry.docker.sae.sina.com.cn/yehot:c72c679 .....
remote: 部署程序中 .....
To https://git.sinacloud.com/yehot
   a6b0d8f..c72c679  master -> master

```

到这里构建成功，就算部署成功了。这时我们的 Hello world 页面就可以在你的新浪云 Web 站点看到了：

![](http://ob7o39x9f.bkt.clouddn.com/14819134008404.jpg)

站点地址可以从这里查看到：

![](http://ob7o39x9f.bkt.clouddn.com/14819900207625.jpg)


## 四、部署 html 页面

1、懒得自己写个页面了，直接用一个网站模板：[40 个 Bootstrap 网站模板](https://www.oschina.net/news/59924/free-bootstrap-templates) ,随便选一个，把代码压缩包 down 下来

2、解压，将代码网站模板全部文件拷贝到我们的刚创建的本地 Node 仓库目录里。

3、这次我们就不是简单的响应个 hello world 的，需要将 html 文本作为页面 send 出去。这里直接使用 node.js 流行框架 `Express` 帮我们完成这件事。

首先在代码目录路径下执行命令：

```
npm install express --save
```

这样会在 package.json 中，生成一条依赖信息：

![](http://ob7o39x9f.bkt.clouddn.com/14819895856109.jpg)

同时，会将 express 的源码从 npm 仓库中拉下来到本地自动生成的 node_modules 目录中。此时目录结构如下：

![](http://ob7o39x9f.bkt.clouddn.com/14819914963002.jpg)

4、改造 server.js 代码

工具准备好了，开始使用：

```js
// server.js

var express = require('express')
var app = express()

// 静态 html 页面，需要将当前目录下的所有文件都设置为 static
app.use(express.static(__dirname + '/'));

app.get('/', function (req, res) {
    console.log('start server');
    // sendFile 函数，在有 request 访问时，将当前目录下的 index.html 文件作为 response 返回
    res.sendFile(__dirname + '/index.html');
    console.log('start success');
})

// 监听 8000 端口
app.listen(process.env.PORT || 8000)
```

5、Ok，再次 commit log、push ，等待编译

编译完成后，刷新我们的站点，就能看到一个漂亮的 html 页面了：

![](http://ob7o39x9f.bkt.clouddn.com/14819919635022.jpg)

bootstrap 是 Twitter 开源的强大的响应式布局框架，已经帮我们做好了移动端浏览器的适配工作，可以在手机浏览器上访问下试试，效果还是挺不错的。

## 五、作为服务器接口使用

目前我们的 Node 服务，已经成功部署了一个简单的 web 应用。

我们可以在 iOS 端通过 get 请求访问下我们的站点 `http://xxx.applinzi.com` 试试，以 AFNetworkign 为例：

```ObjC
AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];

sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];


sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

[sessionManager GET:@"http://yehot.applinzi.com/index.html" parameters:nil progress:nil

success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

NSLog(@"%@",responseObject);

} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

NSLog(@"%@",error);

}];

```

## 六、其它

###  新浪云控制台使用

1、查看操作记录
![](http://ob7o39x9f.bkt.clouddn.com/14819090622798.jpg)

2、注册会送 200 云豆 == 2元

没有额外流量消耗的话，每天默认扣 10 个豆

![](http://ob7o39x9f.bkt.clouddn.com/14819091585001.jpg)

如果欠费后显示

![](http://ob7o39x9f.bkt.clouddn.com/14819093138228.jpg)

3、查看日志、重启

![](http://ob7o39x9f.bkt.clouddn.com/14819095502076.jpg)


### 最后，新浪是有 node 应用的部署指南的

上边这些坑，整整折腾了我5个小时后，我才发现这个：

[新浪 node 应用部署指南](https://www.sinacloud.com/doc/sae/docker/nodejs-getting-started.html)

不说了，都是泪。当然使用 Python、PHP 也可以查看对应的文档
https://www.sinacloud.com/index/support.html


## 参考：

[在新浪云上用php+mysql搭建简单后台系列](http://www.jianshu.com/p/325288166a59)


