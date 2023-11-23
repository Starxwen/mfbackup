# 魔方云备份脚本

#### 介绍

本脚本是魔方云小鸡备份脚本，基于rsync，如果有运行报错可以手动安装一下rsync

运行该脚本会自动将/home/kvm目录下除images（镜像）外的全部文件备份到指定的备份服务器的/home/mfbackup目录

最后的50G表示则将小于50G的文件都备份，可以排除掉一些硬盘文件过大的文件，可以自行更改

一键使用：

`bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) <服务器IP> <SSH用户名> <SSH密码> 50G
`
