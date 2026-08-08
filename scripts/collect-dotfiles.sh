#!/usr/bin/env bash
# collect-dotfiles.sh
# Run this ON your Legion5, from anywhere. It copies your live configs
# into a git repo structure ready to commit and push.
set -euo pipefail

REPO="$HOME/nixos"          # where you cloned/created Yassinini/nixos
CFG="$REPO/config"
BIN="$REPO/local-bin"
HOSTS="$REPO/hosts/legion5"

mkdir -p "$CFG" "$BIN" "$HOSTS" "$REPO/home"

copy_dir() {
  local src="$1" dest="$2"
  if [ -e "$src" ]; then
    set +e
    rsync -a --delete \
      --exclude 'cache' --exclude '*.log' --exclude '.git' \
      "$src"/ "$dest"/
    local rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
      echo "✓ $src -> $dest"
    elif [ "$rc" -eq 23 ] || [ "$rc" -eq 24 ]; then
      echo "⚠ $src -> $dest (copied, but some files skipped — permission denied or vanished, usually safe to ignore)"
    else
      echo "✗ $src -> $dest FAILED (rsync exit $rc)"
    fi
  else
    echo "⚠ skipped (not found): $src"
  fi
}

copy_file() {
  local src="$1" dest="$2"
  if [ -e "$src" ]; then
    cp "$src" "$dest"
    echo "✓ $src -> $dest"
  else
    echo "⚠ skipped (not found): $src"
  fi
}

# --- System-level nix files ---
copy_file /etc/nixos/configuration.nix "$HOSTS/configuration.nix"
copy_file /etc/nixos/hardware-configuration.nix "$HOSTS/hardware-configuration.nix"

# --- Auto-locate flake.nix / home.nix instead of hardcoding a path ---
# (searches common spots first, falls back to a filesystem search)
find_first() {
  local name="$1"; shift
  local candidates=("$@")
  for c in "${candidates[@]}"; do
    [ -f "$c" ] && { echo "$c"; return 0; }
  done
  # fallback: search /etc/nixos and $HOME, skip the repo itself and /nix/store
  find /etc/nixos "$HOME" -maxdepth 4 -name "$name" \
    -not -path "$REPO/*" -not -path "*/nix/store/*" 2>/dev/null | head -n1
}

FLAKE_NIX=$(find_first flake.nix /etc/nixos/flake.nix "$HOME/nixos-src/flake.nix" "$HOME/.config/nixos/flake.nix")
FLAKE_LOCK=$(find_first flake.lock /etc/nixos/flake.lock "$HOME/nixos-src/flake.lock" "$HOME/.config/nixos/flake.lock")
HOME_NIX=$(find_first home.nix "$HOME/nixos-src/home.nix" "$HOME/.config/home-manager/home.nix")

[ -n "${FLAKE_NIX:-}" ]  && copy_file "$FLAKE_NIX"  "$REPO/flake.nix"  || echo "⚠ flake.nix not found — copy it manually"
[ -n "${FLAKE_LOCK:-}" ] && copy_file "$FLAKE_LOCK" "$REPO/flake.lock" || echo "⚠ flake.lock not found — copy it manually"
[ -n "${HOME_NIX:-}" ]   && copy_file "$HOME_NIX"   "$REPO/home/home.nix" || echo "⚠ home.nix not found — copy it manually"

# --- .config dirs ---
copy_dir "$HOME/.config/fish"       "$CFG/fish"
copy_dir "$HOME/.config/tmux"       "$CFG/tmux"
copy_dir "$HOME/.config/fastfetch"  "$CFG/fastfetch"
copy_dir "$HOME/.config/hypr"       "$CFG/hypr"
copy_dir "$HOME/.config/waybar"     "$CFG/waybar"
copy_dir "$HOME/.config/rofi"       "$CFG/rofi"
copy_dir "$HOME/.config/wofi"       "$CFG/wofi"
copy_dir "$HOME/.config/kitty"      "$CFG/kitty"
copy_dir "$HOME/.config/matugen"    "$CFG/matugen"
copy_dir "$HOME/.config/spicetify"  "$CFG/spicetify"
copy_dir "$HOME/.config/hyprlock"   "$CFG/hyprlock"
copy_dir "$HOME/.config/swaync"     "$CFG/swaync"
copy_dir "$HOME/.config/spotify-player" "$CFG/spotify-player"

# --- local bin scripts ---
copy_file "$HOME/.local/bin/yurrr" "$BIN/yurrr"
copy_file "$HOME/.local/bin/yeup"  "$BIN/yeup"
chmod +x "$BIN"/* 2>/dev/null || true

echo
echo "Done. Review changes with: cd $REPO && git status"
echo "Then: git add -A && git commit -m 'sync dotfiles' && git push"
