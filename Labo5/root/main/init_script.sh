#!/bin/bash -e

# Set working directory
mkdir init && cd init

# Generate private keys for mainServer, farServer, and remote
pki --gen --type ed25519 --outform pem > mainServerKey.pem
pki --gen --type ed25519 --outform pem > farServerKey.pem
pki --gen --type ed25519 --outform pem > remoteKey.pem
echo "Private keys generated"

# Create the CA based on the mainServer priv key
pki --self --ca --lifetime 3652 --in mainServerKey.pem --dn "C=CH, O=heig, CN=heig Root CA" --san mainServer --san 10.0.0.2 --outform pem > caCert.pem
echo "CA generated"

# Generate the CSR for mainServer, farServer, and remote
pki --req --type priv --in mainServerKey.pem --dn "C=CH, O=heig, CN=heig.mainServer" --san mainServer --san 10.0.0.2 --outform pem > mainServerReq.pem

pki --req --type priv --in farServerKey.pem --dn "C=CH, O=heig, CN=heig.farServer" --san farServer --san 10.0.0.3 --outform pem > farServerReq.pem

pki --req --type priv --in remoteKey.pem --dn "C=CH, O=heig, CN=heig.remote" --san remote --san 10.0.0.4 --outform pem > remoteReq.pem

echo "CSR generated"

# Issue the CSR for mainServer, farServer, and remote
pki --issue --cacert caCert.pem --cakey mainServerKey.pem --type pkcs10 --in mainServerReq.pem --serial 01 --lifetime 1826 --san mainServer --san 10.0.0.2 --outform pem > mainServerCert.pem

pki --issue --cacert caCert.pem --cakey mainServerKey.pem --type pkcs10 --in farServerReq.pem --serial 02 --lifetime 1826 --san farServer --san 10.0.0.3 --outform pem > farServerCert.pem

pki --issue --cacert caCert.pem --cakey mainServerKey.pem --type pkcs10 --in remoteReq.pem --serial 03 --lifetime 1826 --san remote --san 10.0.0.4 --outform pem > remoteCert.pem
echo "CSR issued"

# Copy all PEM files to /root
cp *.pem /root
echo "PEM files copied to /root"

# Clean up PEM files in the current directory
rm *.pem
echo "Old PEM files deleted"
