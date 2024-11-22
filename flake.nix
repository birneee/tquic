{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        libtquicManifest = (pkgs.lib.importTOML ./Cargo.toml).package;
        toolsManifest = (pkgs.lib.importTOML ./tools/Cargo.toml).package;
      in
      {
        packages.libtquic = pkgs.rustPlatform.buildRustPackage {
            pname = libtquicManifest.name;
            version = libtquicManifest.version;
            cargoLock.lockFile = ./Cargo.lock;
            src = pkgs.lib.cleanSource ./.;
            nativeBuildInputs = with pkgs; [
                cmake
            ];
        };
        packages.tools = pkgs.rustPlatform.buildRustPackage {
            pname = toolsManifest.name;
            version = toolsManifest.version;
            cargoLock.lockFile = ./Cargo.lock;
            src = pkgs.lib.cleanSource ./.;
            buildAndTestSubdir = [
                "tools"
            ];
            nativeBuildInputs = with pkgs; [
                cmake
            ];
        };
        packages.default = self.packages.${system}.libtquic;
      }
    );
}