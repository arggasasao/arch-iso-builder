#!/bin/bash
# Script to automate Arch Linux installation with minimal input
# Runs archinstall with a pre-configured JSON file
# sudo archinstall --config /root/user_configuration.json --creds /root/user_credentials.json --silent && sudo reboot
sudo archinstall --config /root/minimal-install.json
