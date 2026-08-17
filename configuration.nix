# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, hyprglass, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  ############################################################
  # Imports & Core System Settings
  ############################################################
  imports = [
    ./hardware-configuration.nix
  ];

  documentation.man.man-db.enable = false;

  nixpkgs.overlays = [
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = pyFinal: pyPrev: {
          flatlatex = pyPrev.flatlatex.overridePythonAttrs (old: {
            disabled = false;
            doCheck = false;
          });
        };
      };
      python3Packages = final.python3.pkgs;
    })
  ];

nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
 nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  flake-registry = "";
};

  environment.shellAliases = {
    lock = "loginctl lock-session";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 20;
  };

  ############################################################
  # Home Manager (Spicetify + Hakuspace Dotfiles)
  ############################################################
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs hyprglass; };

    users.suupatruupa = { pkgs, ... }: {
      imports = [
        # Spicetify HM module
        inputs.spicetify-nix.homeManagerModules.default

        # Spicetify Config
        ({ ... }: {
          programs.spicetify = {
            enable = true;
            theme = spicePkgs.themes.text;
            enabledCustomApps = with spicePkgs.apps; [
              marketplace
              newReleases
            ] ++ [
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

      # hakuspace Dotfiles & Scripts Imports via Home Manager
      xdg.configFile = {
        "rofi".source = pkgs.lib.mkForce ./dotfiles/rofi;
        "swaync".source = pkgs.lib.mkForce ./dotfiles/swaync;
        "cava".source = pkgs.lib.mkForce ./dotfiles/cava;
        "hakuspace".source = pkgs.lib.mkForce ./dotfiles/hakuspace;
        "waybar".source = pkgs.lib.mkForce ./dotfiles/waybar;
      };
    };
  };

  ############################################################
  # User Accounts
  ############################################################
  users.users."suupatruupa" = {
    isNormalUser = true;
    description = "suupatruupa";
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" ];
  };

  programs.fish.enable = true;

  ############################################################
  # Power & Session Management
  ############################################################
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  ############################################################
  # Bootloader
  ############################################################
boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 5; # Keeps only the last 5 generations in /boot
    theme = "${pkgs.fetchFromGitHub {
      owner = "harishnkr";
      repo = "bsol";
      rev = "master";
      sha256 = "1nhazccsp71lxjyw15lns2gpch182j66d54qw8spzlniv5yk4gvj";
    }}/bsol";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "acpi_backlight=video" ];
  boot.initrd.kernelModules = [ "nvidia" ];

  ############################################################
  # Networking & Regional Settings
  ############################################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Africa/Cairo";
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

  ############################################################
  # Display Manager, X11 & Hyprland
  ############################################################
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

xdg.portal = {
  enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-hyprland
  ];
  config = {
    common.default = [ "hyprland" "gtk" ];
    hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    };
  };
};

  ############################################################
  # Printing & Audio
  ############################################################
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################################
  # Bluetooth & Misc Hardware Services
  ############################################################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.flatpak.enable = true;

  ############################################################
  # Program Configurations
  ############################################################
  programs.firefox.enable = true;
  programs.starship.enable = true;
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

  ############################################################
  # System Packages
  ############################################################
  environment.systemPackages = with pkgs; [
    # Core Wayland & Hakuspace Infrastructure
    waybar
    rofi
    swaynotificationcenter
    awww
    cava
    playerctl
    brightnessctl
    pavucontrol
    wireplumber
    networkmanagerapplet
    xwayland-satellite

    # Screen Capture, Clipboard & Utilities
    grim
    slurp
    wl-clipboard
    cliphist
    swappy
    libnotify
    ddcutil
    lm_sensors
    libqalculate
    inotify-tools

    # Shell, Editors & Terminal Utilities
    git
    kitty
    alacritty
    fish
    vscode
    neovim
    fastfetch
    btop
    yazi
    superfile
    zoxide
    atuin
    fzf
    tmux
    gum
    dysk
    github-cli
    appimage-run
    bun

    # Media, Audio & Applications
    spotify
    discord
    discordo
    obsidian
    steam
    prismlauncher
    mpvpaper
    davinci-resolve
    localsend
    croc
    spotify-player
    spotatui
    sptlrx
    lynx
    w3m
    astroterm
    ani-cli

    # Rice / Aesthetic Toys
    peaclock
    lavat
    nyancat
    asciiquarium
    cmatrix
    mapscii
    glava
    tuigreet
    matugen

    # Development & Compilers
    cmake
    meson
    cpio
    gcc
    pkg-config
    gnumake
    stdenv.cc.cc.lib
    libxcb

    # Python Environment
    (python3.withPackages (ps: with ps; [
      pynvim
      jupyter-client
      ipykernel
      cairosvg
      pnglatex
      requests
      plotly
      euporie
    ]))

    # Inputs & External Flakes
    inputs.quickshell.packages.${pkgs.system}.default
    hyprglass

    # Fonts & Icons
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    material-design-icons
    commit-mono
    qt6.qtsvg
    qt6.qtimageformats

    bluetuith
    
fzf
# myappshere
  ];
programs.zoom-us.enable = true;

  ############################################################
  # Fonts
  ############################################################
  fonts.fontconfig.defaultFonts = {
    serif = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "JetBrainsMono Nerd Font" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  ############################################################
  # Containers
  ############################################################
  virtualisation.oci-containers.containers.waha = {
    image = "devlikeapro/waha";
    ports = [ "3000:3000" ];
    autoStart = true;
  };

  ############################################################
  # NVIDIA GPU
  ############################################################
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

  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-hibernate.enable = true;
  systemd.services.nvidia-resume.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  ############################################################
  # Nix-LD Binary Compatibility Layer
  ############################################################
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

  system.stateVersion = "26.05";
}
