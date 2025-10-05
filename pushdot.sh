#!/usr/bin/env bash
# pushdot.sh - sube tus configuraciones locales a GitHub

set -euo pipefail

DOTDIR=~/dotfiles

echo "=== Copiando configs actuales al repo ==="
cp ~/.bashrc $DOTDIR/
rsync -av --exclude='.git' ~/.config/nvim/ "$DOTDIR/nvim/"
cp ~/.gitconfig $DOTDIR/ || true

cd $DOTDIR

echo "=== Subiendo cambios a GitHub ==="
git add .
git commit -m "Sync dotfiles: $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nada nuevo para commitear"
git push

echo "✅ Dotfiles actualizados en GitHub"

