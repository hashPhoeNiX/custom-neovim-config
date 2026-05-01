# nix-wrapper-modules Neovim configuration module
# This is where your nixCats "categoryDefinitions" and "packageDefinitions" merge
# Using the Nix module system instead of custom categories
#
# NOTE: This POC uses only nixpkgs plugins for simplicity
# Your full config has custom GitHub plugins - those can be added later

{ wlib, config, pkgs, lib, enableDataTools, ... }:

{
  # Import the neovim wrapper module
  imports = [ wlib.wrapperModules.neovim ];

  # ============================================================================
  # PLUGINS (replaces nixCats categoryDefinitions.startupPlugins)
  # ============================================================================

  # General plugins from nixpkgs
  specs.general = with pkgs.vimPlugins; [
    # Core
    catppuccin-nvim
    telescope-nvim
    plenary-nvim
    lazydev-nvim
    noice-nvim
    mini-nvim

    # LSP and completion
    blink-cmp
    nvim-lspconfig
    copilot-lua

    # UI and navigation
    vim-tmux-navigator
    nvim-ufo
    promise-async
    todo-comments-nvim
    grug-far-nvim

    # Git
    gitsigns-nvim

    # Utilities
    project-nvim
    distant-nvim
    conform-nvim

    # Treesitter
    nvim-treesitter.withAllGrammars
  ] ++ lib.optionals enableDataTools [
    # Data Engineering plugins (conditionally included)
    quarto-nvim
    image-nvim
    jupytext-nvim
    otter-nvim
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion
  ];

  # Custom plugins from GitHub (built by the neovimPlugins overlay in flake.nix)
  specs.gitPlugins = with pkgs.neovimPlugins; [
    obsidian-nvim
    molten-nvim
    youversion-linker-nvim
    dbtpal
    cmp-dbt
    dbt-power-nvim
  ];

  # ============================================================================
  # RUNTIME DEPENDENCIES (replaces nixCats lspsAndRuntimeDeps)
  # ============================================================================

  extraPackages = with pkgs; [
    # Core tools
    fd
    ripgrep

    # Formatters and linters
    nixd
    nixfmt
    ruff

    # LSP servers
    lua-language-server
    pyright
    basedpyright

    # DevOps LSPs
    dockerfile-language-server
    docker-compose-language-service
    terraform-ls
    yaml-language-server

    # Misc tools
    imagemagick
    python312Packages.jupytext
    lua51Packages.lua
    lua51Packages.luarocks

    # lazygit with custom config
    (pkgs.writeShellScriptBin "lazygit" ''
      exec ${pkgs.lazygit}/bin/lazygit --use-config-file ${pkgs.writeText "lazygit_config.yml" ""} "$@"
    '')
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    dbt-language-server
  ];

  # ============================================================================
  # PYTHON ENVIRONMENT (replaces nixCats python3.libraries)
  # ============================================================================

  # nix-wrapper-modules uses hosts.python3.withPackages (pynvim is added automatically)
  hosts.python3.withPackages = ps: with ps; [
    jupyter-client
    cairosvg
    pnglatex
    pyperclip
    nbformat
    jupytext
    ipykernel
    pillow
  ];

  # ============================================================================
  # LUA PACKAGES (replaces nixCats extraLuaPackages)
  # ============================================================================

  # nix-wrapper-modules uses settings.nvim_lua_env (takes a single function, not a list)
  settings.nvim_lua_env = lp: with lp; [
    luasocket
    luasec
    lrexlib-pcre
    cjson
    penlight
    jsregexp
    busted
    magick
  ];

  # ============================================================================
  # CONFIGURATION DIRECTORY
  # ============================================================================

  # Point to your existing lua config directory
  # This can be:
  # - An in-store path: "${./../lua}"
  # - Your entire config: "${./..}"
  # - A generated config
  settings.config_directory = "${./..}";

  # ============================================================================
  # ENVIRONMENT VARIABLES (replaces nixCats environmentVariables)
  # ============================================================================

  # Environment variables available to Neovim (nix-wrapper-modules uses `env`, not `extraEnvVars`)
  env = {
    CATTESTVAR = "It works!";
  };

  # ============================================================================
  # WRAPPER ARGS (replaces nixCats extraWrapperArgs)
  # ============================================================================

  # Additional wrapper arguments
  # extraMakeWrapperArgs = [
  #   "--set CATTESTVAR2 \"It works again!\""
  # ];

  # ============================================================================
  # ADVANCED OPTIONS (new in nix-wrapper-modules)
  # ============================================================================

  # Python 3 and Node hosts are enabled by default in nix-wrapper-modules.
  # Use hosts.python3.nvim-host.enable / hosts.node.nvim-host.enable to toggle.
  # hosts.python3.nvim-host.enable = true;  # default
  # hosts.node.nvim-host.enable = true;     # default

  # Aliases (like nixCats settings.aliases)
  # Note: In nix-wrapper-modules, you typically install the package
  # and create aliases in your shell or home-manager

  # ============================================================================
  # CUSTOM MODULE OPTIONS (the power of modules!)
  # ============================================================================

  # Note: enableDataTools is passed as a parameter from flake.nix
  # In a full module, you could define custom options here using:
  # options.enableDataTools = lib.mkOption { ... };
  # But for POC simplicity, we use function parameters instead

  # ============================================================================
  # HOOKS (new capability in nix-wrapper-modules)
  # ============================================================================

  # Pre-wrapper hooks (like nixCats bashBeforeWrapper)
  # preWrap = ''
  #   if [ ! -d "$HOME/Library/Jupyter/kernels/nixcats-python" ]; then
  #     ${config.python3}/bin/python3 -m ipykernel install \
  #       --user \
  #       --name "nixCats-python" \
  #       --display-name "NixCats Python"
  #   fi
  # '';

  # ============================================================================
  # SHARED LIBRARIES (replaces nixCats sharedLibraries)
  # ============================================================================

  # extraSharedLibraries = with pkgs; [
  #   # libgit2
  # ];
}
