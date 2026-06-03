#!/bin/bash

# Käyttö:
# sudo ./luo_kayttaja.sh käyttäjänimi

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

# Tarkistetaan löytyykö käyttäjä jo
if id "$USERNAME" >/dev/null 2>&1; then
    echo "Virhe: käyttäjä '$USERNAME' on jo olemassa."
    exit 1
fi

# Selvitetään käyttäjä, jonka ryhmät kopioidaan
SOURCE_USER="${SUDO_USER:-$(logname 2>/dev/null || true)}"

if [ -z "$SOURCE_USER" ] || ! id "$SOURCE_USER" >/dev/null 2>&1; then
    echo "Virhe: lähdekäyttäjää ei voitu selvittää."
    exit 1
fi

echo "Kopioidaan käyttäjän '$SOURCE_USER' lisäryhmät..."

GROUP_LIST=$(
    id -nG "$SOURCE_USER" |
    tr ' ' '\n' |
    grep -vx "$SOURCE_USER" |
    paste -sd, -
)

# Luodaan käyttäjä
useradd \
    -m \
    -U \
    -s /bin/bash \
    ${GROUP_LIST:+-G "$GROUP_LIST"} \
    "$USERNAME"

echo
echo "Aseta salasana käyttäjälle $USERNAME"
passwd "$USERNAME"

echo
echo "Käyttäjä luotu onnistuneesti."
echo

id "$USERNAME"

echo
echo "Kotihakemisto:"
ls -ld "/home/$USERNAME"
