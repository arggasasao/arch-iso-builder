#!/bin/bash
# pre-install.sh: Script para recopilar información del usuario antes de archinstall

# Función para listar discos disponibles
list_disks() {
    echo "Discos disponibles:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
}

# Función para seleccionar el disco
select_disk() {
    list_disks
    echo "Por favor, selecciona el disco donde instalar Arch Linux (ejemplo: /dev/sda):"
    read -r disk
    while [ ! -b "$disk" ]; do
        echo "Disco inválido. Ingresa un disco válido (ejemplo: /dev/sda):"
        read -r disk
    done
    echo "Disco seleccionado: $disk"
}

# Función para obtener nombre de usuario y contraseña
get_user_credentials() {
    echo "Ingresa el nombre de usuario para el nuevo usuario:"
    read -r username
    echo "Ingresa la contraseña para el nuevo usuario:"
    read -s password
    echo "Confirma la contraseña:"
    read -s password_confirm
    while [ "$password" != "$password_confirm" ]; do
        echo "Las contraseñas no coinciden. Intenta de nuevo."
        echo "Ingresa la contraseña:"
        read -s password
        echo "Confirma la contraseña:"
        read -s password_confirm
    done
}

# Script principal
echo "Bienvenido a la instalación de Arch Linux"

# Seleccionar disco
select_disk

# Obtener credenciales
get_user_credentials

# Actualizar el archivo JSON de archinstall
json_file="/root/minimal-install.json"
jq --arg disk "$disk" --arg username "$username" --arg password "$password" \
   '.disk_config.device = $disk | .users[0].username = $username | .users[0].password = $password' \
   "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"

# echo $disk
# echo $username
# echo $password

# cat ${json_file}
# Ejecutar archinstall
# archinstall --config "$json_file" --silent
archinstall --config "$json_file"
