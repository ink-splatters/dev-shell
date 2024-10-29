{pkgs ? import <nixpkgs> {},... }:
let
	llvmPackages = llvmPackages_19;

  compiler-flags =  pkgs.callPackage ./lib/compiler-flags.nix { inherit llvmPackages; };

  inherit (llvmPackages)
	    stdenv
	    llvm
      clang
	    libcxx
	    lld
	    ;
in
mkShell.override { inherit stdenv; } {
    name = "cpp-shell";

    inherit (compiler-flags)
      CFLAGS
      CXXFLAGS
      LDFLAGS
      hardeningDisable
      ;

    nativeBuildInputs = with pkgs; [
      ccache
      clang
      cmake
      gnumake
      lld
      ninja
      pkg-config
    ];

    shellHook =
      pre-commit-check.shellHook
      + ''
        export PS1="\n\[\033[01;36m\]‹⊂˖˖› \\$ \[\033[00m\]"
        echo -e "\nto install pre-commit hooks:\n\x1b[1;37mnix develop .#install-hooks\x1b[00m"
      '';
  };



  {
  callPackage,
  llvmPackages,
  mkShell,
  stdenvNoCC,  
  lib,
  ...
}:
let
  
  # compiler-flags = callPackage ./compiler-flags.nix { maxPerf = true; };
  

in
{
  cpp = callPackage ./shells/cpp.nix { inherit   llvmPackages pre-commit-check; };
  
  install-hooks = mkShell.override { stdenv = stdenvNoCC; } {
    shellHook =
      let
        inherit (pre-commit-check) shellHook;
      in
      ''
        ${shellHook}
        echo Done!
        exit
      '';
  };
}
