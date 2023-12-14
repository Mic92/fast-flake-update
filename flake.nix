{
  description = "Update nix flake git/github inputs from local git repositories checkouts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "riscv64-linux"

        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [ ./treefmt.nix ];
      perSystem = { config, self', pkgs, lib, ... }: {
        packages.fast-flake-update = pkgs.python3.pkgs.buildPythonPackage {
          pname = "fast-flake-update";
          version = "0.1.0";
          src = ./.;
          makeWrapperArgs = [
            "--prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.git pkgs.nixVersions.nix_2_19
            ]}"
          ];
          doCheck = false;
        };
        packages.default = config.packages.fast-flake-update;
        checks =
          let
            packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
            devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
          in
          packages // devShells;
      };
    };
}
