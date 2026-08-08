#!/usr/bin/env bash
# restore.sh
# Quick non-Nix restore: symlinks .config/ and local-bin/ into place.
# Only needed if testing dotfiles on a non-NixOS box without home-manager.
# On the actual NixOS machine, `sudo nixos-rebuild switch --flake ~/nixos#nixos`
# (aliased as `rebuild`) handles all of this automatically via mkOutOfStoreSymlink.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$REPO/.config"
BIN="$REPO/local-bin"

mkdir -p "$HOME/.config" "$HOME/.local/bin"

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%s)"
    echo "  (backed up existing $dest)"
  fi
  ln -sfn "$src" "$dest"
  echo "✓ linked $dest -> $src"
}

for d in tmux fastfetch waybar rofi wofi kitty matugen spicetify \
         swaync spotify-player glava nvim btop sptlrx waypaper; do
  [ -d "$CFG/$d" ] && link "$CFG/$d" "$HOME/.config/$d"
done

for f in yurrr yeup; do
  [ -f "$BIN/$f" ] && link "$BIN/$f" "$HOME/.local/bin/$f"
done

echo "Done. Restart shell / re-login to Hyprland to pick up changes."
