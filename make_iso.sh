#!/bin/bash
# Script to build an Arch ISO with archinstall
# Author: Neo (with Grok's help)
clear
echo "============================================================================="
echo "|                      Arch Linux ISO Builder                               |"
echo "============================================================================="
echo ""

# Define directories
WORK_DIR="/home/neo/arch-iso-builder"
CONFIG_DIR="${WORK_DIR}/config"
BASELINE_DIR="${WORK_DIR}/releng"
OUT_DIR="${WORK_DIR}/out_dir"
TEMP_DIR="${WORK_DIR}/temp_dir"

# Remove temp folders
sudo rm -rf "${BASELINE_DIR}"
sudo rm -rf "${OUT_DIR}"
sudo rm -rf "${TEMP_DIR}"

# Create temp folders
sudo mkdir -p "${OUT_DIR}"
sudo chmod 777 "${OUT_DIR}"
sudo mkdir -p "${TEMP_DIR}"
sudo chmod 777 "${TEMP_DIR}"

init() {
    # Copy baseline profile
    cp -r /usr/share/archiso/configs/releng/ "${BASELINE_DIR}"

    # Add required packages
    echo "archinstall" | sudo tee -a "${BASELINE_DIR}/packages.x86_64"
    echo "base" | sudo tee -a "${BASELINE_DIR}/packages.x86_64"
    echo "networkmanager" | sudo tee -a "${BASELINE_DIR}/packages.x86_64"

    sudo mkdir -p "${BASELINE_DIR}/airootfs/root/"

    # Copy config and script to ISO root
    # sudo cp "${CONFIG_DIR}/minimal-install.json" "${BASELINE_DIR}/airootfs/root/"
    sudo cp "${CONFIG_DIR}/user_configuration.json" "${BASELINE_DIR}/airootfs/root/"
    sudo cp "${CONFIG_DIR}/user_credentials.json" "${BASELINE_DIR}/airootfs/root/"
    sudo cp "${WORK_DIR}/scripts/install.sh" "${BASELINE_DIR}/airootfs/root/"

    # Ensure script is executable
    sudo chmod +x "${BASELINE_DIR}/airootfs/root/install.sh"

    # Enable autologin in syslinux-linux.cfg (only if not present)
    if ! grep -q "systemd.autologin=root" "${BASELINE_DIR}/syslinux/syslinux-linux.cfg"; then
        sudo sed -i '/APPEND/ s/$/ systemd.autologin=root/' "${BASELINE_DIR}/syslinux/syslinux-linux.cfg"
    fi

    # Ensure NetworkManager starts on boot
    sudo mkdir -p "${BASELINE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants"
    sudo ln -sf /usr/lib/systemd/system/NetworkManager.service "${BASELINE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"

    # Enable autologin via getty for tty1
    sudo mkdir -p "${BASELINE_DIR}/airootfs/etc/systemd/system/getty@tty1.service.d"
    echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM" | sudo tee "${BASELINE_DIR}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf"

    # Add install script to /etc/profile if not present
    if ! grep -q "bash /root/install.sh" "${BASELINE_DIR}/airootfs/etc/profile"; then
        echo -e "\n# Run installation script\nbash /root/install.sh" | sudo tee -a "${BASELINE_DIR}/airootfs/etc/profile"
    fi

    # Build the ISO
    sudo mkarchiso -v -w "${TEMP_DIR}" -o "${OUT_DIR}" "${BASELINE_DIR}"
}

init
