# bin
Scripts and bins

## ssx

  ssx < script

Exemple script `hostinfo`:
  ```
  HIP=$(ip r | grep default | cut -d" " -f9) 
  HSERIAL=$(lshw -c System | grep serie | cut -d" " -f6)
  echo "$HIP:$HSERIAL"
  ```
