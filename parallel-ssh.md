# Install
```apt install -y pssh```


# Exemple: crear un usuari "alumne/alumne" en cada ordinador
1. Generar password encriptat (alumne)
  ```
  openssl passwd -crypt
  ```
2. Generar arxiu hosts
  ```bash
  for i in {100..253}; do echo "10.2.1.$i"; done > hosts.txt
  ```
3. Executar useradd en tots els hosts
  ```
  parallel-ssh -h hosts.txt -O StrictHostKeyChecking=no -l administrador -A -i "printf 'passwdadministrador\n' | sudo -S useradd -m -p A8SQLoeC.o/Ps -s /bin/bash alumne"
  ```

  *(millor fer-ho amb clau publica)*

4. Executar script:
  ```
  parallel-ssh -h hosts.txt -P -O StrictHostKeyChecking=no -I < script
  ```

## SCRIPTS:

1. Obtenir la IP i SERIAL de cada ordinador de la xarxa:

```
#!/usr/bin/bash

HIP=$(ip r | grep default | cut -d" " -f9) 
HSERIAL=$(lshw -c System | grep serie | cut -d" " -f6)

echo "YYYYYYYYYY $HIP,$HSERIAL"
```
