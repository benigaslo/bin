# Install
```apt install -y pssh```


# Exemple: crear un usuari "alumne/alumne" en cada ordinador
1. Generar password encriptat (alumne)
  ```
  openssl passwd -crypt
  ```
2. Generar arxiu hosts
  ```bash
  for i in {15..238}; do echo "10.2.1.$i"; done > hosts.txt
  ```
3. Executar useradd en tots els hosts
  ```
  parallel-ssh -h hosts.txt -O StrictHostKeyChecking=no -l administrador -A -i "printf 'passwdadministrador\n' | sudo -S useradd -m -p A8SQLoeC.o/Ps -s /bin/bash alumne"
  ```

  *(millor fer-ho amb clau publica)*
