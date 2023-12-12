#!/bin/bash

# 如果 /etc/apache2 是空的，從備份中恢復並設定 ServerName
if [ ! "$(ls -A /etc/apache2)" ]; then
   rsync -a /backup/apache2/ /etc/apache2/
fi

# 如果 /etc/php 是空的，從備份中恢復
if [ ! "$(ls -A /etc/php)" ]; then
   rsync -a /backup/php/ /etc/php/
fi

# 如果 /etc/php/8.2 是空的，從備份中恢復
if [ ! "$(ls -A /etc/php/8.2)" ]; then
   rsync -a /backup/php/8.2/ /etc/php/8.2/
fi

# 刪除備份
#rm -rf /backup/*

# 檢查並修正 /var/www 和 /var/www/html 的擁有者和權限
for dir in /var/www /var/www/html; do

    # 檢查資料夾是否存在
    if [ -d "$dir" ]; then

        # 檢查擁有者和使用者組
        owner_group=$(stat -c '%U:%G' "$dir")
        if [ "$owner_group" != "root:www-data" ]; then
            chown root:www-data "$dir"
            echo "Changed owner and group of $dir to root:www-data"
        fi

        # 檢查權限
        permissions=$(stat -c '%a' "$dir")
        if [ "$permissions" != "750" ]; then
            chmod 750 "$dir"
            echo "Changed permissions of $dir to 750"
        fi

    else
        echo "Directory $dir does not exist!"
    fi

done

# 檢查 /etc/apache2/conf-available/servername.conf 文件是否存在
if [ ! -f /etc/apache2/conf-available/servername.conf ]; then
    # 設定 Apache ServerName 為容器的主機名，以避免啟動警告
    echo "ServerName $(hostname)" > /etc/apache2/conf-available/servername.conf
    
    # 啟用 servername 配置
    a2enconf servername
fi

# PHP 設定
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 1024M/' /etc/php/8.2/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 1024M/' /etc/php/8.2/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 4096M/' /etc/php/8.2/apache2/php.ini
sed -i 's/max_execution_time = .*/max_execution_time = 360/' /etc/php/8.2/apache2/php.ini
sed -i 's/max_input_time = .*/max_input_time = 360/' /etc/php/8.2/apache2/php.ini

# 啟動 Apache
service apache2 start
service cron start

# 防止容器退出
/bin/bash
