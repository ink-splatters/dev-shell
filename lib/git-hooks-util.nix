{
  pkgs,
  git-hooks,
  system,
  ...
}: rec {
  run-hooks = git-hooks.lib.${system}.run {
    src = ../.;
    hooks = {
      clang-format.enable = true;
      clang-tidy.enable = true;
      deadnix.enable = true;
      markdownlint = {
        enable = true;
        settings.configuration = {
          MD041.level = 2;
        };
      };

      nil.enable = true;
      nixfmt-rfc-style.enable = true;
      statix.enable = true;
    };

    tools = pkgs;
  };

  install-hooks = let
      inherit (run-hooks) shellHook;
    in
    {
    type = "app";
    program = pkgs.writeShellScriptBin "install-hooks" ''
      ${shellHook}
      echo Done!
    '';
  };
}