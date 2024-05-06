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

      in {
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage rec {
          pname = "rumqttd";
          version = "0.19.0";
          name = "${pname}";
          root = ./.;
          src = ./.;
          release = true;
          cargoBuildOptions = x: x ++ [ "-p" "rumqttd" ];          
          nativeBuildInputs = [ pkgs.pkg-config pkgs.openssl];
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
