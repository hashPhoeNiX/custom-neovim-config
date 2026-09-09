# nix-wrapper-modules proof-of-concept migration from nixCats
# This flake is MUCH simpler than nixCats - most config moves to module.nix
{
  description = "Neovim with nix-wrapper-modules (nixCats successor)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # Custom plugins (mirroring main flake.nix).
    # Naming convention: "plugins-<name>" — module.nix uses nvim-lib.mkPlugin
    # to build these, which has doCheck = false built in (no overlay needed).
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
    plugins-bento-nvim = {
      url = "github:serhez/bento.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-wrapper-modules, ... }@inputs:
    let
      # aarch64-darwin: Apple Silicon (original target).
      # x86_64-linux / aarch64-linux: general Linux VMs/distros, and
      # aarch64-linux also covers nix-on-droid (Termux/proot on Android).
      # Not all packages are meaningful/available on every system —
      # anything platform-specific (e.g. dbt-language-server, which fetches
      # a hardcoded darwin-arm64 binary) stays gated behind
      # pkgs.stdenv.isDarwin in module.nix, unchanged by this.
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "jupytext.nvim"
          ];
        };
        overlays = [
          (final: prev: {
            dbt-language-server = import ./pkgs/dbt-language-server.nix { pkgs = final; };
          })
          # Workaround: upstream nixpkgs Python packages have flaky/broken tests on macOS
          # causing a cascade failure through jupyter-server -> jupytext -> neovim.
          # Harmless to apply on Linux too (just skips tests, doesn't change behavior).
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

      nvimFor = system:
        let pkgs = pkgsFor system; in
        {
          # This is where the magic happens - evaluate the module
          nvim = nix-wrapper-modules.lib.evalPackage [
            ./module.nix
            {
              inherit pkgs;
              _module.args.inputs = inputs;
              _module.args.enableDataTools = true;
            }
          ];

          # You can create multiple variants easily
          nvim-light = nix-wrapper-modules.lib.evalPackage [
            ./module.nix
            {
              inherit pkgs;
              _module.args.inputs = inputs;
              _module.args.enableDataTools = false;
            }
          ];
        };
    in
    {
      # Export packages for each system
      packages = forAllSystems (system:
        let inherit (nvimFor system) nvim nvim-light; in
        {
          default = nvim;
          inherit nvim nvim-light;
        }
      );

      # Development shell
      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = [ (nvimFor system).nvim ];
        };
      });

      # Can also export as an overlay for use in other flakes
      overlays.default = final: prev: {
        nvim-custom = (nvimFor final.stdenv.hostPlatform.system).nvim;
      };
    };
}
