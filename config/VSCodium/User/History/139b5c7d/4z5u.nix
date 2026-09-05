{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "py312-env";
  buildInputs = with pkgs; [
    python312
    python312Packages.pip
    python312Packages.virtualenv
    stdenv.cc.cc.lib
    zlib
    glib
    libxcb
    libGL
    libGLU
    libglvnd
    libX11
    libXext
    libSM
    libICE
    libXrender
    libXrandr
    libXfixes
    libXi
    libxkbcommon
    fontconfig
    freetype
    dbus
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
  pkgs.stdenv.cc.cc.lib
  pkgs.zlib
  pkgs.glib
  pkgs.libGL
  pkgs.libglvnd
  pkgs.libxcb
  pkgs.libX11
  pkgs.libXext
  pkgs.libSM
  pkgs.libICE
  pkgs.libXrender
  pkgs.libXrandr
  pkgs.libXfixes
  pkgs.libXi
  pkgs.libxkbcommon
  pkgs.fontconfig
  pkgs.freetype
  pkgs.dbus
];
