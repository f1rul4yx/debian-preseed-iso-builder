#!/bin/bash

RESET="\e[0m"
ROJO="\e[31m"
VERDE="\e[32m"

VM="debian13-preseed"
ISO="/home/diego/Documentos/isos/Debian13-Preseed.iso"

verification_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${ROJO}[-] Este script se debe ejecutar con permisos de root.${RESET}"
    exit 1
  fi
}

borrar() {
  virsh destroy $VM &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${ROJO}[-] No se ha apagado la máquina.${RESET}"
  else
    echo -e "${VERDE}[+] Se ha apagado correctamente.${RESET}"
  fi
  virsh undefine --remove-all-storage --nvram $VM &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${ROJO}[-] No se ha borrado la máquina.${RESET}"
  else
    echo -e "${VERDE}[+] Se ha borrado correctamente.${RESET}"
  fi
}

crearUEFI() {
  virt-install \
    --virt-type kvm \
    --name "$VM" \
    --cdrom "$ISO" \
    --os-variant debian13 \
    --disk path=/var/lib/libvirt/images/"$VM".qcow2,size=20 \
    --memory 1024 \
    --vcpus 1 \
    --network network=default \
    --boot uefi \
    --graphics spice
}

crearBIOS() {
  virt-install \
    --virt-type kvm \
    --name "$VM" \
    --cdrom "$ISO" \
    --os-variant debian13 \
    --disk path=/var/lib/libvirt/images/"$VM".qcow2,size=20 \
    --memory 1024 \
    --vcpus 1 \
    --network network=default \
    --graphics spice
}

menu() {
  if [ -z "$1" ]; then
    echo "Uso: $0 {b|cu|cb}"
    exit 1
  fi

  case "$1" in
    b)
      borrar
      ;;
    cu)
      crearUEFI
      ;;
    cb)
      crearBIOS
      ;;
    *)
      echo "Introduce un parámetro"
      exit 1
      ;;
  esac
}

verification_root
menu "$1"
