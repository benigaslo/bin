# Canvia el hostname de pc, i instala el ClientFog (i mono)

HOSTNAME=$1
while [[ -z $HOSTNAME ]] 
do
    echo "HOSTNAME:"
    read HOSTNAME
done

echo "$HOSTNAME" > /etc/hostname

sed -i "/127.0.1.1/d" /etc/hosts
printf "127.0.1.1\t$HOSTNAME" >> /etc/hosts 


apt update
apt -y install dirmngr gnupg apt-transport-https ca-certificates software-properties-common wget
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'
apt update
apt install mono-complete 
wget http://172.21.44.254/fog/client/download.php?smartinstaller
mono SmartInstaller.exe --server 172.21.44.254
