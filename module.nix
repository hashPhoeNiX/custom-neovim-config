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

{ wlib, config, pkgs, lib, inputs, enableDataTools, ... }:

{
  imports = [ wlib.wrapperModules.neovim ];

  # ============================================================================
  # PLUGINS (replaces nixCats startupPlugins)
  # ============================================================================

  # nixpkgs plugins (was: startupPlugins.general)
  specs.general = with pkgs.vimPlugins;
    [
      # Plugin manager (lazy.nvim)
      lazy-nvim

      # Colorschemes
      catppuccin-nvim
      github-nvim-theme
      vim-moonfly-colors

      # Core UI
      noice-nvim
      nvim-notify       # required by noice
      snacks-nvim
      which-key-nvim
      bufferline-nvim
      nvim-web-devicons  # required by bufferline, neo-tree, etc.
      nui-nvim           # required by neo-tree, hardtime
      edgy-nvim
      lualine-nvim
      dropbar-nvim

      # Completion
      blink-cmp
      blink-cmp-copilot
      friendly-snippets

      # LSP
      nvim-lspconfig

      # Telescope
      telescope-nvim
      plenary-nvim

      # File exploration and navigation
      neo-tree-nvim
      lazygit-nvim

      # AI coding assistants
      copilot-lua
      codecompanion-nvim

      # Editor tools
      lazydev-nvim
      mini-nvim
      neodev-nvim
      vim-tmux-navigator
      conform-nvim
      gitsigns-nvim
      project-nvim
      distant-nvim
      render-markdown-nvim
      persistence-nvim

      # Habit and navigation aids (optional quality-of-life)
      hardtime-nvim
      precognition-nvim

      # Treesitter: include the plugin for its query files (highlights, indent,
      # textobjects). The Lua layer is unused — native Neovim 0.12 treesitter API
      # handles highlighting via the FileType autocmd in lua/plugins/treesitter.lua.
      #
      # NOTE: Do NOT use nvim-treesitter.withAllGrammars here. That produces a
      # merged derivation without passthru.isTreesitterGrammar = true, so
      # nix-wrapper-modules' COLLATE_TS_GRAMMARS mechanism cannot detect the .so
      # files and they never reach the runtimepath.
      # Individual grammarPlugins each carry passthru.isTreesitterGrammar = true
      # and are correctly collated. Added below via builtins.attrValues.
      nvim-treesitter

      # Enhanced editing and navigation
      nvim-ufo
      promise-async
      todo-comments-nvim
      grug-far-nvim
    ]
    # Treesitter grammar .so files — each has passthru.isTreesitterGrammar = true
    # so nix-wrapper-modules' COLLATE_TS_GRAMMARS mechanism picks them up and
    # symlinks them into the packdir where Neovim's rtp can find the parsers.
    ++ builtins.attrValues pkgs.vimPlugins.nvim-treesitter.grammarPlugins
    ++ lib.optionals enableDataTools [
      # Data Engineering, Science and Analysis
      quarto-nvim
      image-nvim
      # jupytext-nvim removed: not in use and its health.lua calls the removed
      # vim.health.report_start API, causing a checkhealth error on Neovim 0.12.
      otter-nvim

      # Database and dbt
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];

  # GitHub plugins (was: startupPlugins.gitPlugins)
  # Built via config.nvim-lib.mkPlugin — uses pkgs.vimUtils.buildVimPlugin with
  # doCheck = false, so the require-check sandbox issue doesn't apply.
  # No overlay needed; inputs are passed directly from flake.nix.
  specs.gitPlugins = [
    (config.nvim-lib.mkPlugin "obsidian-nvim"          inputs.plugins-obsidian-nvim)
    (config.nvim-lib.mkPlugin "molten-nvim"            inputs.plugins-molten-nvim)
    (config.nvim-lib.mkPlugin "youversion-linker-nvim" inputs.plugins-youversion-linker-nvim)
    (config.nvim-lib.mkPlugin "dbtpal"                 inputs.plugins-dbtpal)
    (config.nvim-lib.mkPlugin "cmp-dbt"                inputs.plugins-cmp-dbt)
    (config.nvim-lib.mkPlugin "dbt-power-nvim"         inputs.plugins-dbt-power-nvim)
    (config.nvim-lib.mkPlugin "bento-nvim"             inputs.plugins-bento-nvim)
    # (config.nvim-lib.mkPlugin "sshfs-nvim"           inputs.plugins-sshfs-nvim)
    # (config.nvim-lib.mkPlugin "remote-ssh-nvim"      inputs.plugins-remote-ssh-nvim)
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

      # jupynvim (lua/plugins/data-tools/jupynvim.lua) builds its Rust backend
      # via `cargo build --release` from its lazy.nvim `build` hook; not Nix
      # packaged, so it needs a real cargo/rustc on PATH to build.
      cargo
      rustc

      # Language servers and formatters
      stylua
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
  settings.config_directory = "${./.}";

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
  # Install/refresh the Jupyter ipykernel spec so molten-nvim and jupynvim can
  # find it.
  #
  # This always re-runs `ipykernel install` rather than skipping when the
  # kernel directory already exists: the kernel.json it writes hardcodes an
  # absolute /nix/store path to the python3 host, which is immutable and gets
  # garbage-collected once nothing references it. Skipping on "already
  # installed" meant the kernelspec silently went stale (pointing at a
  # deleted path) after every `nix-collect-garbage`, breaking kernel startup
  # with no clear error until it was tracked down manually. `ipykernel
  # install` just (re)writes a small json file, so re-running it on every
  # launch is cheap.
  #
  # $NVIM_PYTHON3_HOST is not a real variable nix-wrapper-modules sets (it
  # was never defined anywhere in the generated wrapper — confirmed by
  # grepping the built script). What actually exists is a sibling
  # "${binName}-python3" executable installed next to the main binary in the
  # same output directory (e.g. result/bin/nvim-python3), which execs the
  # correct python3 host derivation. Reference it relative to $0 so it works
  # regardless of how the wrapper itself was invoked (absolute path, PATH
  # lookup, or an alias like nv/vim).
  # ============================================================================

  runShell = [
    {
      name = "install-jupyter-kernel";
      data = ''
        "$(dirname "$0")/${config.binName}-python3" -m ipykernel install \
          --user \
          --name "nixcats-python" \
          --display-name "NixCats Python"
      '';
    }
  ];
}
