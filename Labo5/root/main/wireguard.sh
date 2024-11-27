#!/bin/bash -e
chmod 600 ./wireguard/config/wg0.conf
# Démarrer WireGuard
wg-quick up ./wireguard/config/wg0.conf
