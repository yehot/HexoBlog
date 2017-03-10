---
title: Git常用命令清单
date: 2017-02-15 22:33:01
tags: git
---

![目录](http://upload-images.jianshu.io/upload_images/332029-53b2e99ec9b33e76.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


之前一直借助于 Source-tree 这种图形化 Git 工具，一次在帮同事解决 Git 分支合并问题时，用的同事电脑，没有 Source-tree ，感觉完全不会用了，什么命令也没记住。恶补一下命令，重新学一遍 Git 教程，发现好多常用的操作，用命令还是非常方便的。
这里整理汇总下：

## 一、Git alias

在开始常用命令前，先推荐下使用 alias 定义 git 常用命令的别名，合理使用简写可以大幅提高效率。

常用 git 命令，可以在 `~/.gitconfig` 文件中使用 alias 定义简写，以下是我个人常用 alias:

```js
[alias]
    st = status -s
    ci = commit
    l  = log --oneline --decorate -12 --color
    ll = log --oneline --decorate --color
    lc = log --graph --color
    co = checkout
    br = branch
    ba = branch -a
    rb = rebase
    dci = dcommit
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
```

> 另，`~/.gitconfig` 文件中，可以查看当前 user 的 git 配置信息

## 二、branch 分支操作

### 查看分支信息

```js

# 列出所有本地分支
// git br
$ git branch

# 列出所有本地分支和远程分支
// git ba
$ git branch -a
```

### 新建分支

```js
# 从当前分支新建一个分支。但依然停留在当前分支
// git br [本地xxx]
$ git branch [branch-name]
// 常用于：对当前 分支做个备份

# 从指定的远程分支，拉一个本地分支。并切换到该分支
// 常用于： 从远端 develop 拉一个 本地 feature/xxx 分支
$ git checkout -b newBrach origin/master

# 新建一个分支，指向指定commit。但依然停留在当前分支
$ git branch [branch] [commit]

# 新建一个分支。并切换到该分支
// git co -b [local or remote/branch-name]
$ git checkout -b [branch-name]

# 新建一个分支，指向某个tag
$ git checkout -b [branch] [tag]
```

### 切换分支

```js
# 切换到指定分支，并更新工作区
// git co [branch-name]
$ git checkout [branch-name]

# 切换到上一个分支
$ git checkout -
```

### 删除分支

```js
# 删除本地分支
// git br -d [branch-name]]
$ git branch -d [branch-name]
$ git branch -D //强制删除

# 删除远程分支
// git br -dr [remote/branch]
// eg:  git br -dr origin/xxx_name
$ git branch -dr [remote/branch]
```

### 合并分支

```js
# 合并指定分支到当前分支
$ git merge [branch]

# 选择一个commit，合并进当前分支
$ git cherry-pick [commit]
```


## 三、tag 分支操作

在 Git 中 tag 可以看做是指向某个 commit 的特殊分支

### 列显已有 tag

```js
$ git tag
```

### 添加 tag

```js
$ git tag v1.4.0

// 添加一个带 commit log 的 tag
$ git tag -a v1.4 -m 'my version 1.4'

// 为某个指定的 commit 打上 tag
$ git tag -a v1.2 9fceb02

// 查看 tag 信息
$ git show v1.4
```

### 推送 tag

```js
// git push 不会将本地的 tag push 到 origin

# push 指定 tag name
$ git push origin v1.0
# push 全部 tag
$ git push origin --tags
```

### 删除 tag

```js
// 删除本地 tag
$ git tag -d v0.9

// 删除远端 tag
$ git push origin :refs/tags/0.1.0
## 明确的表示删除
$ git push --delete origin v1.1
```

## 四、git pull

git pull命令的作用是，取回远程主机某个分支的更新，再与本地的指定分支合并。

### Merge 型 的 pull

> 如果本地分支，在 checkout 后，有 commit， git pull 就会增加一个 Merge log
> 如果本地分支没有 新 commit，等于直接 fetch、pull

![](http://upload-images.jianshu.io/upload_images/332029-6510e80758bdf307.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```git

// 将远端的 A 分支的代码，拉到本地 B 分支 (会产生一个 Merge log)
$ git pull origin [remote_name]:[local_name]
// 如果是往当前 本地分支 pull，则冒号后面的部分可以省略
$ git pull origin [remote_name]


// 实质上，这等同于先做git fetch，再做git merge。
$ git fetch origin
$ git merge origin/next

# Git会自动在本地分支与远程分支之间，建立一种追踪关系（tracking）。 就是说，本地的master分支自动"追踪"origin/master分支。

// 如果当前分支与远程分支存在追踪关系，git pull就可以省略远程分支名。
$ git pull origin

// 如果当前分支只有一个追踪分支，连远程主机名都可以省略。
$ git pull
// 上面命令表示，当前分支自动与唯一一个追踪分支进行合并

```

### rebase 型 pull

```js

// 如果合并需要采用rebase模式，可以使用--rebase选项。
$ git pull --rebase <远程主机名> <远程分支名>:<本地分支名>
// git pull --rebase origin [origin_name]:[local_name]

// 如果是 rebase 到当前分支，可省略 ： 后
$ git pull --rebase origin [origin_name]
// 如果 rebase 的远端分支，是当前分支 track 的，[origin_name] 可省略
$ git pull --rebase origin

```


## 五、Git push


```js
// 将当前 loca_name 分支 push 到远端，命名为 new_name
$ git push <远程主机名> <本地分支名>:<远程分支名>
// git push origin loca_name:new_name

# 如果当前分支与远程分支之间存在追踪关系，则本地分支和远程分支都可以省略。
# 如果当前分支只有一个追踪分支，那么主机名都可以省略。
// 会将本地所有分支都 对应 push （慎用）
$ git push

// push 可以用来删除
$ git push origin --delete master

# 如果远程主机的版本比本地版本更新，推送时Git会报错，要求先在本地做git pull合并差异，然后再推送到远程主机。这时，如果你一定要推送，可以使用--force选项。
$ git push --force origin

# 最后，git push不会推送标签（tag），除非使用--tags选项。
$ git push origin --tags

```


## 六、代码回滚

### 快速合并缓存区到上一个 commit

```js
// 将 add 到缓存区的内容，和上一个 commit 一起， rebase 成了一个新的 commit
$ git commit --amend

// 便于将漏修改的，或是修改错误的内容，合并到上一个 commit 中。而不用提交两个 commit，然后 rebase 成一个
// 注：如果修改过了， 只能 push -f 到远端
```

### checkout 到指定 commit

这对于快速查看项目旧版本来说非常有用

```js
$ git checkout [commit id]

// check 到往前指定此的 commit
$ git checkout HEAD~2
```

### git Revert

Revert撤销一个提交的同时会创建一个新的提交。

```js
# 新建一个commit，用来撤销指定commit
# 后者的所有变化都将被前者抵消，并且应用到当前分支
$ git revert [commit]
```

### git reset

- 将已经加到缓存区的内容（仅打了本地 commit），移除到工作区

```
$ git reset HEAD

$ git reset HEAD~2
```

- 从缓存区重置，不删除修改的地方

```js
// 将缓存区中的指定文件，移到工作区
// 缓存区中的，指的是 add 后的
git reset <file>

// 将缓存区中的全部文件，移到工作区
$ git reset

// 将本地 commit 历史中的 commit 移除到 工作区 （未 add 状态）
$ git reset [commit_id]
```

### 删除式 reset

```js
// 缓存区和工作区的，都会被完全移除（删除）
$ git reset --hard

// 将本地 commit 历史中的直接删除
$ git reset --hard <commit>

# 重置当前HEAD为指定commit，但保持暂存区和工作区不变
$ git reset --keep [commit]
```

参考：
[常用 Git 命令清单 - 阮一峰](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
[Git远程操作详解 - 阮一峰](http://www.ruanyifeng.com/blog/2014/06/git_remote.html)
[Git 配置别名 - 廖雪峰](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/001375234012342f90be1fc4d81446c967bbdc19e7c03d3000)
[果壳中的 Git](https://github.com/geeeeeeeeek/git-recipes/wiki)

特别推荐：
[ jaywcjlove —— Git常用命令清单](https://github.com/jaywcjlove/handbook/blob/master/other/Git%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%E6%B8%85%E5%8D%95.md)
