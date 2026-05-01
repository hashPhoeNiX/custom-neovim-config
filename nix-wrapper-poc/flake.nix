# nix-wrapper-modules proof-of-concept migration from nixCats
# This flake is MUCH simpler than nixCats - most config moves to module.nix
{
  description = "Neovim with nix-wrapper-modules (nixCats successor)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # Custom plugins (mirroring main flake.nix)
    plugins-obsidian-nvim = {
      url = "github:obsidian-nvim/obsidian.nvim";
      flake = false;
    };
    plugins-molten-nvim = {
      url = "github:benlubas/molten-nvim";
      flake = false;
    };
    plugins-youversion-linker-nvim = {
      url = "github:hashPhoeNiX/youversion-linker.nvim/feat/initial-setup";
      flake = false;
    };
    plugins-dbtpal = {
      url = "github:PedramNavid/dbtpal";
      flake = false;
    };
    plugins-cmp-dbt = {
      url = "github:MattiasMTS/cmp-dbt";
      flake = false;
    };
    plugins-dbt-power-nvim = {
      url = "github:hashPhoeNiX/dbt-power.nvim/feat/config-validation-and-improvements";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-wrapper-modules, ... }@inputs:
    let
      system = "aarch64-darwin";  # Apple Silicon
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "jupytext.nvim"
          ];
        };
        overlays = [
          (final: prev: {
            dbt-language-server = import ./../pkgs/dbt-language-server.nix { pkgs = final; };
          })
          # Build custom GitHub plugins into pkgs.neovimPlugins (same role as
          # nixCats' standardPluginOverlay — strips the "plugins-" prefix)
          (final: prev: {
            neovimPlugins = builtins.mapAttrs (name: src:
              prev.vimUtils.buildVimPlugin {
                pname = name;
                version = "latest";
                inherit src;
                # Disable build-time require check: custom plugins often depend
                # on other plugins (e.g. cmp-dbt → nvim-cmp) that aren't
                # present in the build sandbox.
                nvimRequireCheck = false;
              }
            ) {
              obsidian-nvim        = inputs.plugins-obsidian-nvim;
              molten-nvim          = inputs.plugins-molten-nvim;
              youversion-linker-nvim = inputs.plugins-youversion-linker-nvim;
              dbtpal               = inputs.plugins-dbtpal;
              cmp-dbt              = inputs.plugins-cmp-dbt;
              dbt-power-nvim       = inputs.plugins-dbt-power-nvim;
            };
          })
          # Workaround: upstream nixpkgs Python packages have flaky/broken tests on macOS
          # causing a cascade failure through jupyter-server -> jupytext -> neovim
          (final: prev: {
            python312 = prev.python312.override {
              packageOverrides = pyFinal: pyPrev: {
                twisted = pyPrev.twisted.overridePythonAttrs (_: {
                  doCheck = false;
                });
                jupyter-server = pyPrev.jupyter-server.overridePythonAttrs (_: {
                  doCheck = false;
                });
              };
            };
            python312Packages = final.python312.pkgs;
          })
        ];
      };

      # This is where the magic happens - evaluate the module
      nvim = nix-wrapper-modules.lib.evalPackage [
        ./module.nix
        { inherit pkgs; _module.args.enableDataTools = true; }
      ];

      # You can create multiple variants easily
      nvim-light = nix-wrapper-modules.lib.evalPackage [
        ./module.nix
        { inherit pkgs; _module.args.enableDataTools = false; }
      ];

    in
    {
      # Export packages for each system
      packages.${system} = {
        default = nvim;
        nvim = nvim;
        nvim-light = nvim-light;
      };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        packages = [ nvim ];
      };

      # Can also export as an overlay for use in other flakes
      overlays.default = final: prev: {
        nvim-custom = nvim;
      };
    };
}
