#!/bin/bash

echo "魔方云备份脚本 作者：星跃云"

if [ "$#" -ne 6 ]; then
    echo "用法: bash <(curl -sS http://mirrors.xwyue.com/mfbackup.sh) <远程IP> <SSH用户名> <SSH密码> <远程SSH端口> <最大文件大小> <远程备份目录>"
    exit 1
fi
start_time=$(date +%s)
REMOTE_SERVER_IP="$1"
SSH_USERNAME="$2"
SSH_PASSWORD="$3"
REMOTE_SSH_PORT="$4"
MAX_SIZE="$5"
REMOTE_BACKUP_DIR="$6"
SOURCE_DIR="/home/kvm"
EXCLUDE_DIR="/home/kvm/images"

# Check if sshpass is installed, if not, try to install it
if ! command -v sshpass &> /dev/null; then
    echo "检测到没有安装sshpass. 即将进行安装..."
    sudo yum install -y sshpass
    # If installation fails, exit with an error
    if [ $? -ne 0 ]; then
        echo "安装 sshpass 失败. 请尝试手动安装."
        exit 1
    fi
    echo "sshpass 安装成功."
fi

# SSH连接测试
sshpass -p "$SSH_PASSWORD" ssh -p "$REMOTE_SSH_PORT" "$SSH_USERNAME@$REMOTE_SERVER_IP" true
if [ $? -ne 0 ]; then
    echo "SSH连接测试失败，请检查连接配置，备份中止"
    exit 1
fi

# 删除远程服务器的REMOTE_BACKUP_DIR文件夹
echo "执行删除原备份文件夹"
sshpass -p "$SSH_PASSWORD" ssh -p "$REMOTE_SSH_PORT" "$SSH_USERNAME@$REMOTE_SERVER_IP" "rm -rf $REMOTE_BACKUP_DIR"
echo "删除原备份文件夹成功!"

# Convert MAX_SIZE to bytes
case $MAX_SIZE in
  *[gG]) MAX_SIZE=$(echo "$MAX_SIZE" | tr -d 'G' | awk '{printf "%.0f\n", $1 * 1024^3}');;
  *[mM]) MAX_SIZE=$(echo "$MAX_SIZE" | tr -d 'M' | awk '{printf "%.0f\n", $1 * 1024^2}');;
  *[kK]) MAX_SIZE=$(echo "$MAX_SIZE" | tr -d 'K' | awk '{printf "%.0f\n", $1 * 1024}');;
  *) MAX_SIZE=$(echo "$MAX_SIZE" | tr -d 'B');;
esac

# Use find to get a list of files (excluding the specified directories)
find "$SOURCE_DIR" -type f \( -not -path "$EXCLUDE_DIR/*" \) |
while IFS= read -r file; do
  # Adjust the source path to remove /home/kvm
  relative_path="${file#$SOURCE_DIR/}"

  # Check file size with stat and compare against MAX_SIZE
  file_size=$(stat -c %s "$file")
  if [ "$file_size" -le "$MAX_SIZE" ]; then
    current_time=$(date +"[%H:%M:%S]")
    echo "$current_time 正在备份文件: $file"
    sshpass -p "$SSH_PASSWORD" rsync -a --progress --rsync-path="mkdir -p \"$REMOTE_BACKUP_DIR/\$(dirname $relative_path)\" && rsync" -e "ssh -p $REMOTE_SSH_PORT" "$file" "$SSH_USERNAME@$REMOTE_SERVER_IP:$REMOTE_BACKUP_DIR/$relative_path"
    echo "$current_time 备份完成: $file"
  fi
done

current_time=$(date +"[%H:%M:%S]")
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
hours=$((elapsed_time / 3600))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))
 
printf "%s全部文件备份完成,总用时:%02d时%02d分%02d秒\n" $current_time $hours $minutes $seconds