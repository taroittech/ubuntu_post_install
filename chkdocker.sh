#!/bin/bash

if snap list docker >/dev/null 2>&1; then
    echo "Docker installed via SNAP"
elif dpkg -l | grep -q docker-ce; then
    echo "Docker CE installed"
elif dpkg -l | grep -q docker.io; then
    echo "docker.io package installed"
else
    echo "Docker package not detected"
fi
