{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [
    python3
    python3Packages.pygobject3
    python3Packages.google-auth
    python3Packages.google-auth-oauthlib
    python3Packages.google-api-python-client
    gtk4
    gtk4-layer-shell
    pango
  ];
  
  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.gtk4-layer-shell}/lib:$LD_LIBRARY_PATH"
  '';
}
