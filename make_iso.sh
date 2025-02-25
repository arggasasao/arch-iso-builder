#!/bin/bash
clear

# Define Folers
WORK_DIR="/home/neo/arch-iso-builder"
CONFIG_DIR="${WORK_DIR}/config"
BASELINE_DIR="${WORK_DIR}/baseline"
OUT_DIR="${WORK_DIR}/out_dir"
TEMP_DIR="${WORK_DIR}/temp_dir"

# Remove temps folders
sudo rm -rf "$OUT_DIR" "$TEMP_DIR"

# Create folders
mkdir -p "$OUT_DIR" "$TEMP_DIR"

echo "============================================================================="
echo "|                      Arch Linux ISO Builder                               |"
echo "============================================================================="
echo ""

# Copy baseline profile
# cp -r /usr/share/archiso/configs/baseline/ ${WORK_DIR}

# Generate  ISO
sudo mkarchiso -v -w "$TEMP_DIR" -o "$OUT_DIR" "$BASELINE_DIR"

echo "¡Listo! La ISO personalizada se ha creado en ${OUT_DIR}"
