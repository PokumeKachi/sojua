{
    description = "sojua flake.nix";
    inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    outputs =
        { self, nixpkgs }:
        let
            systems = [ "x86_64-linux" ];
            forAllSystems = nixpkgs.lib.genAttrs systems;

            perSystem =
                system:
                let
                    pkgs = import nixpkgs { inherit system; };
                    libs = with pkgs; [
                        libxkbcommon
                        alsa-lib
                        wayland
                        systemdLibs
                    ];
                    tools = with pkgs; [
                        pkg-config
                        mold
                    ];
                    common = {
                        buildInputs = libs;
                        nativeBuildInputs = tools;
                    };
                in
                {
                    inherit
                        pkgs
                        libs
                        tools
                        common
                        ;
                };
        in
        {
            packages = forAllSystems (
                system:
                let
                    ps = perSystem system;
                in
                {
                    default = ps.pkgs.rustPlatform.buildRustPackage (
                        ps.common
                        // {
                            pname = "sojua";
                            version = "0.1.0";
                            src = ps.pkgs.lib.cleanSource ./.;
                            cargoLock.lockFile = ./Cargo.lock;
                        }
                    );
                }
            );

            devShells = forAllSystems (
                system:
                let
                    ps = perSystem system;
                in
                {
                    default = ps.pkgs.mkShell (
                        ps.common
                        // {
                            shellHook = ''
                                export SHELL=${ps.pkgs.bashInteractive}/bin/bash
                                export LD_LIBRARY_PATH=${ps.pkgs.lib.makeLibraryPath ps.libs}:$LD_LIBRARY_PATH
                            '';
                        }
                    );
                }
            );
        };
}
