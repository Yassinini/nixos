# NixOS Configuration

Welcome to my personal NixOS configuration repository. This setup is optimized for productivity, performance, and aesthetics, featuring a custom Hyprland workflow and a tailored terminal environment.

##  Feat.

* **OS:** [NixOS](https://nixos.org/) (Unstable)
* **Window Manager:** [Hyprland](https://hyprland.org/)
* **Terminal Stack:** Kitty, Fish, tmux, Starship
* **Dynamic Color Management:** Integrated [Matugen](https://github.com/InioX/matugen)
* **Workflow Tools:** Obsidian & VsCode & Terminal apps

##  File Structure

```text
.
├── .config/                    --> User application configurations
├── dotfiles/                   --> Modular desktop & system dotfiles
├── local-bin/                  --> Local user executable binaries
├── scripts/                    --> Custom utility scripts
├── configuration.nix           --> System-wide NixOS configuration
├── flake.nix                   --> Flake entrypoint
├── flake.lock                  --> Dependency lockfile
├── hardware-configuration.nix  --> Auto-generated hardware layout
└── home.nix                    --> Home Manager profile configuration
```

## Installation

### Prerequisites

1. Nix installed with Flakes enabled.
2. Home Manager configured for user-space packages.

### Installation

Clone the repository and apply the configuration:

```bash
# Clone the repository
git clone [https://github.com/Yassinini/nixos.git](https://github.com/Yassinini/nixos.git)
cd nixos

# Rebuild and switch (replace <hostname> with your target profile)
sudo nixos-rebuild switch --flake .#<hostname>
```

## Keybinds

### Applications

    Super + Q — Terminal (Kitty)

    Super + B — Zen Browser

    Super + I — Obsidian

    Super + O — Spotify

### Window Management

    Super + C — Close active window

    Super + V — Toggle full screen

    Super + Shift + [Arrow] — Move window position

    Alt + Tab — Cycle window focus

### Workspaces

    Super + [0–9] — Switch active workspace

### System 

    Super + L — Lock screen

    Super + Shift + W — Wallpaper switcher
---
*Built on NixOS. By suupa*
