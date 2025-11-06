#!/bin/bash

set -e

echo "=========================================="
echo "  Zabbix 7.2 asennus (EI tietokanta-asetuksia)"
echo "  Oletus: Tietokanta on jo valmiiksi luotu ja konfiguroitu."
echo "=========================================="

echo "==> Päivitetään pakettilista"
apt update

echo "==> Ladataan ja asennetaan Zabbix repository"
wget -q https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update

echo "==> Asennetaan Zabbix serveri, frontend ja agent"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent zabbix-sql-scripts

echo "==> HUOM: /etc/zabbix/zabbix_server.conf EI muokata."
echo "         Varmista itse, että DBName, DBUser ja DBPassword ovat oikein."

echo "==> Käynnistetään Zabbix-palvelut"
systemctl restart zabbix-server zabbix-agent apache2

echo "==> Asetetaan palvelut käynnistymään automaattisesti"
systemctl enable zabbix-server zabbix-agent apache2

echo
echo "=============================================="
echo " Asennus valmis!"
echo " Muista konfiguroida tietokanta:"
echo "   /etc/zabbix/zabbix_server.conf"
echo
echo " Zabbix-web UI:"
echo "   http://<palvelimen_IP>/zabbix"
echo "=============================================="
