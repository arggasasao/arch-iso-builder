#!/bin/bash
# Script to build an Arch ISO with archinstall
# Author: Neo (with Grok's help)
clear
echo "============================================================================="
echo "|                      Arch Linux ISO Builder                               |"
echo "============================================================================="
echo ""

# Source
SOURCE="baseline"
SOURCE="releng"

# Define directories
BASE_DIR="/home/neo/arch-iso-builder"
WORK_DIR="${BASE_DIR}/work"
CONFIG_DIR="${BASE_DIR}/config"
PROFILE_DIR="${WORK_DIR}/${SOURCE}"
OUT_DIR="${BASE_DIR}/out"

# Remove temp folders
sudo rm -rf "${WORK_DIR}/"*

# Create temp folders
sudo mkdir -p "${OUT_DIR}"
sudo chmod 777 "${OUT_DIR}"
sudo mkdir -p "${WORK_DIR}"
sudo chmod 777 "${WORK_DIR}"

init() {

    # Copy baseline profile
    cp -r "/usr/share/archiso/configs/${SOURCE}/" "${WORK_DIR}"

    # Create root dir for scripts
    sudo mkdir -p "${PROFILE_DIR}/airootfs/root/"

    # Copy config and script to ISO root
    sudo cp "${CONFIG_DIR}/minimal-install.json" "${PROFILE_DIR}/airootfs/root/"
    sudo cp "${CONFIG_DIR}/user_configuration.json" "${PROFILE_DIR}/airootfs/root/"
    sudo cp "${CONFIG_DIR}/user_credentials.json" "${PROFILE_DIR}/airootfs/root/"
    sudo cp "${BASE_DIR}/install.sh" "${PROFILE_DIR}/airootfs/root/"
    sudo cp "${BASE_DIR}/pre-install.sh" "${PROFILE_DIR}/airootfs/root/"

    # Ensure script is executable
    sudo chmod +x "${PROFILE_DIR}/airootfs/root/install.sh"
    sudo chmod +x "${PROFILE_DIR}/airootfs/root/pre-install.sh"

    # Add required packages
    echo " " | sudo tee -a "${PROFILE_DIR}/packages.x86_64"
    echo "# Arch ISO Builder #" | sudo tee -a "${PROFILE_DIR}/packages.x86_64"
    echo "archinstall" | sudo tee -a "${PROFILE_DIR}/packages.x86_64"
    echo "base" | sudo tee -a "${PROFILE_DIR}/packages.x86_64"
    echo "networkmanager" | sudo tee -a "${PROFILE_DIR}/packages.x86_64"
    echo "jq" | sudo tee -a "${PROFILE_DIR}/packages.x86_64"

    # Enable autologin in syslinux-linux.cfg (only if not present)
    if ! grep -q "systemd.autologin=root" "${PROFILE_DIR}/syslinux/syslinux-linux.cfg"; then
        sudo sed -i '/APPEND/ s/$/ systemd.autologin=root/' "${PROFILE_DIR}/syslinux/syslinux-linux.cfg"
    fi

    # Ensure NetworkManager starts on boot
    sudo mkdir -p "${PROFILE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants"
    sudo ln -sf /usr/lib/systemd/system/NetworkManager.service "${PROFILE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"

    # Enable autologin via getty for tty1
    sudo mkdir -p "${PROFILE_DIR}/airootfs/etc/systemd/system/getty@tty1.service.d"
    echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM" | sudo tee "${PROFILE_DIR}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf"

    # Add install script to /etc/profile if not present
    if ! grep -q "bash /root/install.sh" "${PROFILE_DIR}/airootfs/etc/profile"; then
        echo -e "\n# Run installation script\nbash /root/pre-install.sh" | sudo tee -a "${PROFILE_DIR}/airootfs/etc/profile"
    fi

    # Build the ISO
    sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"
}

init
