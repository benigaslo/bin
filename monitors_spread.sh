#!/bin/bash

# copia l'arxiu monitors.xml en les carpetes dels usuaris
for d in /home/*/; do
  mkdir -p $d/.config;
  cp /var/lib/gdm3/.config/monitors.xml $d/.config/monitors.xml;
  chown --reference=$d $d/.config/monitors.xml;
done

# for d in /home/*/; do mkdir -p $d/.config; cp /var/lib/gdm3/.config/monitors.xml $d/.config/monitors.xml; chown --reference=$d $d/.config/monitors.xml; done
