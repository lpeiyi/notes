# 解决本地仓库与远程仓库不一致问题

**一、将远程仓库代码拉取到本地作为一个新的分支**

将远程仓库main分支（本地分支一样）拉取到本地作为temp分支：

```sql
git fetch origin main:temp
```

**二、检查分支**

```sql
git branch
```

**三、对比本地当前分支和temp的差异**

```sql
git diff temp
```

**四、将temp分支与本地当前分支合并**

```sql
git merge temp
```

如果有不能自动合并的冲突文件，则需要自己打开并修改。

冲突文件的基本格式是<<<<<<<到=======是在当前分支合并之前的文件内容。=======到>>>>>>> 是在其它分支下修改的内容需要。

在这个两个版本中选择一个，然后把标记符号也要一起删除。

手动解决完冲突就可以push到远端分支了。

**五、删除temp分支**

```sql
git branch --delete temp
或
git branch -d temp
```