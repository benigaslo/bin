#!/usr/bin/bash
# Configuracio dels portatils EducaEnDigital per als carros


# Per a fer proves posar un directori que no siga '/'
PROVA=/

## Configuracio del hostname i la xarxa wifi del carro
mkdir -p $PROVA/etc/netplan

if [ $PROVA != "/" ]
then
    cp /etc/hosts $PROVA/etc/hosts
    cp /etc/hostname $PROVA/etc/hostname
    cp /etc/netplan/01-network-manager-all.yaml $PROVA/etc/netplan/01-network-manager-all.yaml
fi

CARRO=$1
NUM=$2
while [[ -z $CARRO ]] 
do
    echo "CARRO:"
    read CARRO
done
while [[ -z $NUM ]] 
do
    echo "NUMERO PORTATIL:"
    read NUM
done

HOSTNAME="$CARRO-$NUM"

printf "networks:\n  version: 2\n  renderer: NetworkManager\n  wifis:\n    wlan0:\n      access-points:\n        \"WIFI_$CARRO\": {}\n      dhcp4: true" >  $PROVA/etc/netplan/01-network-manager-all.yaml 

echo "$HOSTNAME" > $PROVA/etc/hostname

sed -i "/administrador/d" $PROVA/etc/hosts
sed -i "/127.0.1.1/d" $PROVA/etc/hosts
printf "127.0.1.1\t$HOSTNAME" >> $PROVA/etc/hosts 

netplan apply



## Configuracio de l'acces ssh amb clau publica

apt install -y curl openssh-server

mkdir -p $PROVA/root/.ssh/
mkdir -p $PROVA/etc/ssh/
echo 'PasswordAuthentication no' >> $PROVA/etc/ssh/sshd_config
sh -c 'curl -fsSL  https://github.com/benigaslo/docs/releases/download/id_rsa/id_rsa.pub > $PROVA/root/.ssh/authorized_keys'
