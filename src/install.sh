#!/bin/bash


# 权限检查
# 检查 /etc/gitconfig 的写入权限
if touch /etc/.test_gitconfig 2>/dev/null; then
    rm -f /etc/.test_gitconfig
else
    echo "没有写入/etc 的权限,请使用sudo ./install_subrepo.sh运行"
    exit 1
fi

# 检查 /usr/local/bin 的写入权限
if touch /usr/local/bin/.test_usrlocalbin 2>/dev/null; then
    rm -f /usr/local/bin/.test_usrlocalbin
else
    echo "没有写入/usr/local/bin 的权限,请使用sudo ./install_subrepo.sh运行"
    exit 1
fi

# 定义要添加到 /etc/gitconfig 的内容
GITCONFIG_LINE="[alias]
    subrepo= !bash subrepo.sh"

# 检查 /etc/gitconfig 是否存在
if [ -f /etc/gitconfig ]; then
  # 检查 alias 是否已存在
  if ! grep -qF "[alias]" /etc/gitconfig; then
    # 添加行到 /etc/gitconfig
    echo -e "$GITCONFIG_LINE" | sudo tee -a /etc/gitconfig > /dev/null
    echo "已添加行到 /etc/gitconfig"
  else
    echo "该 alias 已存在于 /etc/gitconfig"
  fi
fi

# 创建 /usr/bin/subrepo.sh 并写入内容

prog_name="/usr/local/bin/subrepo.sh"

sed "1,/^# END OF THE SCRIPT/d" "$0" > ${prog_name}  

# 给予执行权限
chmod +x $prog_name

rm -f "$0"

# WARNING: Do not modify the following !!!
exit 0
# END OF THE SCRIPT  #这是shell 脚本当前的最后一行
