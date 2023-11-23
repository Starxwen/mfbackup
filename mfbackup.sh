#!/bin/bash

echo "魔方备份脚本"
echo "作者：星跃云"

if [ "$#" -ne 5 ]; then
    echo "用法: bash <(curl -sS http://download.leapteam.cn/mfbackup.sh) <远程IP> <SSH用户名> <SSH密码> <最大文件大小> <备份目录>"
    exit 1
fi

REMOTE_SERVER_IP="$1"
SSH_USERNAME="$2"
SSH_PASSWORD="$3"
MAX_SIZE="$4"
BACKUP_DIR="$5"
SOURCE_DIR="/home/kvm"
EXCLUDE_DIR="/home/kvm/images"
mkdir -p "$BACKUP_DIR"

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

# Use rsync with --relative option to preserve the directory structure
rsync -a --relative --exclude="$EXCLUDE_DIR" --max-size="$MAX_SIZE" "$SOURCE_DIR/" "$BACKUP_DIR"

# Use sshpass to provide the password for ssh
sshpass -p "$SSH_PASSWORD" rsync -a --progress "$BACKUP_DIR/" "$SSH_USERNAME@$REMOTE_SERVER_IP:$BACKUP_DIR/"

# 删除本地备份目录
rm -rf "$BACKUP_DIR"

echo "备份完成."
