{
  description = "Dev shells";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts = {

      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }: # flake-parts-lib, ... }:
      let
        # inherit (flake-parts-lib) importApply;

        flakeModules = {
          pre-commit = import ./modules/pre-commit.nix { inherit withSystem; };
          # cpp  = import ./modules/shells/cpp.nix { inherit withSystem; };
        };

      in
      {
        imports = [
          flakeModules.pre-commit
          inputs.git-hooks.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem =
          { pkgs, ... }:
          {
            formatter = pkgs.nixfmt-rfc-style;
          };

        flake = {
          inherit flakeModules;
        };
      }
    );
}
