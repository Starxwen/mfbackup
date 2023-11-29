
本脚本是魔方云小鸡备份脚本，基于rsync，如果有运行报错可以手动安装一下rsync

运行该脚本会自动将/home/kvm目录下除images（镜像）外的全部文件备份到指定的备份服务器的指定目录

最后的50G表示则将小于50G的文件都备份，可以排除掉一些硬盘文件过大的文件，可以自行更改

一键使用：

`脚本：bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) <IP> <SSH用户名> <SSH密码> <SSH端口> <最大文件大小> <目录>`

`示例：bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) 192.168.1.1 root 123456 22 50G /home/mfbackup`

最大文件大小要带单位，如50M或50G，目录为备份的目录，使用绝对路径，/代表根目录 有多台宿主机请使用不同目录

最大文件大小的单位有：G M K，大小建议带单位，否则默认单位是字节），例如：50G 50M 50K

计划任务：

在root目录执行下面内容：


```
curl -O http://download.leapteam.cn/mfbackup.sh
chmod +x mfbackup.sh
```

上面可以偶尔执行一遍，以保证该文件是最新版本~

然后输入：`crontab -e`

在编辑模式下添加下面内容

`0 3 */3 * * /bin/bash /root/mfbackup.sh 192.168.1.1 root 123456 22 50G /home/mfbackup >> /root/mfbackuplogs/$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1
`

分钟 小时 日期 月份 星期 （crontab表达式）

上面代码代表是每3天的凌晨3点0分执行备份计划，并输出到/root/mfbackuplogs/时间.log文件下面

注意：mfbackuplogs目录需要手动先创建，也可以手动更改路径或者取消输出该日志，创建命令：`mkdir -p /root/mfbackuplogs`
