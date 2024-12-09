# subrepo
git new command

## subrepo命令

**添加子仓库**
git subrepo add  <repository-url> <path>

1. 写入配置 .gitsubrepo
2. 写入.gitigorn

**子仓库初始化**
git subrepo  init    <subrepo_name>

1. git clone 

**子仓库删除**
git subrepo del  <subrepo_name>

1. 删除子目录
2. 处理.gitsubrepo
3. 处理.gitigore

## 包装原始git命令

用于常见的几个操作，复杂操作可以直接进入子仓库目录下操作

**子仓库fetch**
git subrepo fetch  -p  <subrepo_name>

**子仓库pull**
git subrepo pull … <subrepo_name>

git subrepo pull …


**子仓库push**
git subrepo push  … <subrepo_name>

git subrepo push  …

git subrepo checkout   … <subrepo_name>

git subrepo checkout   … 


git subrepo merge …  <subrepo_name>

git subrepo merge … 