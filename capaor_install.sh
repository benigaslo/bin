apt update
apt install squid

cat << EOF > /etc/squid/conf.d/capaor.conf
acl PERMES dstdomain .gva.es
http_access allow PERMES
EOF

cat << EOF > /usr/local/sbin/capaor
#!/usr/bin/env bash

if [ $1 == "up" ]; then
        echo "Capant internet..."
        echo "Els alumnes han de configurar el proxy (o servidor intermediari) al Firefox:"
        echo "  Proxy HTTP: 10.2.1.254   |  Port: 3128"
        echo "  [v] Usar tambien para HTTPS"
        iptables -P FORWARD DROP
        iptables -D FORWARD -j ACCEPT 2> /dev/null
elif [ $1 == "down" ]; then
        echo "Habilitant internet..."
        iptables -P FORWARD ACCEPT
fi
EOF

chmod +x /usr/local/sbin/capaor
