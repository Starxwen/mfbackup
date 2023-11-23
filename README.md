
本脚本是魔方云小鸡备份脚本，基于rsync，如果有运行报错可以手动安装一下rsync

运行该脚本会自动将/home/kvm目录下除images（镜像）外的全部文件备份到指定的备份服务器的指定目录

最后的50G表示则将小于50G的文件都备份，可以排除掉一些硬盘文件过大的文件，可以自行更改

一键使用：

`脚本：bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) <IP> <SSH用户名> <SSH密码>  <最大文件大小> <目录>`

`示例：bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) 192.168.1.1 root 123456 50G /home/mfbackup`

最大文件大小要带单位，如50M或50G，目录为备份的目录，使用绝对路径，/代表根目录