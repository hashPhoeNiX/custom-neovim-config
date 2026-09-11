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
          # and nix-on-droid's proot sandbox (no real network interfaces, kernels die
          # before replying) causing a cascade failure through
          # jupyter-server/nbconvert -> jupytext -> neovim.
          # Harmless to apply everywhere (just skips tests, doesn't change behavior).
          (final: prev: {
            python312 = prev.python312.override {
              packageOverrides = pyFinal: pyPrev: {
                twisted = pyPrev.twisted.overridePythonAttrs (_: {
                  doCheck = false;
                });
                jupyter-server = pyPrev.jupyter-server.overridePythonAttrs (_: {
                  doCheck = false;
                });
                nbconvert = pyPrev.nbconvert.overridePythonAttrs (_: {
                  doCheck = false;
                });
                # NOTE: deliberately NOT overriding jupytext here. `notebook`
                # (jupytext's nativeCheckInputs, test-time only) is what
                # crashes under nix-on-droid/proot — proot blocks /proc/stat,
                # so Node's os.cpus() returns [], and notebook's yarn-berry
                # frontend build feeds that into a concurrency pool and
                # crashes ("fastqueue concurrency must be greater than 1",
                # unpatched upstream: yarnpkg/berry#5635). But jupytext is
                # now Darwin-only (module.nix) precisely because Molten — its
                # only consumer — is Darwin-only, and Darwin never hits this
                # bug at all. overridePythonAttrs'ing jupytext just to flip
                # doCheck invalidates its binary-cache substitute (the cache
                # only has the stock build), forcing an expensive full local
                # rebuild of jupytext + its own build-time JupyterLab
                # extension deps (jupyterlab, jupyterlab-server, fastapi,
                # openapi-core) — and risks hitting jupytext's *own* internal
                # yarn-berry step, the same bug class, on a platform that
                # never needed the workaround. Leave it at nixpkgs defaults.
                #
                # (Also worth noting: jupyter-server and nbconvert above are
                # only ever reached transitively through jupytext's own
                # build inputs — nothing else in this config touches them
                # (jupyter-client, which Molten/Jupynvim both need for real
                # kernel connections, is a separate, independent package).
                # So now that jupytext is Darwin-only, this whole doCheck
                # chain is effectively Darwin-only too: nothing on Linux
                # references jupytext, so nothing pulls these in there
                # either. Keeping the overrides is harmless either way —
                # they just won't matter outside Darwin anymore.)
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
