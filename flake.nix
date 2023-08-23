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
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [ ./treefmt.nix ];
      perSystem = { pkgs, ... }: {
        packages.default = pkgs.python3.pkgs.buildPythonPackage {

          pname = "fast-flake-update";
          version = "0.1.0";
          src = ./.;
          doCheck = false;
        };
      };
    };
}
