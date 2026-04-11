# nix-wrapper-modules proof-of-concept migration from nixCats
# This flake is MUCH simpler than nixCats - most config moves to module.nix
{
  description = "Neovim with nix-wrapper-modules (nixCats successor)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # Custom plugins (same as before)
    plugins-obsidian-nvim = {
      url = "github:obsidian-nvim/obsidian.nvim";
      flake = false;
    };
    plugins-molten-nvim = {
      url = "github:benlubas/molten-nvim";
      flake = false;
    };
    plugins-dbt-power-nvim = {
      url = "github:hashPhoeNiX/dbt-power.nvim/feat/config-validation-and-improvements";
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
  };

  outputs = { self, nixpkgs, nix-wrapper-modules, ... }@inputs:
    let
      system = "x86_64-darwin";  # or aarch64-darwin
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Standard plugin overlay (same as nixCats)
          (final: prev: {
            neovimPlugins = builtins.mapAttrs
              (name: value: prev.vimUtils.buildVimPlugin {
                pname = name;
                version = "latest";
                src = value;
              })
              (builtins.removeAttrs inputs [ "self" "nixpkgs" "nix-wrapper-modules" ]);
          })
          # Custom packages overlay
          (final: prev: import ../pkgs { pkgs = final; })
        ];
      };

      # This is where the magic happens - evaluate the module
      nvim = nix-wrapper-modules.lib.evalPackage [
        ./module.nix
        {
          inherit pkgs;
          # Pass inputs for access to custom plugins
          inherit inputs;
        }
      ];

      # You can create multiple variants easily
      nvim-light = nix-wrapper-modules.lib.evalPackage [
        ./module.nix
        {
          inherit pkgs inputs;
          # Override specific options
          enableDataTools = false;
        }
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
