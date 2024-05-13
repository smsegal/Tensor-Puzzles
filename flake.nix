{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;

        devenv.shells.default = {
          name = "tensor-puzzles";
          
          packages = [
            pkgs.ruff
            pkgs.pyright
            pkgs.nil
            pkgs.wget
          ];

          pre-commit.hooks = {
            ruff.enable = true;
            pyright.enable = true;
            ruff-format = {
              enable = true;
              name = "Ruff Format";
              entry = "${pkgs.ruff}/bin/ruff format";
              types = ["python"];
              language = "system";
            };
          };
          languages.python = {
            enable = pkgs.stdenv.isDarwin;
            version = "3.10";
            venv.enable = true;
            libraries = [];
            venv.requirements = builtins.readFile ./requirements.txt; 
          };
          enterShell = ''
            which python
            python --version
            # pip install -r requirements.txt
          '';
        };

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
