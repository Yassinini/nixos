{
  description = "NixOS Flake Configuration";

  inputs = {
     nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";

     home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };

     shiki-src = {
       url = "github:sazardev/shiki";
       flake = false;
     };

     quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

spicetify-nix = {
  url = "git+https://github.com/Gerg-L/spicetify-nix.git";
  inputs.nixpkgs.follows = "nixpkgs";
};
  };

  outputs = { self, nixpkgs, home-manager, quickshell, spicetify-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      ##########################################################
      # Custom Derivations
      ##########################################################


      # hyprglass — Hyprland plugin, built from main branch for
      # modern Hyprland compatibility
      hyprglass = pkgs.stdenv.mkDerivation {
        pname = "hyprglass";
        version = "unstable-2026-08";
        src = pkgs.fetchFromGitHub {
          owner = "hyprnux";
          repo = "hyprglass";
          rev = "main";
          hash = "sha256-x/584kY+XXlU/OWKtZAFo89VtowjLXs1DiP9PC0o0Os=";
        };

        nativeBuildInputs = with pkgs; [ pkg-config cpio gcc gnumake ];
        dontUseCmakeConfigure = true;
        dontUseMesonConfigure = true;
        configurePhase = "true";
        buildInputs = with pkgs; [
          hyprland
          hyprlang
          hyprutils
          hyprcursor
          hyprgraphics
          aquamarine
          wayland
          wayland-protocols
          cairo
          libxkbcommon
          libinput
          libdrm
          pixman
          libglvnd
          libGL
          mesa
          libxcb-wm
          libxcb-util
          libxcb-render-util
          libxcb-errors
          libxcb
          glslang
          lua5_4
          openssl
        ];
        OPENSSL_NO_VENDOR = 1;
        buildPhase = ''
          make
        '';
        installPhase = ''
          mkdir -p $out/lib
          cp hyprglass.so $out/lib/
        '';
      };

      # shiki-cli — TUI note-taking app, git-native notebooks
      shiki-cli = pkgs.rustPlatform.buildRustPackage {
        pname = "shiki-cli";
        version = "unstable-2026-08-08";
        src = inputs.shiki-src;
        cargoHash = "sha256-1A4x/1cqpXR35bU2X6WpwPNt0uj9TSgQ3JJPZDBQPtw=";
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [ openssl ];
        OPENSSL_NO_VENDOR = 1;
        meta = with pkgs.lib; {
          description = "TUI note-taking app in Rust, git-native notebooks";
          homepage = "https://github.com/sazardev/shiki";
          license = licenses.mit;
          mainProgram = "shiki";
        };
      };

      # retrosmart-cursors — X11 cursor theme
      retrosmart-cursors = pkgs.stdenv.mkDerivation rec {
        pname = "retrosmart-x11-cursors";
        version = "unstable-2025-01-13";
        src = pkgs.fetchFromGitHub {
          owner = "mdomlop";
          repo = "retrosmart-x11-cursors";
          rev = "master";
          sha256 = "sha256-smsC02aDdOWlNfk+1/lVwH41qDCpPDxePDbrmou8M/4=";
        };
        nativeBuildInputs = with pkgs; [ imagemagick xcursorgen ];
        installFlags = [ "DESTDIR=${placeholder "out"}" "PREFIX=" ];
        meta = with pkgs.lib; {
          description = "Old-fashioned X11 cursor theme inspired by Windows 3.x and OS X";
          homepage = "https://github.com/mdomlop/retrosmart-x11-cursors";
          license = licenses.gpl3Only;
          platforms = platforms.linux;
        };
      };
    in
    {
          nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs hyprglass shiki-cli retrosmart-cursors; };
  modules = [
    { nixpkgs.hostPlatform = system; } # Modern replacement
    ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs hyprglass shiki-cli retrosmart-cursors; };
            home-manager.users.suupatruupa = import ./home.nix;
          }
        ];
      };
    };
}
