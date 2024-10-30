{
  description = "Development environment for Zig 0.13.0 from source with GTK 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    let
      overlays = [
        # Other overlays
        (final: prev: {
          zigpkgs = inputs.zig.packages.${prev.system};
          zls = inputs.zls.packages.${prev.system}.zls;
        })
      ];

      # Our supported systems are the same supported systems as the Zig binaries
      systems = builtins.attrNames inputs.zig.packages;
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs { inherit overlays system; };
      in
      rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.zigpkgs."0.13.0"
            pkgs.zls
            pkgs.gtk4  # Add GTK 4 as a program
          ];

          buildInputs = [
            pkgs.bashInteractive
            pkgs.zlib
            pkgs.glib
            pkgs.pkg-config  # Add pkg-config to ensure proper library detection
          ];

          shellHook = ''
            # Setting the interactive bash shell
            export SHELL=${pkgs.bashInteractive}/bin/bash

            # Adding GTK 4 binaries to the PATH
            export PATH=${pkgs.gtk4}/bin:$PATH

            # Setting LD_LIBRARY_PATH for dynamic linking
            export LD_LIBRARY_PATH=${pkgs.gtk4}/lib:$LD_LIBRARY_PATH

            # Setting PKG_CONFIG_PATH for pkg-config
            export PKG_CONFIG_PATH=${pkgs.gtk4}/lib/pkgconfig:$PKG_CONFIG_PATH
          '';
        };

        # For compatibility with older versions of the `nix` binary
        devShell = devShells.${system}.default;
      }
    );
}

