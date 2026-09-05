function hyprset
    set -l pkgs libadwaita gtk4 graphene pango gdk-pixbuf cairo harfbuzz glib
    set -x LD_LIBRARY_PATH (nix build --no-link --print-out-paths $pkgs 2>/dev/null | string replace -r '$' '/lib' | string join :)
    
    nix-shell -p python312 python312Packages.pygobject3 gtk4 libadwaita graphene pango gdk-pixbuf cairo harfbuzz glib gobject-introspection pkg-config uv $argv
end
