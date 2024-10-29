# {
#   description = "basic dev shells";

#   inputs = {
#     systems.url = "github:nix-systems/default";

#     flake-utils = {
#       url = "github:numtide/flake-utils";
#       inputs.systems.follows = "systems";
#     };
#     git-hooks = {
#       url = "github:cachix/git-hooks.nix";
#       inputs = {
#         nixpkgs.follows = "nixpkgs";
#         nixpkgs-stable.follows = "nixpkgs";
#       };
#     };
#   };

#   nixConfig = {
#     extra-substituters = "https://cachix.cachix.org";
#     extra-trusted-public-keys = "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
#   };

#   outputs =
#     {
#       nixpkgs,
#       flake-utils,
#       git-hooks,
#       ...
#     }:
#     flake-utils.lib.eachDefaultSystem (
#       system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};

#         inherit (pkgs) callPackage;

#         callPackageWithLib = let
#           lib = {

#             # TODO: make maxPerf configurable
#             compiler-flags =  callPackage ./lib/compiler-flags.nix { maxPerf = true; };
#             pre-commit-check = callPackage ./lib/pre-commit-check.nix { inherit git-hooks system; };        

#           };
        
#       in
#       {
#         checks = {
#           inherit pre-commit-check;
#         };

#         formatter = pkgs.nixfmt-rfc-style;

#         devShells = {
#           install-hooks = callPackage ./shells/install-hooks { inherit lib; stdenv = pkgs.stdenvNoCC; };
#           cpp = callPackage ./shells/cpp  { llvmPackages = pkgs.llvmPackages_19; };

#         };
#       }
#     );
# }

{
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs =
    { nixpkgs, flake-utils, git-hooks,self,... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        git-hooks-util = pkgs.callPackage ./git-hooks-util.nix { inherit git-hooks system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        checks = {
          inherit (git-hooks-util) run-hooks;
        };
        apps = {
          inherit (git-hooks-util) install-hooks;
        };

        devShells.default = pkgs.callPackage ./shell.nix { };

        });

}
