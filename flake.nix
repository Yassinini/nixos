{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
        ];

        buildPhase = ''
          make
        '';

        installPhase = ''
          mkdir -p $out/lib
          cp hyprglass.so $out/lib/
        '';
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hyprglass; };
        modules = [
          ./hosts/legion5/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs hyprglass; };
            home-manager.users.suupatruupa = import ./home/home.nix;
          }
        ];
      };
    };
}
