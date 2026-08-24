{ config, pkgs, inputs, hyprglass, shiki-cli, retrosmart-cursors, gamemaker-fhs,  ... }:

{
  ############################################################
  # Core Home Manager Identity
  ############################################################
  home.username = "suupatruupa";
  home.homeDirectory = "/home/suupatruupa";
  home.stateVersion = "26.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  ############################################################
  # Cursor Theme
  ############################################################
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = retrosmart-cursors;
    name = "retrosmart-xcursor-black";
    size = 34;
  };

  ############################################################
  # GTK / QT / Dark Mode Theming
  ############################################################
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };

  # Force dark preference across Freedesktop portals (XDG Desktop Portal)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    GI_TYPELIB_PATH = "${pkgs.gtk4}/lib/girepository-1.0:${pkgs.gtk4-layer-shell}/lib/girepository-1.0:${pkgs.libadwaita}/lib/girepository-1.0";
  };

  ############################################################
  # Packages
  ############################################################
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
    jq
    swaynotificationcenter
    brightnessctl
    networkmanagerapplet
    nwg-look
    gum
    shiki-cli
  pkgs.nvtopPackages.nvidia  

    # suupathing — quick-launch script for a few TUI apps in kitty
    (writeShellScriptBin "suupa" ''
      setsid -f kitty -e spotatui >/dev/null 2>&1
      setsid -f kitty -e lavat >/dev/null 2>&1
      setsid -f kitty -e discordo >/dev/null 2>&1
    '')

gamemaker-fhs
unzip
appimage-run
linuxdeploy

];
programs.btop = {
  enable = true;
};

  ############################################################
  # Shell Integrations
  ############################################################
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.bash.enable = true;

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      cd ~/.nixos
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
          exec tmux new-session
      end

      if status is-interactive
          set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
          starship init fish | source
          fastfetch
      end
    '';

    functions = {
      com = ''
        set -l msg $argv
        if test -z "$msg"
          set msg "update"
        end
        cd ~/.nixos
        git add -A
        git commit -m "$msg"
        git push
      '';

      sync = ''
        bash ~/.nixos/scripts/collect-dotfiles.sh
        sudo nixos-rebuild switch --flake ~/.nixos#nixos
        cd ~/.nixos
        git add -A
        git commit -m "sync $(date '+%Y-%m-%d %H:%M')"
        git push
      '';
    };
  };

programs.fzf = {
  enable = true;
  enableFishIntegration = true;
};

  home.shellAliases = {
    steam = "WAYLAND_DISPLAY= SDL_VIDEODRIVER=x11 steam";
    fih = "asciiquarium";
    scr = "gpu-screen-recorder -w screen -f 60 -a \"default_output\" -o ~/Videos/Recordings/recording_\$(date +%Y-%m-%d_%H-%M-%S).mp4";
    scrH = "gpu-screen-recorder -w screen -f 60 -a \"default_output\" -q very_high -o ~/Videos/Recordings/recording_\$(date +%Y-%m-%d_%H-%M-%S).mp4";
    yup = "~/.local/bin/yeup";
    rebuild = "sudo nixos-rebuild switch --flake ~/.nixos#nixos";
    bk = "cd ~/.nixos";
    hyprset = "nix-shell -p python312 python312Packages.pygobject3 gtk4 libadwaita gobject-introspection cairo pkg-config uv lua5_4 glib --run 'export XDG_DATA_DIRS=\"$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS\"; hyprmod'";
};

programs.fish.functions = {
  gamemaker = ''
    setsid gamemaker-fhs -c 'DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 exec ~/Apps/GameMaker/opt/GameMaker-LTS2026/GameMaker' > /dev/null 2>&1 &
    disown
  '';
};

  ############################################################
  # Hyprlock — screen lock
  ############################################################
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
        no_fade_out = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      label = [
        {
          text = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
          font_size = 90;
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:1000] echo \"$(date +'%A, %B %d')\"";
          font_size = 24;
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          outer_color = "rgba(255, 255, 255, 0.3)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgba(255, 255, 255, 0.9)";
          fade_on_empty = false;
          placeholder_text = "Password...";
        }
      ];
    };
  };

  ############################################################
  # Hyprland
  ############################################################
  wayland.windowManager.hyprland.plugins = [
    hyprglass
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
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
      "SUPER, L, exec, hyprlock"
      "SUPER SHIFT, K, exec, /home/suupatruupa/.config/hypr/scripts/wallpaper_picker.sh"
    ];
  };

  # hyprpaper: preload/apply wallpaper on startup
  home.file.".config/hypr/hyprpaper.conf" = {
    text = ''
      preload = /home/suupatruupa/Pictures/Wallpapers/wallhaven-1qr6mg.png
      wallpaper = eDP-1,/home/suupatruupa/Pictures/Wallpapers/wallhaven-1qr6mg.png
      splash = false
    '';
  };

  # Wallpaper picker script (wofi-based dynamic switcher)
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

  ############################################################
  # Desktop Entries
  ############################################################
  xdg.desktopEntries.steam = {
    name = "Steam";
    exec = "env WAYLAND_DISPLAY= SDL_VIDEODRIVER=x11 steam %U";
    icon = "steam";
    type = "Application";
    categories = [ "Game" "Network" ];
    terminal = false;
  };

  ############################################################
  # Local Scripts (live-editable symlinks)
  ############################################################
  home.file.".local/bin/yurrr".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/local-bin/yurrr";
  home.file.".local/bin/yeup".source  = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/local-bin/yeup";
home.file.".local/bin/yayyy".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/local-bin/yayyy";
  ############################################################
  # Dotfiles (live-editable symlinks)
  ############################################################
  xdg.configFile = {
    "tmux".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/tmux";
    "fastfetch".source      = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/fastfetch";
    "waybar".source         = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/waybar";
    "rofi".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/rofi";
    "wofi".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/wofi";
    "kitty".source          = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/kitty";
    "matugen".source        = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/matugen";
    "spicetify".source      = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/spicetify";
    "swaync".source         = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/swaync";
    "spotify-player".source = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/spotify-player";
    "glava".source          = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/glava";
    "nvim".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/nvim";
    "btop".source           = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/btop";
    "sptlrx".source         = config.lib.file.mkOutOfStoreSymlink "/home/suupatruupa/.nixos/.config/sptlrx";
  };
}
