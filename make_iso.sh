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
BASELINE_DIR="${WORK_DIR}/baseline"
OUT_DIR="${WORK_DIR}/out_dir"
TEMP_DIR="${WORK_DIR}/temp_dir"

# Remove temps folders
sudo rm -rf "$OUT_DIR/*"
sudo rm -rf "$TEMP_DIR/*"


# Add archinstall to packages
echo "archinstall" | sudo tee -a "$BASELINE_DIR/packages.x86_64"
echo "base" | sudo tee -a "$BASELINE_DIR/packages.x86_64"

# Copy config and script to ISO root
sudo cp "$CONFIG_DIR/minimal-install.json" "$BASELINE_DIR/airootfs/root/"
sudo cp "$WORK_DIR/scripts/install.sh" "$BASELINE_DIR/airootfs/root/"

# Ensure script is executable
sudo chmod +x "$BASELINE_DIR/airootfs/root/install.sh"

# Modify /etc/profile to run install.sh on boot
echo -e "\n# Run installation script\neval /root/install.sh" | sudo tee -a "$BASELINE_DIR/airootfs/etc/profile"

# Build the ISO
sudo mkarchiso -v -w "$TEMP_DIR" -o "$OUT_DIR" "$BASELINE_DIR"
