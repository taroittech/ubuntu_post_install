#!/bin/bash

set -e

echo "=========================================="
echo "  Zabbix 7.x asennus (EI tietokanta-asetuksia)"
echo "  Valitse käytettävä repository-versio"
echo "=========================================="
echo
echo "1) Zabbix 7.2"
echo "2) Zabbix 7.4"
echo

read -p "Valitse versio (1/2): " VERSION

case "$VERSION" in
    1)
        ZABBIX_REPO_URL="https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb"
        REPO_FILE="zabbix-release_latest_7.2+ubuntu24.04_all.deb"
        echo "Valittu: Zabbix 7.2"
        ;;
    2)
        ZABBIX_REPO_URL="https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb"
        REPO_FILE="zabbix-release_latest_7.4+ubuntu24.04_all.deb"
        echo "Valittu: Zabbix 7.4"
        ;;
    *)
        echo "Virheellinen valinta!"
        exit 1
        ;;
esac

echo
echo "==> Päivitetään pakettilista"
apt update

echo "==> Ladataan Zabbix repository: $REPO_FILE"
wget -q "$ZABBIX_REPO_URL"

echo "==> Asennetaan repository-paketti"
dpkg -i "$REPO_FILE"

echo "==> Päivitetään pakettilista"
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
