#!/usr/bin/env bash
#
# git-download.sh
#
# Download or update GitHub repository.
#

set -euo pipefail

REPO_URL="https://github.com/taroittech/ubuntu_post_install.git"
GIT_DIR="${HOME}/GIT"
REPO_DIR="${GIT_DIR}/ubuntu_post_install"

# Install Git if missing
if ! command -v git &>/dev/null; then
    echo "Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
fi

# Create GIT directory
mkdir -p "$GIT_DIR"

# Clone or update repository
if [[ -d "$REPO_DIR/.git" ]]; then
    echo "Updating repository..."
    git -C "$REPO_DIR" pull --ff-only
elif [[ -e "$REPO_DIR" ]]; then
    echo "ERROR: $REPO_DIR already exists."
    exit 1
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

echo "Repository ready: $REPO_DIR"
