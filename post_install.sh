#!/bin/bash
# Debian/Ubuntu postinstallation script
# TaroITTech
# 2025.06.27 created
# 2025.06.27 modified

# We will make sure that the list is found.
if [ ! -f programlist.txt ]; then
  echo "Error: programlist.txt not found!"
  exit 1
fi

# Updating the system.
sudo apt update && sudo apt upgrade -y

# Let's read and install programs from the list.
while read -r program; do
  # Blank lines and comments are ignored.
  if [[ -z "$program" || "$program" =~ ^# ]]; then
    continue
  fi
  echo "Let's install.: $program"
  sudo apt install -y "$program"
done < programs.txt

echo "All programs installed!"
