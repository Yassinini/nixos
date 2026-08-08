{ config, pkgs, inputs, hyprglass,  ... }:

{
  home.username = "suupatruupa";
  home.homeDirectory = "/home/suupatruupa";
  home.stateVersion = "26.05";

  home.pointerCursor = {
  gtk.enable = true;
  package = pkgs.bibata-cursors;
  name = "Bibata-Modern-Classic";
  size = 24;
};

home.packages = with pkgs; [
    rofi
    gtk4
    gtk4-layer-shell
    (python3.withPackages (ps: with ps; [
      pygobject3
      pycairo
      google-auth
      google-auth-oauthlib
      google-api-python-client
    ]))
    wallust
    jq
    swaynotificationcenter
    brightnessctl
    networkmanagerapplet
    nwg-look
    gtk4-layer-shell
    gum  
];
# apps="discordo spotatui yazi btop lavat cmatrix asciiquarium nyancat nvim "


  # Pull in Caelestia's home-manager module
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];


  programs.caelestia = {
    enable = true;
    cli.enable = true; # adds the `caelestia` command to your PATH
  };

   programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

# ZOXIDE
programs.zoxide = {
  enable = true;
  enableBashIntegration = true; # Set to true for your preferred shell
  enableZshIntegration = true;
  enableFishIntegration = true;
};
  # Minimal Hyprland config to auto-start Caelestia on login.
  # You can replace/expand this later with the full caelestia-dots hyprland.conf.
wayland.windowManager.hyprland.plugins = [
  hyprglass
];
  
wayland.windowManager.hyprland.settings = {
  exec-once = [
    "caelestia shell -d"
    "hyprpaper --wait -c /home/suupatruupa/.config/hypr/hyprpaper.conf"
  ];

  env = [
    "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
    "LIBVA_DRIVER_NAME,nvidia"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    "WLR_NO_HARDWARE_CURSORS,1"
    "NIXOS_OZONE_WL,1"
    "__EGL_VENDOR_LIBRARY_FILENAMES,/run/opengl-driver/share/glvnd/egl_vendor.d/50_nvidia.json"
    "OGL_FORCE_SOFTWARE,0"
    "QT_QPA_PLATFORM,wayland;xcb"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
  ];

  bind = [
    "SUPER, Q, exec, kitty"
    "SUPER, C, killactive"
    "SUPER, M, exit"
    "SUPER, Super_L, exec, caelestia shell -d"
    "SUPER SHIFT, K, exec, /home/suupatruupa/.config/hypr/scripts/wallpaper_picker.sh"
  ];
};


# Register the script file
# 1. The configuration file to initialize hyprpaper on startup
# Configuration file to initialize hyprpaper on startup
  home.file.".config/hypr/hyprpaper.conf" = {
    text = ''
      preload = /home/suupatruupa/Pictures/Wallpapers/wallhaven-1qr6mg.png
      wallpaper = eDP-1,/home/suupatruupa/Pictures/Wallpapers/wallhaven-1qr6mg.png
      splash = false
    '';
  };

  # The script to switch wallpapers dynamically
home.file.".config/hypr/scripts/wallpaper_picker.sh" = {
  text = ''
    #!/usr/bin/env bash
    DIR="/home/suupatruupa/Pictures/Wallpapers"
    WOFI="/run/current-system/sw/bin/wofi"
    NOTIFY="/run/current-system/sw/bin/notify-send"

    SELECTION=$(ls "$DIR" | $WOFI --show dmenu -p "Select Wallpaper" \
        --style ~/.config/wofi/style.css \
        --width 800 \
        --height 200 \
        --columns 6)

    if [ -n "$SELECTION" ]; then
        IMAGE="$DIR/$SELECTION"
        if [ -f "$IMAGE" ]; then
            hyprctl hyprpaper unload all
            hyprctl hyprpaper preload "$IMAGE"
            hyprctl hyprpaper wallpaper "eDP-1,$IMAGE"
            $NOTIFY "Wallpaper" "Applied: $SELECTION"
        fi
    fi
  '';
  executable = true;
};



gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

qt = {
  enable = true;
  style.name = "adwaita-dark";
};

home.sessionVariables = {
  GTK_THEME = "Adwaita:dark";
  QT_STYLE_OVERRIDE = "adwaita-dark";
  GI_TYPELIB_PATH = "${pkgs.gtk4}/lib/girepository-1.0:${pkgs.gtk4-layer-shell}/lib/girepository-1.0";
};

programs.fish = {
  enable = true;

  interactiveShellInit = ''
    set -gx GI_TYPELIB_PATH "${pkgs.gtk4}/lib/girepository-1.0:${pkgs.gtk4-layer-shell}/lib/girepository-1.0"

    set fish_greeting

    # Keep the Hyprland instance signature up to date.
    if command -sq hyprctl
        set -l inst (hyprctl instances 2>/dev/null | awk '/^instance / {print $2}' | string trim -r -c :)
        if test -n "$inst"
            set -gx HYPRLAND_INSTANCE_SIGNATURE $inst
        end
    end

    if status is-interactive; and not set -q TMUX
        fish -c '
            ~/.local/bin/caelestia-to-alacritty.py
            while true
                inotifywait -e modify -e create -e moved_to -q ~/.local/state/caelestia/ | grep -q scheme.json
                and ~/.local/bin/caelestia-to-alacritty.py
                and touch ~/.config/alacritty/alacritty.toml
            end
        ' &
        disown
    end

    if status is-interactive; and not set -q TMUX
        exec tmux new-session
    end

    if status is-interactive
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"

        if test -f "$HOME/.cache/wal/sequences"
            cat "$HOME/.cache/wal/sequences" &
        end

        starship init fish | source
        fastfetch
    end
  '';
};


home.shellAliases = {
  steam = "WAYLAND_DISPLAY= SDL_VIDEODRIVER=x11 steam";
  fih = "asciiquarium";
  scr  = "gpu-screen-recorder -w screen -f 60 -a \"default_output\" -o ~/Videos/Recordings/recording_\$(date +%Y-%m-%d_%H-%M-%S).mp4";
    scrH = "gpu-screen-recorder -w screen -f 60 -a \"default_output\" -q very_high -o ~/Videos/Recordings/recording_\$(date +%Y-%m-%d_%H-%M-%S).mp4";
  yup = "~/.local/bin/yeup";
};

programs.bash = {
  enable = true;
};
xdg.desktopEntries.steam = {
  name = "Steam";
  exec = "env WAYLAND_DISPLAY= SDL_VIDEODRIVER=x11 steam %U";
  icon = "steam";
  type = "Application";
  categories = [ "Game" "Network" ];
  terminal = false;
};



home.file.".local/bin/yurrr".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/local-bin/yurrr";
  home.file.".local/bin/yeup".source  = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/local-bin/yeup";

  xdg.configFile = {
    "tmux".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/tmux";
    "fastfetch".source      = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/fastfetch";
    "waybar".source         = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/waybar";
    "rofi".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/rofi";
    "wofi".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/wofi";
    "kitty".source          = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/kitty";
    "matugen".source        = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/matugen";
    "spicetify".source      = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/spicetify";
    "swaync".source         = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/swaync";
    "spotify-player".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/spotify-player";
   "glava".source    = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/glava";
    "nvim".source     = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/nvim";
    "btop".source     = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/btop";
    "sptlrx".source   = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/sptlrx";
    "waypaper".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/nixos/config/waypaper";
  };
}
