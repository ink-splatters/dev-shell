{ ... }:
{
  perSystem =
    {
      pkgs,
      config,
      self',
      ...
    }:
    {
      pre-commit = {
        check.enable = true;
        inherit pkgs;
        settings = {

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

            # nil.enable = true;
            nixfmt-rfc-style.enable = true;
            statix = {
              settings.config = "statix.toml";
              enable = true;
            };
          };
        };
      };
      packages.install-hooks = pkgs.writeShellScriptBin "install-hooks" ''
        ${config.pre-commit.installationScript}
        echo Done!
      '';
      apps = {
        install-hooks = {
          type = "app";
          program = "${self'.packages.install-hooks}/bin/install-hooks";
        };
      };
      devShells.default = config.pre-commit.devShell;
    };
}
