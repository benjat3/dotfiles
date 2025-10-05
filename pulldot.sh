#!/usr/bin/env bash
# pulldot.sh - descarga la última configuración desde GitHub y la instala

set -euo pipefail

DOTDIR=~/dotfiles

echo "=== Actualizando dotfiles desde GitHub ==="
cd $DOTDIR
git pull

echo "=== Copiando configs al sistema ==="
cp $DOTDIR/.bashrc ~/
rsync -av --exclude='.git' "$DOTDIR/nvim/" ~/.config/nvim/
cp $DOTDIR/.gitconfig ~/ || true

source ~/.bashrc

echo "✅ Configuración sincronizada con éxito"

