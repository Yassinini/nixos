{
  description = "NixOS Flake Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shiki-src = {
      url = "github:sazardev/shiki";
      flake = false;
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Added pixie-sddm input
    pixie-sddm = {
      url = "github:xCaptaiN09/pixie-sddm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, caelestia-shell, caelestia-cli, quickshell, spicetify-nix, pixie-sddm, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Custom hyprglass derivation
      hyprglass = pkgs.stdenv.mkDerivation {
        pname = "hyprglass";
        version = "0.6.2";
        src = pkgs.fetchFromGitHub {
          owner = "hyprnux";
          repo = "hyprglass";
          rev = "v0.6.2";
          sha256 = "sha256-6qa0PoeKfGSpXpILgp2yuYfRmrQKjDSQWpy8q27u1uE=";
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
OPENSSL_NO_VENDOR= 1;
        buildPhase = ''
          make
        '';
        installPhase = ''
          mkdir -p $out/lib
          cp hyprglass.so $out/lib/
        '';
      };
      # Custom shiki-cli derivation (sibling of hyprglass, not nested inside it)
      shiki-cli = pkgs.rustPlatform.buildRustPackage {
        pname = "shiki-cli";
        version = "unstable-2026-08-08"; # bump this when you update the shiki-src input
        src = inputs.shiki-src;
        cargoHash = "sha256-TMExeM+9Xtt2pIdKUqRegVoMYriDaBH5zPvNBXo0Vk4=";
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
      # Custom retrosmart-x11-cursors derivation (sibling of hyprglass/shiki-cli)
      retrosmart-cursors = pkgs.stdenv.mkDerivation rec {
        pname = "retrosmart-x11-cursors";
        version = "unstable-2025-01-13";
        src = pkgs.fetchFromGitHub {
          owner = "mdomlop";
          repo = "retrosmart-x11-cursors";
          rev = "master"; # pin to a commit sha once confirmed working
          sha256 = "sha256-smsC02aDdOWlNfk+1/lVwH41qDCpPDxePDbrmou8M/4=";
        };
        nativeBuildInputs = with pkgs; [ imagemagick xorg.xcursorgen ];
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
        inherit system;
        specialArgs = { inherit inputs hyprglass shiki-cli retrosmart-cursors; };
        modules = [
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
