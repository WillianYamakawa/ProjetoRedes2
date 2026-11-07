#!/bin/bash
set -e

SENHA_PROXY1="proxy1"
SENHA_PROXY2="proxy2"

apt-get update
apt-get install squid apache2-utils

arquivo_senhas=/etc/squid/squid.pass
umask 027

if [ -f "$arquivo_senhas" ]; then
    printf '%s\n' "$SENHA_PROXY1" | htpasswd -iB "$arquivo_senhas" proxy1
else
    printf '%s\n' "$SENHA_PROXY1" | htpasswd -ciB "$arquivo_senhas" proxy1
fi

printf '%s\n' "$SENHA_PROXY2" | htpasswd -iB "$arquivo_senhas" proxy2
chown root:proxy "$arquivo_senhas"
chmod 640 "$arquivo_senhas"
