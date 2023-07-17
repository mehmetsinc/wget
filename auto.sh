#!/bin/bash

# Sunucu Hostname'i
hostname=$(hostname)

# Master Sunucu Ayarları
master_ip="10.16.0.230"
master_hostname="16230-master"

# Slave Sunucu Ayarları
slave_ip="10.16.0.229"
slave_hostname="16229-slave"

if [[ $hostname == $master_hostname ]]; then
    # Master Sunucu Yapılandırması
    echo "[1/6] Master Sunucu Yapılandırılıyor..."
    echo "server-id=1" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "log_bin = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "binlog_format = ROW" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "expire_logs_days = 10" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "max_binlog_size = 100M" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "log_error = /var/log/mysql/error.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf

    # Mariadb Servisleri Yeniden Başlatılıyor
    echo "[2/6] Mariadb Servisleri Yeniden Başlatılıyor..."
    systemctl restart mysql

    # Master Sunucuda Replication Kullanıcısı Oluşturuluyor
    echo "[3/6] Master Sunucuda Replication Kullanıcısı Oluşturuluyor..."
    mysql -u root -e "CREATE USER 'repl_user'@'%' IDENTIFIED BY 'repl_password';"
    mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Master Sunucuda Binary Log Aktifleştiriliyor
    echo "[4/6] Master Sunucuda Binary Log Aktifleştiriliyor..."
    mysql -u root -e "PURGE BINARY LOGS BEFORE NOW();"
    mysql -u root -e "RESET MASTER;"

    echo "Master Sunucu yapılandırması tamamlandı."

elif [[ $hostname == $slave_hostname ]]; then
    # Slave Sunucu Yapılandırması
    echo "[1/4] Slave Sunucu Yapılandırılıyor..."
    echo "server-id=2" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "log_bin = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "binlog_format = ROW" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "expire_logs_days = 10" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "max_binlog_size = 100M" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "log_error = /var/log/mysql/error.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf

    # Mariadb Servisleri Yeniden Başlatılıyor
    echo "[2/4] Mariadb Servisleri Yeniden Başlatılıyor..."
    systemctl restart mysql

    # Slave Sunucuda Replication Ayarları Yapılıyor
    echo "[3/4] Slave Sunucuda Replication Ayarları Yapılıyor..."
    mysql -u root -e "CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='repl_user', MASTER_PASSWORD='repl_password';"
    mysql -u root -e "START SLAVE;"

    echo "Slave Sunucu yapılandırması tamamlandı."

else
    echo "Bilinmeyen bir sunucu hostname'i algılandı."
    exit 1
fi
