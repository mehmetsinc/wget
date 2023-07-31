#!/bin/bash
# GLPI kurulum scripti

# Apache, MySQL ve PHP kurulumu
sudo apt update
sudo apt -y install apache2 mysql-server php php-mysql libapache2-mod-php php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-tidy php-json php-imagick php-curl php-zip

# MySQL ayarları
echo "Aşağıdaki işlem için MySQL root parolanızı girin"
mysql -u root -p <<QUERY_INPUT
CREATE DATABASE glpi;
CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';
FLUSH PRIVILEGES;
QUERY_INPUT

# GLPI'nin son sürümünü indirme ve çıkarma
wget https://github.com/glpi-project/glpi/releases/download/10.0.8/glpi-10.0.8.tgz
tar xvf glpi-10.0.8.tgz
sudo mv glpi /var/www/html/

# Apache ve MySQL servislerini yeniden başlatma
sudo systemctl restart apache2.service
sudo systemctl restart mysql.service

# Yetkileri ayarlama
sudo chown -R www-data:www-data /var/www/html/glpi
sudo chmod -R 755 /var/www/html/glpi

echo "GLPI kurulumu tamamlandı. Lütfen http://server-ip/glpi adresini ziyaret edin ve kurulumu tamamlayın."
