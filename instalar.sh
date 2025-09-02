#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget unzip zip tar git tree htop bat
sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y neovim
sudo apt install -y git
sudo apt install -y tree
sudo apt install -y htop
sudo apt install -y octave
sudo apt install -y openssh-server
#Python entorno y librerias
python3 -m venv ~/.venvs/ingenieria
source ~/.venvs/ingenieria/bin/activate
pip install jupyter numpy pandas matplotlib scipy
deactivate
