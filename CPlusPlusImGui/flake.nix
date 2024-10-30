{
  description = "RoombaController - C++ ImGui project with GLFW and OpenGL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";  # Adjust if you're on a different architecture
    in {
      # Define the devShell (development environment)
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.cmake
          pkgs.gcc
          pkgs.glew
          pkgs.pkg-config
          pkgs.mesa  # Provides OpenGL libraries
          pkgs.glfw
          pkgs.git
          pkgs.libclang
        ];

        shellHook = ''
          echo "Welcome to the RoombaController development shell!"
        '';
      };

      # Define a package for building the project
      packages.x86_64-linux.roomba-controller = pkgs.stdenv.mkDerivation {
        name = "RoombaControllers";
        src = ./.;
        buildInputs = [
          pkgs.cmake
          pkgs.gcc
          pkgs.glew
          pkgs.mesa  # Provides OpenGL libraries
          pkgs.glfw
        ];

        nativeBuildInputs = [ pkgs.cmake ];

        buildPhase = ''
          mkdir -p build
          cd build
          cmake .. -DCMAKE_BUILD_TYPE=Release
          make
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp build/RoombaControllers $out/bin/
        '';
      };

      # Optionally, define a `run` command to run the app after building
      apps.x86_64-linux.run = {
        type = "app";
        program = "${self.packages.x86_64-linux.roomba-controller}/bin/RoombaControllers";
      };
    };
}
