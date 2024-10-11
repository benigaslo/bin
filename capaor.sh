#!/usr/bin/env bash

function capaor_up {
echo "Capant internet..."
echo "  Els alumnes han de configurar el proxy (o servidor intermediari) al Firefox:"
echo "    * Proxy HTTP: 10.2.1.254   |  Port: 3128"
echo "      [v] Usar tambien para HTTPS"
apt update
apt install -y squid
cat << EOF > /etc/squid/conf.d/capaor.conf
acl PERMES dstdomain .gva.es
http_access allow PERMES
EOF
systemctl restart squid
iptables -P FORWARD DROP
iptables -D FORWARD -j ACCEPT 2> /dev/null
}

function capaor_down {
echo "Habilitant internet..."
echo "  Els alumnes ja poden deshabilitar el proxy (no es necessari)"
cat << EOF > /etc/squid/conf.d/capaor.conf
http_access allow all
EOF
systemctl restart squid
iptables -P FORWARD ACCEPT
}

function usage {
echo "Usage: capaor up"
echo "       capaor down"
}

if [ "$1" == "up" ]; then
  capaor_up
elif [ "$1" == "down" ]; then
  capaor_down
else
  usage
fi
