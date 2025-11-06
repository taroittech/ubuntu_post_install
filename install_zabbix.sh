Skip to content
Chat history

You said:
Tee näistä ohjeista Bash-scripti
Install and configure Zabbix for your platform
a. Become root user
Start new shell session with root privileges.

$ sudo -s
b. Install Zabbix repository
Documentation
# wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
# dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
# apt update
c. Install Zabbix server, frontend, agent
# apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
d. Create initial database
Documentation
Make sure you have database server up and running.

Run the following on your database host.

# mysql -uroot -p
password
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;
On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.

# zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
Disable log_bin_trust_function_creators option after importing database schema.

# mysql -uroot -p
password
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;
e. Configure the database for Zabbix server
Edit file /etc/zabbix/zabbix_server.conf

DBPassword=password
f. Start Zabbix server and agent processes
Start Zabbix server and agent processes and make it start at system boot.

# systemctl restart zabbix-server zabbix-agent apache2
# systemctl enable zabbix-server zabbix-agent apache2
ChatGPT said:
Tässä on valmis Bash-scripti, joka automatisoi ohjeesi mahdollisimman pitkälle.
Huom: Scripti olettaa, että MySQL/MariaDB on jo asennettu paikallisesti ja root-salasana tunnetaan. Syötä ZABBIX_DB_PASS muuttujaksi haluamasi salasana ennen ajoa.

#!/bin/bash

set -e

### ASETUKSET ###
ZABBIX_DB="zabbix"
ZABBIX_DB_USER="zabbix"
ZABBIX_DB_PASS="password"         # <-- Vaihda haluamaksesi
MYSQL_ROOT_PASS="rootpassword"    # <-- Vaihda MySQL-root salasanasi

echo "==> Vaihe 1: Ladataan ja asennetaan Zabbix repository"
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update

echo "==> Vaihe 2: Asennetaan Zabbix serveri, frontend ja agent"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "==> Vaihe 3: Luodaan tietokanta ja käyttäjä MySQL:ään"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
create database ${ZABBIX_DB} character set utf8mb4 collate utf8mb4_bin;
create user '${ZABBIX_DB_USER}'@'localhost' identified by '${ZABBIX_DB_PASS}';
grant all privileges on ${ZABBIX_DB}.* to '${ZABBIX_DB_USER}'@'localhost';
set global log_bin_trust_function_creators = 1;
EOF

echo "==> Vaihe 4: Tuodaan Zabbixin alkuperäinen tietokantarakenne"
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} ${ZABBIX_DB}

echo "==> Vaihe 5: Poistetaan log_bin_trust_function_creators käytöstä"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
set global log_bin_trust_function_creators = 0;
EOF

echo "==> Vaihe 6: Konfiguroidaan Zabbix-serveri"
sed -i "s/^# DBPassword=.*/DBPassword=${ZABBIX_DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "==> Vaihe 7: Käynnistetään ja enable Zabbix-palvelut"
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "================================================="
echo " Asennus valmis!"
echo " Avaa selain ja siirry osoitteeseen:"
echo "     http://<palvelimen_IP_osoite>/zabbix"
echo "================================================="
Jos haluat, voin myös tehdä skriptistä interaktiivisen (kysyy salasanat ajon aikana).

You said:
Tee versio jossa ensin asennetaan MariaDB ja kysyy salasanat ajon aikana.
ChatGPT said:
Tässä on uusi versio Bash-scriptistä, joka:

✅ Asentaa MariaDB:n
✅ Kysyy root-salasanan, Zabbix-tietokannan salasanan ja muut tarvittavat tiedot ajon aikana
✅ Asentaa ja konfiguroi Zabbixin automaattisesti

✅ Bash-scripti
Tallenna esim. tiedostoon install_zabbix.sh ja aja:

sudo bash install_zabbix.sh
#!/bin/bash

set -e

echo "=========================================="
echo " Zabbix 7.2 + MariaDB asennus"
echo "=========================================="

### KYSYTÄÄN SALASANAT ###

read -s -p "Anna MariaDB root-salasana (uusi, jos MariaDB ei ole vielä asennettu): " MYSQL_ROOT_PASS
echo
read -s -p "Anna Zabbix-tietokannan salasana: " ZABBIX_DB_PASS
echo

ZABBIX_DB="zabbix"
ZABBIX_DB_USER="zabbix"

echo
echo "==> Päivitetään pakettilista"
apt update

echo "==> Asennetaan MariaDB-palvelin"
apt install -y mariadb-server mariadb-client

echo "==> Suoritetaan MariaDB security setup"
# Automatisoitu mysql_secure_installation
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "==> Ladataan ja asennetaan Zabbix repository"
wget -q https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update

echo "==> Asennetaan Zabbix serveri, frontend ja agent"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "==> Luodaan Zabbix-tietokanta ja käyttäjä"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
CREATE DATABASE ${ZABBIX_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER '${ZABBIX_DB_USER}'@'localhost' IDENTIFIED BY '${ZABBIX_DB_PASS}';
GRANT ALL PRIVILEGES ON ${ZABBIX_DB}.* TO '${ZABBIX_DB_USER}'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
EOF

echo "==> Tuodaan Zabbixin tietokantarakenne"
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} ${ZABBIX_DB}

