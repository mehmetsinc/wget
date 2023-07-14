#!/bin/bash

# Güncellemeleri kontrol et ve indir
sudo apt update -y

# Eski MySQL versiyonlarını kaldır
sudo apt remove mysql-server mysql-client -y

# Gerekli bağımlılıkları yükle
sudo apt install wget lsb-release -y

# Percona repository'sini indir ve etkinleştir
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

# Percona Server 5.7'yi kurmak için repository'yi setupla
sudo percona-release setup ps57

# Güncelleme kontrolünü yeniden yap
sudo apt update -y

# Percona Server'ı yükle
sudo apt-get install percona-server-server -y

# Percona Server'ı başlat ve otomatik başlamasını sağla
sudo systemctl start mysql
sudo systemctl enable mysql
