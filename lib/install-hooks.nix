{ stdenv, lib,...}:
mkShell.override { inherit stdenv; } {
    shellHook =
      let
        inherit (lib.pre-commit-check) shellHook;
      in
      ''
        ${shellHook}
        echo Done!
        exit
      '';
  }