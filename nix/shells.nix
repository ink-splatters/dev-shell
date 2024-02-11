{ pkgs, common, self, system, ... }:
with pkgs; rec {

  default = mkShell.override { inherit (llvmPackages) stdenv; } {

    name = "cpp-shell";

    shellHook = ''
      export PS1="\n\[\033[01;36m\]‹⊂˖˖› \\$ \[\033[00m\]"
      echo -e "\nto install pre-commit hooks:\n\x1b[1;37mnix develop .#install-hooks\x1b[00m"
    '';
  } // common;

  unhardened = { hardeningDisable = [ "all" ]; } // default;

  O3 = let inherit (default) CFLAGS CXXFLAGS;
  in {
    CFLAGS = "${CFLAGS} -O3";
    CXXFLAGS = "${CXXFLAGS} -O3";
  } // default;

  O3-unhardened = O3 // unhardened;

  install-hooks =
    mkShell { inherit (self.checks.${system}.pre-commit-check) shellHook; };
}
