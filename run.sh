#!/bin/bash



RESET="\e[0m"
ROJO="\e[31m"
VERDE="\e[32m"

ISO="debian-13.1.0-amd64-netinst.iso"



verification_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${ROJO}[-] Este script se debe ejecutar con permisos de root.${RESET}"
    exit 1
  fi
}

checkear_e_instalar_paquetes() {
  dpkg -s p7zip-full &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${VERDE}[+] Instalación del paquete p7zip-full.${RESET}"
    apt install p7zip-full -y 1>/dev/null
  fi
  dpkg -s isolinux &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${VERDE}[+] Instalación del paquete isolinux.${RESET}"
    apt install isolinux -y 1>/dev/null
  fi
}

extraer_iso() {
  echo -e "${VERDE}[+] Extrayendo imagen ISO.${RESET}"
  mkdir isofiles/
  7z x -oisofiles/ "$ISO"
}

extraer_initrd() {
  echo -e "${VERDE}[+] Extrayendo fichero initrd.gz.${RESET}"
  chmod +w -R isofiles/install.amd/
  gunzip isofiles/install.amd/initrd.gz
}

aniadir_preseed_al_initrd() {
  echo -e "${VERDE}[+] Aplicando fichero preseed.cfg.${RESET}"
  echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
  gzip isofiles/install.amd/initrd
  chmod -w -R isofiles/install.amd/
}

regenerar_md5sum() {
  echo -e "${VERDE}[+] Regenerando hashes de la ISO en el fichero md5sum.txt.${RESET}"
  cd isofiles/
  chmod +w md5sum.txt
  find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
  chmod -w md5sum.txt
  cd ../
}

generar_iso() {
  echo -e "${VERDE}[+] Generando imagen ISO.${RESET}"
  xorriso -as mkisofs \
    -r -V 'Debian 13.1.0 amd64 n' \
    -o "modified.iso" \
    -J -joliet-long \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -boot-load-size 4 -boot-info-table -no-emul-boot \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot -isohybrid-gpt-basdat \
    "isofiles"
}

limpiar() {
  echo -e "${VERDE}[+] Limpieza y finalización.${RESET}"
  chmod +w isofiles/
  rm -r isofiles/
}



verification_root
checkear_e_instalar_paquetes
extraer_iso
extraer_initrd
aniadir_preseed_al_initrd
regenerar_md5sum
generar_iso
limpiar

