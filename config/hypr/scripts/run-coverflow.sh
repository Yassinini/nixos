#!/usr/bin/env bash
nix-shell -p "python3.withPackages (ps: [ ps.pyside6 ])" --run "python3 $HOME/.config/hypr/scripts/CoverflowPicker.py"
