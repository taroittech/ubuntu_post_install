#!/bin/bash

# Käyttö:
# sudo ./poista_kayttaja.sh käyttäjänimi

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Virhe: suorita skripti rootina tai sudolla."
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Käyttö: $0 käyttäjänimi"
    exit 1
fi

USERNAME="$1"

# Tarkistetaan löytyykö käyttäjä
if ! id "$USERNAME" >/dev/null 2>&1; then
    echo "Virhe: käyttäjää '$USERNAME' ei löydy."
    exit 1
fi

# Estetään nykyisen käyttäjän poisto
if [ "$USERNAME" = "${SUDO_USER}" ]; then
    echo "Virhe: et voi poistaa käyttäjää, jolla suoritat skriptiä."
    exit 1
fi

echo "Poistetaan käyttäjä: $USERNAME"
echo "Tämä poistaa myös kotihakemiston /home/$USERNAME"
echo

read -p "Jatketaanko? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Peruutettu."
    exit 0
fi

# Tapa mahdolliset käyttäjän prosessit
pkill -KILL -u "$USERNAME" 2>/dev/null || true

# Poista käyttäjä ja kotihakemisto
userdel -r "$USERNAME"

echo
echo "Käyttäjä '$USERNAME' poistettu."

# Tarkistetaan jäikö käyttäjän oma ryhmä
if getent group "$USERNAME" >/dev/null 2>&1; then
    echo "Poistetaan käyttäjän ryhmä '$USERNAME'..."
    groupdel "$USERNAME" 2>/dev/null || true
fi

echo "Valmis."
