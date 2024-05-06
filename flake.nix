{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk {};

      in rec {
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          pname = "rumqttd";
          root = ./.;
          src = ./.;
          release = true;
          cargoBuildOptions = x: x ++ [ "-p" "rumqttd" ];          
          # TODO test without libtool or pkg-config
          nativeBuildInputs = [ pkgs.pkg-config pkgs.libtool ];
          buildInputs = [ pkgs.openssl ];
        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
           rustc
           cargo
           rust-analyzer
           rustfmt
           clippy
           cargo-watch
           gdb
           pkg-config
           openssl
         ];
        };
      }
    );
}