echo "==> Poistetaan log_bin_trust_function_creators käytöstä"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
EOF

echo "==> Konfiguroidaan Zabbix-serveri"
sed -i "s/^# DBPassword=.*/DBPassword=${ZABBIX_DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "==> Käynnistetään ja asetetaan palvelut automaattisesti käynnistyviksi"
systemctl restart zabbix-server zabbix-agent apache2 mariadb
systemctl enable zabbix-server zabbix-agent apache2 mariadb

echo
echo "=============================================="
echo " Asennus valmis!"
echo " Zabbix toimii osoitteessa:"
echo "   http://<palvelimen_IP_osoite>/zabbix"
echo "=============================================="
Jos haluat, voin vielä:

✅ tehdä skriptistä valitsimilla toimivan (esim. --noninteractive)
✅ tehdä lokituksen
✅ lisätä palomuurisäännöt UFW:lle

Sano vain!

You said:
Jätä MariaDB osuus pois.
ChatGPT said:
Tässä on scripti, jossa MariaDB-osuus on poistettu kokonaan ja skripti kysyy vain Zabbix-tietokannan salasanan, olettaen että MariaDB/MySQL on jo asennettu ja root-salasana on tiedossa.

✅ Bash-scripti ilman MariaDB-asennusta
Tallenna esim. install_zabbix.sh ja aja:

sudo bash install_zabbix.sh
#!/bin/bash

set -e

echo "=========================================="
echo "  Zabbix 7.2 asennus (ilman MariaDB-asennusta)"
echo "  Oletus: MariaDB/MySQL on jo asennettu!"
echo "=========================================="

### KYSYTÄÄN SALASANAT ###

read -s -p "Anna MySQL/MariaDB root-salasana: " MYSQL_ROOT_PASS
echo
read -s -p "Anna Zabbix-tietokannan salasana: " ZABBIX_DB_PASS
echo

ZABBIX_DB="zabbix"
ZABBIX_DB_USER="zabbix"

echo
echo "==> Päivitetään pakettilista"
apt update

echo "==> Ladataan ja asennetaan Zabbix repository"
wget -q https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update

echo "==> Asennetaan Zabbix serveri, frontend ja agent"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "==> Luodaan tietokanta ja käyttäjä"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
CREATE DATABASE ${ZABBIX_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER '${ZABBIX_DB_USER}'@'localhost' IDENTIFIED BY '${ZABBIX_DB_PASS}';
GRANT ALL PRIVILEGES ON ${ZABBIX_DB}.* TO '${ZABBIX_DB_USER}'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
EOF

echo "==> Tuodaan Zabbixin tietokantarakenne"
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -u${ZABBIX_DB_USER} -p${ZABBIX_DB_PASS} ${ZABBIX_DB}

echo "==> Poistetaan log_bin_trust_function_creators käytöstä"
mysql -uroot -p"${MYSQL_ROOT_PASS}" <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
EOF

echo "==> Konfiguroidaan Zabbix-serveri"
sed -i "s/^# DBPassword=.*/DBPassword=${ZABBIX_DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "==> Käynnistetään ja asetetaan palvelut automaattisesti käynnistyviksi"
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo
echo "=============================================="
echo " Asennus valmis!"
echo " Avaa selain:"
echo "   http://<palvelimen_IP>/zabbix"
echo "=============================================="
Jos haluat, voin tehdä vielä version joka:

✅ tarkistaa valmiiksi, onko tietokanta jo olemassa
✅ tekee interaktiivisen valikon
✅ lisää UFW-palomuuriportit

Kerro vain mitä haluat!

You said:
Kätä myös tietokannan konfikurointi pois.
ChatGPT said:
Tässä on versio, josta on poistettu täysin:

❌ MariaDB:n asennus
❌ Tietokannan luonti
❌ Tietokannan tuonti
❌ log_bin_trust_function_creators -asetukset

✅ Scripti asentaa vain Zabbix-paketit ja konfiguroi + käynnistää palvelut.
✅ DB-salasanaa ei kysytä, koska konfigurointi on poistettu.

✅ Bash-scripti ilman mitään tietokanta-osuuksia
Tallenna esim. install_zabbix.sh ja aja:

sudo bash install_zabbix.sh
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
Jos haluat, voin tehdä myös version, joka:

✅ tarkistaa, onko Zabbix-tietokanta jo olemassa
✅ tulostaa varoituksen, jos asetukset puuttuvat
✅ kysyy web-käyttöliittymän oletusasetukset

Kerro mitä haluat lisätä!

You said:
Lisää srcriptiin vaihtoehtoinen versio tästä reposta
# wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
# dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
ChatGPT said:
Tässä on päivitetty scripti, jossa on valittavissa Zabbix-repo 7.2 tai 7.4 ennen asennusta.
Skriptin alkuun lisätään valikko, josta käyttäjä valitsee version.

✅ Bash-scripti (Zabbix 7.2 tai 7.4, ei tietokanta-asetuksia)
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
Jos haluat, voin lisätä skriptiin myös:

✅ automaattisen version-tunnistuksen
✅ komentoargumentit (--zabbix-version 7.4)
✅ interaktiivisen konfiguraation /etc/zabbix/zabbix_server.conf

Sano vain!



No file chosenNo file chosen
ChatGPT can make mistakes. Check important info. See Cookie Preferences.
