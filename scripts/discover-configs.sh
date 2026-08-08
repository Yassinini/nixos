#!/usr/bin/env bash
# discover-configs.sh
# Run this ON your Legion5. Lists everything in ~/.config and ~/.local/bin,
# flags what's already tracked in the nixos repo vs what's still missing.
set -uo pipefail

REPO="$HOME/nixos"
CFG_TRACKED="$REPO/config"

echo "=================================================="
echo " ~/.config directories (sorted by last-modified)"
echo "=================================================="
printf "%-30s %-12s %-10s %s\n" "DIR" "LAST MOD" "SIZE" "IN REPO?"
printf "%-30s %-12s %-10s %s\n" "---" "--------" "----" "--------"

for d in "$HOME/.config"/*/; do
  name=$(basename "$d")
  mod=$(stat -c '%y' "$d" 2>/dev/null | cut -d' ' -f1)
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  if [ -e "$CFG_TRACKED/$name" ]; then
    tracked="✓ yes"
  else
    tracked="✗ MISSING"
  fi
  printf "%-30s %-12s %-10s %s\n" "$name" "$mod" "$size" "$tracked"
done | sort

echo
echo "=================================================="
echo " ~/.local/bin scripts (yours, not package-provided)"
echo "=================================================="
if [ -d "$HOME/.local/bin" ]; then
  for f in "$HOME/.local/bin"/*; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if [ -e "$REPO/local-bin/$name" ]; then
      tracked="✓ yes"
    else
      tracked="✗ MISSING"
    fi
    mod=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    printf "%-30s %-12s %s\n" "$name" "$mod" "$tracked"
  done | sort
else
  echo "(no ~/.local/bin found)"
fi

echo
echo "=================================================="
echo " Currently running graphical/user processes"
echo " (helps identify what's actually 'in use' vs leftover config dirs)"
echo "=================================================="
ps -u "$USER" -o comm= | sort -u | grep -viE '^(bash|fish|zsh|sh|tmux|systemd|dbus-|pipewire|wireplumber|gvfs|xdg-|at-spi|kitty)$' | head -40

echo
echo "=================================================="
echo " Explicitly-installed packages (home-manager + system, best guess)"
echo " (cross-reference against config dirs above to see what's actually used)"
echo "=================================================="
if command -v nix-env >/dev/null 2>&1; then
  nix-env -q 2>/dev/null | head -60
fi
echo "(system packages are declared in configuration.nix / home.nix — check those directly for the full list)"
