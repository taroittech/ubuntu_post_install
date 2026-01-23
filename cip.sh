#!/bin/bash

NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

NEW_IP="$1"
NEW_GATEWAY="$2"

# Parametrien tarkistus
if [[ -z "$NEW_IP" || -z "$NEW_GATEWAY" ]]; then
  echo "Käyttö:"
  echo "  sudo $0 <IP/CIDR> <GATEWAY>"
  echo "Esim:"
  echo "  sudo $0 10.120.187.20/24 10.120.187.1"
  exit 1
fi

# Root-tarkistus
if [[ $EUID -ne 0 ]]; then
  echo "Aja scripti root-oikeuksilla (sudo)."
  exit 1
fi

# Tiedoston olemassaolon tarkistus
if [[ ! -f "$NETPLAN_FILE" ]]; then
  echo "Netplan-tiedostoa ei löytynyt: $NETPLAN_FILE"
  exit 1
fi

# Varmuuskopio
cp "$NETPLAN_FILE" "$NETPLAN_FILE.bak.$(date +%F_%H-%M-%S)"

# Korvaa addresses:-kohdan IP (ensimmäinen IP-rivi)
sed -i "/addresses:/{
  n
  s|- .*|- $NEW_IP|
}" "$NETPLAN_FILE"

# Korvaa default-reitin gateway
sed -i "s|via: .*|via: $NEW_GATEWAY|" "$NETPLAN_FILE"

# Ota asetukset käyttöön
netplan apply

echo "Netplan päivitetty onnistuneesti:"
echo "  IP: $NEW_IP"
echo "  Gateway: $NEW_GATEWAY"
