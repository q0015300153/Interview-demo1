#!/bin/bash

# 啟動服務
/usr/bin/supervisord -c /etc/supervisor/supervisor.conf

# 設定 mariadb root 密碼
mysqladmin -u root password ${DBRootPass}
# 設定 mariadb 新資料庫與使用者
mysql -uroot -p${DBRootPass} -e "CREATE DATABASE ${DBDataBase};"
mysql -uroot -p${DBRootPass} -e "CREATE USER '${DBUserName}'@'localhost' IDENTIFIED BY '${DBUserPass}';"
mysql -uroot -p${DBRootPass} -e "GRANT ALL PRIVILEGES ON ${DBDataBase}.* TO '${DBUserName}'@'localhost';"
