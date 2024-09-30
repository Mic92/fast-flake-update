{ lib, inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        # Used to find the project root
        projectRootFile = "flake.lock";

        programs.prettier.enable = true;

        programs.nixfmt.enable = lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
        programs.nixfmt.package = pkgs.nixfmt-rfc-style;

        programs.deadnix.enable = true;
        programs.ruff.check = true;
        programs.ruff.format = true;

        programs.mdsh.enable = true;
        programs.mdsh.package =
          pkgs.runCommand "mdsh"
            {
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              mkdir -p $out/bin
              makeWrapper ${pkgs.lib.getExe pkgs.mdsh} $out/bin/mdsh \
                --set PATH ${
                  pkgs.lib.makeBinPath [
                    pkgs.bash
                    pkgs.python3
                  ]
                }
            '';
      };
    };
}
