#!/bin/bash -e

cd ipsec/pems
cp caCert.pem /etc/swanctl/x509ca
cp mainServerKey.pem /etc/swanctl/private
cp mainServerCert.pem /etc/swanctl/x509
cp ../swanctl.conf /etc/swanctl/conf.d

pkill charon || true
/usr/lib/ipsec/charon &
sleep 1

swanctl --load-creds
swanctl --load-conns
swanctl --load-pools
