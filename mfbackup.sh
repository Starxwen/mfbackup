#!/bin/bash

echo "魔方备份脚本"
echo "作者：星跃云"

if [ "$#" -ne 5 ]; then
    echo "用法: bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) <远程IP> <SSH用户名> <SSH密码> <最大文件大小> <远程备份目录>"
    exit 1
fi

REMOTE_SERVER_IP="$1"
SSH_USERNAME="$2"
SSH_PASSWORD="$3"
MAX_SIZE="$4"
REMOTE_BACKUP_DIR="$5"
SOURCE_DIR="/home/kvm"
EXCLUDE_DIR="/home/kvm/images"

# Check if sshpass is installed, if not, try to install it
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Attempting to install..."
    sudo yum install -y sshpass
    # If installation fails, exit with an error
    if [ $? -ne 0 ]; then
        echo "Failed to install sshpass. Please install it manually."
        exit 1
    fi
    echo "sshpass installed successfully."
fi

# Use find to get a list of files smaller than the specified size (excluding the specified directories)
find "$SOURCE_DIR" -type f \( -not -path "$EXCLUDE_DIR/*" \) -size -"$MAX_SIZE" |
while IFS= read -r file; do
  # Adjust the source path to remove /home/kvm
  relative_path="${file#$SOURCE_DIR/}"

  echo "正在备份文件: $file"
  sshpass -p "$SSH_PASSWORD" rsync -a --progress --rsync-path="mkdir -p \"$REMOTE_BACKUP_DIR/\$(dirname $relative_path)\" && rsync" "$file" "$SSH_USERNAME@$REMOTE_SERVER_IP:$REMOTE_BACKUP_DIR/$relative_path"
  echo "备份完成: $file"
done

echo "备份完成."
