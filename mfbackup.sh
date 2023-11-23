#!/bin/bash

echo "魔方备份脚本"
echo "作者：星跃云"
echo "1. 开始备份"
echo "2. 退出"

read -p "请选择操作（输入数字）: " choice

case $choice in
  1)
    echo "开始备份"

    read -p "请输入远程服务器IP: " REMOTE_SERVER_IP
    read -p "请输入SSH用户名: " SSH_USERNAME
    read -p "请输入SSH密码: " SSH_PASSWORD
    read -p "请输入最大文件大小（例如：50G）: " MAX_SIZE

    SOURCE_DIR="/home/kvm"
    EXCLUDE_DIR="/home/kvm/images"
    DESTINATION_DIR="/home/backup"

    mkdir -p "$DESTINATION_DIR"

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

    # Use find to get a list of files smaller than the specified size (excluding the specified directory)
    find "$SOURCE_DIR" -maxdepth 1 -type f -not -path "$EXCLUDE_DIR/*" -size -"$MAX_SIZE" |
    while read -r file; do
      echo "正在备份文件: $file"
      rsync -a --progress -R "$file" "$DESTINATION_DIR"
      echo "备份完成: $file"
    done

    # Use sshpass to provide the password for ssh
    sshpass -p "$SSH_PASSWORD" rsync -a --progress "$DESTINATION_DIR" "$SSH_USERNAME@$REMOTE_SERVER_IP:$DESTINATION_DIR"

    echo "备份完成."
    ;;

  2)
    echo "退出"
    exit 0
    ;;

  *)
    echo "无效的选项"
    exit 1
    ;;
esac
