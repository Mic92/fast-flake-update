{ lib, inputs, ... }: {
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = { pkgs, ... }: {
    treefmt = {
      # Used to find the project root
      projectRootFile = "flake.lock";

      programs.prettier.enable = true;
      programs.mdsh.enable = true;
      programs.mdsh.package = pkgs.runCommand "mdsh"
        {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        } ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.lib.getExe pkgs.mdsh} $out/bin/mdsh \
          --set PATH ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.python3 ]}
      '';

      settings.formatter = {
        prettier.options = [ "--prose-wrap" "always" ];

        nix = {
          command = "sh";
          options = [
            "-eucx"
            ''
              # First deadnix
              ${pkgs.lib.getExe pkgs.deadnix} --edit "$@"
              # Then nixpkgs-fmt
              ${pkgs.lib.getExe pkgs.nixpkgs-fmt} "$@"
            ''
            "--"
          ];
          includes = [ "*.nix" ];
          excludes = [ "nix/sources.nix" ];
        };

        python = {
          command = "sh";
          options = [
            "-eucx"
            ''
              ${lib.getExe pkgs.ruff} --fix "$@"
              ${lib.getExe pkgs.ruff} format "$@"
            ''
            "--" # this argument is ignored by bash
          ];
          includes = [ "*.py" ];
        };
      };
    };
  };
}
