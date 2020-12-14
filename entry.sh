#!/usr/bin/env bash

set -eu

# Host

echo "
127.0.0.1 steamcommunity.com
127.0.0.1 www.steamcommunity.com
" >> /etc/hosts

# TLS

cd openssl

mkdir -p CA/newcerts
mkdir -p CA/Unblock

# Gen ca-key.pem
openssl genrsa -out ./CA/cakey.pem 2048

# ca-key.pem => ca-cert.pem
SUBJECT="/C=CN/ST=X/L=X/O=X/OU=X/CN=Unblock Steam Self Signed CA"
openssl req -new -x509 -key ./CA/cakey.pem -out ./CA/cacert.pem -days 36500 -config ./root.cfg -subj "$SUBJECT"


# Gen unblock.key
openssl genrsa -out ./CA/Unblock/unblock.key 2048

# unblock.key => unblock.csr
openssl req -new -key ./CA/Unblock/unblock.key -out ./CA/Unblock/unblock.csr -config ./server.cfg -subj "$SUBJECT"

# unblock.csr => unblock.crt
#openssl ca -in ./CA/Unblock/unblock.csr -out ./CA/Unblock/unblock.crt -days 36500 -extensions x509_ext -extfile ./server.cfg  -config ./openssl.cfg

expect << EOF  
spawn openssl ca -in ./CA/Unblock/unblock.csr -out ./CA/Unblock/unblock.crt -days 36500 -extensions x509_ext -extfile ./server.cfg  -config ./openssl.cfg
expect "*Sign the certificate?*"  
send "y\n"
expect "*certified, commit*"  
send "y\n"
expect eof;
EOF

# backup
cp ./CA/cacert.pem ./CA/Unblock/cacert.pem

# Trust CA
cp ./CA/cacert.pem /usr/local/share/ca-certificates/*.crt
update-ca-certificates

cd ..
caddy start --config Caddyfile --adapter caddyfile

echo "NETWORK INIT DONE"

curl -sv https://steamcommunity.com -o tmp-index && rm -rf tmp-index

./ArchiSteamFarm.sh --no-restart --process-required --system-required