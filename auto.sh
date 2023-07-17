#!/bin/bash

# Master Sunucu Ayarları
master_ip="10.16.0.230"
master_hostname="16230-master"

# Slave Sunucu Ayarları
slave_ip="10.16.0.229"
slave_hostname="16229-slave"

# Master Sunucu Yapılandırması
echo "[1/6] Master Sunucu Yapılandırılıyor..."
echo "server-id=1" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "log_bin = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "binlog_format = ROW" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "expire_logs_days = 10" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "max_binlog_size = 100M" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "log_error = /var/log/mysql/error.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf

# Slave Sunucu Yapılandırması
echo "[2/6] Slave Sunucu Yapılandırılıyor..."
echo "server-id=2" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "log_bin = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "binlog_format = ROW" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "expire_logs_days = 10" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "max_binlog_size = 100M" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
echo "log_error = /var/log/mysql/error.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf

# Mariadb Servisleri Yeniden Başlatılıyor
echo "[3/6] Mariadb Servisleri Yeniden Başlatılıyor..."
systemctl restart mysql

# Master Sunucuda Replication Kullanıcısı Oluşturuluyor
echo "[4/6] Master Sunucuda Replication Kullanıcısı Oluşturuluyor..."
mysql -u root -e "CREATE USER 'repl_user'@'%' IDENTIFIED BY 'repl_password';"
mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Slave Sunucuda Replication Ayarları Yapılıyor
echo "[5/6] Slave Sunucuda Replication Ayarları Yapılıyor..."
mysql -u root -e "CHANGE MASTER TO MASTER_HOST='$master_hostname', MASTER_USER='repl_user', MASTER_PASSWORD='repl_password', MASTER_AUTO_POSITION=1;"
mysql -u root -e "START SLAVE;"

# Master Sunucuda Binary Log Aktifleştiriliyor
echo "[6/6] Master Sunucuda Binary Log Aktifleştiriliyor..."
mysql -u root -e "PURGE BINARY LOGS BEFORE NOW();"
mysql -u root -e "RESET MASTER;"

echo "Yapılandırma tamamlandı."
