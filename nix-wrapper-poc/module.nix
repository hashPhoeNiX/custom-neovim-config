# nix-wrapper-modules Neovim configuration
# Full mirror of the main nixCats flake — all categories, deps, and settings.
#
# nixCats → nix-wrapper-modules translation map:
#   categoryDefinitions.startupPlugins   → specs.*
#   categoryDefinitions.lspsAndRuntimeDeps → extraPackages
#   categoryDefinitions.python3.libraries  → hosts.python3.withPackages
#   categoryDefinitions.extraLuaPackages   → settings.nvim_lua_env
#   categoryDefinitions.environmentVariables → env.*
#   categoryDefinitions.extraWrapperArgs   → env.* (--set becomes a plain assignment)
#   categoryDefinitions.bashBeforeWrapper  → runShell (list of { data = "..."; })
#   packageDefinitions.settings.aliases   → settings.aliases
#   packageDefinitions.settings.wrapRc    → settings.config_directory
#   packageDefinitions.settings.hosts.*   → hosts.*.nvim-host.enable

{ wlib, config, pkgs, lib, enableDataTools, ... }:

{
  imports = [ wlib.wrapperModules.neovim ];

  # ============================================================================
  # PLUGINS (replaces nixCats startupPlugins)
  # ============================================================================

  # nixpkgs plugins (was: startupPlugins.general)
  specs.general = with pkgs.vimPlugins;
    [
      catppuccin-nvim
      telescope-nvim
      plenary-nvim
      lazydev-nvim
      noice-nvim
      mini-nvim
      neodev-nvim
      copilot-lua
      vim-tmux-navigator
      conform-nvim
      gitsigns-nvim
      project-nvim
      distant-nvim

      # Treesitter: grammars only — native Neovim 0.12 API handles highlighting.
      # nixpkgs maintains this independently from the archived upstream plugin.
      nvim-treesitter.withAllGrammars
      # (nvim-treesitter.withPlugins (
      #   plugins: with plugins; [ nix lua python ]
      # ))

      # Enhanced editing and navigation
      nvim-ufo
      promise-async
      todo-comments-nvim
      grug-far-nvim
    ]
    ++ lib.optionals enableDataTools [
      # Data Engineering, Science and Analysis
      quarto-nvim
      image-nvim
      jupytext-nvim
      otter-nvim

      # Database and dbt
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];

  # GitHub plugins (was: startupPlugins.gitPlugins)
  specs.gitPlugins = with pkgs.neovimPlugins;
    [
      obsidian-nvim
      molten-nvim
      youversion-linker-nvim
      dbtpal
      cmp-dbt
      # sshfs-nvim    # Disabled: Requires macFUSE kernel extension on macOS
      # remote-ssh-nvim
    ]
    ++ lib.optionals (pkgs ? neovimPlugins.dbt-power-nvim) [
      dbt-power-nvim
    ];

  # ============================================================================
  # RUNTIME DEPENDENCIES (replaces nixCats lspsAndRuntimeDeps.general)
  # ============================================================================

  extraPackages = with pkgs;
    [
      fd
      ripgrep

      # lazygit needs a writable config file; supply an empty one from Nix
      (pkgs.writeShellScriptBin "lazygit" ''
        exec ${pkgs.lazygit}/bin/lazygit --use-config-file ${pkgs.writeText "lazygit_config.yml" ""} "$@"
      '')

      # Language servers and formatters
      nixd
      ruff
      pyright
      basedpyright
      nixfmt
      imagemagick
      python312Packages.jupytext
      lua-language-server
      lua51Packages.lua
      lua51Packages.luarocks

      # DevOps LSP servers
      dockerfile-language-server
      docker-compose-language-service
      terraform-ls
      yaml-language-server

      # dbt CLI note: nixpkgs 'dbt' is dbt-core, not dbt Cloud CLI.
      # For dbt Cloud CLI install manually: https://docs.getdbt.com/docs/cloud/cloud-cli-installation
      # dbt
      # python312Packages.dbt-core
      # python312Packages.dbt-postgres
      # python312Packages.dbt-bigquery
      # python312Packages.dbt-snowflake
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      dbt-language-server
    ];

  # ============================================================================
  # PYTHON HOST (replaces nixCats python3.libraries.general + hosts.python3.enable)
  # ============================================================================

  hosts.python3.nvim-host.enable = true;

  # pynvim is added automatically by the host; list the rest here
  hosts.python3.withPackages = ps: with ps; [
    pynvim
    jupyter-client
    cairosvg    # image rendering
    pnglatex    # image rendering
    # plotly    # image rendering
    # kaleido   # image rendering
    pyperclip
    nbformat
    jupytext
    ipykernel
    pillow
  ];

  # ============================================================================
  # NODE HOST (replaces nixCats hosts.node.enable)
  # ============================================================================

  hosts.node.nvim-host.enable = true;

  # ============================================================================
  # LUA PACKAGES (replaces nixCats extraLuaPackages.general + .test)
  # ============================================================================

  settings.nvim_lua_env = lp: with lp; [
    magick        # general: image rendering via imagemagick

    # test category packages
    luasocket
    luasec
    lrexlib-pcre
    cjson
    penlight
    jsregexp
    busted
  ];

  # ============================================================================
  # SETTINGS (replaces nixCats packageDefinitions.nvim.settings)
  # ============================================================================

  # Wrap the config directory (replaces wrapRc = true + luaPath)
  settings.config_directory = "${./..}";

  # Shell aliases for the nvim binary (replaces aliases = [ "vim" "nv" ])
  settings.aliases = [ "vim" "nv" ];

  # ============================================================================
  # ENVIRONMENT VARIABLES (replaces nixCats environmentVariables.test)
  # ============================================================================

  env.CATTESTVAR = "It worked!";
  # replaces extraWrapperArgs.test = [ ''--set CATTESTVAR2 "It worked again!"'' ]
  env.CATTESTVAR2 = "It worked again!";

  # ============================================================================
  # PRE-START HOOK (replaces nixCats bashBeforeWrapper.general)
  # Install the Jupyter ipykernel on first run so molten-nvim can find it.
  #
  # NOTE: In nix-wrapper-modules the wrapped python host binary name differs
  # from nixCats' "${name}-python3". Update the binary path below once confirmed.
  # The host binary is typically available via $NVIM_PYTHON3_HOST or at
  # hosts.python3.nvim-host.package in the Nix derivation.
  # ============================================================================

  runShell = [
    {
      name = "install-jupyter-kernel";
      data = ''
        if [ ! -d "$HOME/Library/Jupyter/kernels/nixcats-python" ]; then
          "$NVIM_PYTHON3_HOST" -m ipykernel install \
            --user \
            --name "nixCats-python" \
            --display-name "NixCats Python"
        fi
      '';
    }
  ];
}
