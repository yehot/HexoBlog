# 手动发布更新到 github 仓库
# 而非使用 hexo d 发布 (后者不能添加 git log)

hexo generate

echo "请输入 git log 信息: "

read GitLogMessage

echo "输入的 log 信息为： ${GitLogMessage}"

cp -R public/* ./yehot.github.io
cd ./yehot.github.io
git add .
git commit -m "${GitLogMessage}"
git push origin master

echo "===== blog 发布成功 ====="
