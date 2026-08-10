# Edit this configuration1 file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, hyprglass, ... }:

let
  
spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Imports & System Settings
  imports = [
    ./hardware-configuration.nix  # <-- MOVED HERE
  ];

  environment.shellAliases = {
    lock = "loginctl lock-session";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 20;
  };

  #. Global Home Manager Settings
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hyprglass; };

    #  User & Spicetify Configuration
    
users.suupatruupa = { pkgs, ... }: {
      imports = [
        # Spicetify HM module
        inputs.spicetify-nix.homeManagerModules.default

        # Separated Spicetify Config
        ({ ... }: {
          programs.spicetify = {
            enable = true;

            theme = {
              name = "vesper";
              src = pkgs.fetchFromGitHub {
                owner = "bdsqqq";
                repo = "spicetify-vesper-theme";
                rev = "main";
                hash = "sha256-BygDAh8AKb6J08pM/v5YNA04vSiEpC3USHmCjWHxaEc=";
              };
              injectCss = true;
              replaceColors = true;
              overwriteAssets = true;
            };

            enabledCustomApps = with spicePkgs.apps; [
              marketplace
              newReleases
            ] ++ [
              # Added spicetify-visualizer custom app
              {
               name = "visualizer.js";
    src = pkgs.fetchFromGitHub {
      owner = "Konsl";
      repo = "spicetify-visualizer";
      rev = "dist";
      hash = "sha256-9mdORE+9MKLGyQYQ2P3So8n3IiRilzA1t11Mav/0JJI=";
                };
              }
            ];
          };
        })
      ];
    };
  };

programs.fish.enable = true;

users.users.finley = {
  isNormalUser = true;
  shell = pkgs.fish;
  group = "finley";
  extraGroups = [ "wheel" "networkmanager" "video" "audio" ];  # adjust as needed
};

users.groups.finley = {};




services.logind.settings.Login.HandleLidSwitch = "ignore";
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;


services.gnome.gnome-keyring.enable = true;
security.pam.services.login.enableGnomeKeyring = true;
# Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
boot.loader.grub.useOSProber = true;  
boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# terminal
programs.starship.enable = true;

  # Permanent fix for backlight not turning on after boot.
  boot.kernelParams = [ "acpi_backlight=video" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

# Enable the GNOME Desktop Environment (kept so you can switch back anytime).
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd start-hyprland";
      user = "greeter";
    };
  };
};
systemd.services.greetd.serviceConfig = {
  Type = "idle";
  StandardInput = "tty";
  StandardOutput = "tty";
  StandardError = "journal";
  TTYReset = true;
  TTYVHangup = true;
  TTYVTDisallocate = true;
};


  # Enable Hyprland (Wayland compositor) - shows up as a session option at login.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # lets normal X11 apps still run inside Hyprland
  };

  # Needed for portals (screen share, file pickers, etc) under Hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };



  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users."suupatruupa" = {
    isNormalUser = true;
    description = "suupatruupa";
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
  # Enable brightness control backend daemon
environment.systemPackages = with pkgs; [
# Hyprland ecosystem essentials
git
kitty
wofi            # App launcher
libnotify       # Provides notify-send
hyprpaper
brightnessctl
networkmanagerapplet
wl-clipboard
swappy          # Screenshot annotation
ddcutil
lm_sensors
libqalculate
fish
vscode
spotify
discord
alacritty
playerctl
grim
slurp
fastfetch
btop
cava
peaclock
stdenv.cc.cc.lib
obsidian
steam
cmake meson cpio gcc pkg-config
gnumake
hyprglass
prismlauncher
waypaper
lavat
nyancat
asciiquarium
cmatrix
mapscii
python3Packages.euporie
xorg.libxcb
localsend
pkgs.mpvpaper
pkgs.neovim

(python3.withPackages (ps: with ps; [
pynvim
jupyter-client    # was jupyter_client
ipykernel
cairosvg
pnglatex
requests
plotly
]))
inputs.quickshell.packages.${pkgs.system}.default
papirus-icon-theme
nerd-fonts.jetbrains-mono
material-design-icons
qt6.qtsvg
qt6.qtimageformats
nerd-fonts.symbols-only
material-design-icons
gcalcli
inotify-tools
sptlrx    
wallust
glava
pkgs.tuigreet   
waybar
bluez
brightnessctl
fzf
networkmanager
pulseaudio
commit-mono
matugen
ani-cli
pkgs.hyprlock
gpu-screen-recorder
yazi
discordo
lynx
croc
spotify-player
spotatui
w3m
astroterm    
appimage-run
pkgs.bun
gum
davinci-resolve
dysk
atuin
superfile
zoxide
github-cli
pwvucontrol


#myappshere
];

virtualisation.oci-containers.containers.waha = {
  image = "devlikeapro/waha";
  ports = [ "3000:3000" ];
  autoStart = true;
};

programs.gpu-screen-recorder.enable = true;

programs.tmux = {
  enable = true;
   clock24 = true;
   keyMode = "vi";
};


programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
};

# Enable Bluetooth support hardware and wireless service
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # Automatically power up the controller on boot
  
  # Enable Bluetooth device management tool service
  services.blueman.enable = true;

services.flatpak.enable = true;
  system.stateVersion = "26.05"; # Did you read the comment?
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
};
services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    dynamicBoost.enable = true;  
};
systemd.services.nvidia-max-power = {
  description = "Set NVIDIA GPU Power Limit to 85W";
  wantedBy = [ "multi-user.target" ];
  after = [ "nvidia-persistenced.service" ];
  path = [ config.boot.kernelPackages.nvidiaPackages.production.bin ];
  script = "nvidia-smi -pl 85";
  serviceConfig = {
    Type = "oneshot";
  };
};
  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-hibernate.enable = true;
  systemd.services.nvidia-resume.enable = true;
boot.initrd.kernelModules = [ "nvidia" ];
environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
      LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
  };


boot.loader.grub.theme = "${pkgs.fetchFromGitHub {
  owner = "harishnkr";
  repo = "bsol";
  rev = "master";
  sha256 = "1nhazccsp71lxjyw15lns2gpch182j66d54qw8spzlniv5yk4gvj";
}}/bsol";


systemd.services.nvidia-power-limit = {
  description = "Set NVIDIA Power Limit to Maximum";
  after = [ "display-manager.service" ];
  wantedBy = [ "multi-user.target" ];
  path = with pkgs; [
    coreutils
    gnugrep
    gawk
    config.hardware.nvidia.package.bin
  ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = pkgs.writeShellScript "nvidia-power-caps" ''
      # $(NF-1) = the numeric value, since the line always ends in "<value> W"
      MAX_PWR=$(nvidia-smi -q -d POWER | grep "Max Power Limit" | awk '{print $(NF-1)}')
      if [ -n "$MAX_PWR" ]; then
        nvidia-smi -pl "$MAX_PWR"
      else
        echo "Could not detect Max Power Limit"
        exit 1
      fi
    '';
  };
};

programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libGL
      libxkbcommon
      libx11
      libxcursor
      libxrandr
      libxi
      libxxf86vm
      libxrender
      libxext
      libxfixes
      libxinerama
      libSM
      libICE
      fontconfig
      freetype
      libxkbfile
    ];
  };

fonts.fontconfig.defaultFonts = {
    serif = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "JetBrainsMono Nerd Font" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

}
