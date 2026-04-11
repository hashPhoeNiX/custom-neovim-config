# Quick Start Guide

## Prerequisites

You already have everything you need since you're using nixCats!

## Test the POC

### 1. Build the package

```bash
cd nix-wrapper-poc
nix build
```

**Note:** This will download `nix-wrapper-modules` and build Neovim with your config.

### 2. Run Neovim

```bash
./result/bin/nvim
```

This should launch Neovim with:
- All your plugins
- LSP servers
- Python environment
- Your existing lua config from `../lua/`

### 3. Try the lightweight variant

```bash
nix build .#nvim-light
./result/bin/nvim
```

This version excludes data engineering tools (Jupyter, dbt plugins, etc.).

## Development Workflow

### Enter a shell with Neovim

```bash
nix develop
nvim  # Available in PATH
```

### Quick rebuild and test

```bash
nix run
```

Builds and runs Neovim in one command.

## Customization

### Add a plugin

**Edit `module.nix`:**
```nix
specs.general = with pkgs.vimPlugins; [
  # ... existing plugins
  nvim-tree-lua  # Add new plugin
];
```

**Rebuild:**
```bash
nix build
./result/bin/nvim
```

### Add an LSP

**Edit `module.nix`:**
```nix
extraPackages = with pkgs; [
  # ... existing packages
  gopls  # Add Go LSP
];
```

**Configure in your lua:**
```lua
-- lua/lsp/go.lua
return {
  name = 'gopls',
  cmd = { 'gopls' },
  root_markers = { 'go.mod' },
  filetypes = { 'go' },
}
```

**Register in `lua/config/lsp.lua`:**
```lua
local lsp_servers = {
  -- ... existing
  "go",
}
```

### Create a custom variant

**Edit `flake.nix`:**
```nix
outputs = { ... }: {
  packages.${system} = {
    # ... existing

    nvim-minimal = nix-wrapper-modules.lib.evalPackage [
      ./module.nix
      {
        inherit pkgs inputs;
        enableDataTools = false;
        # Add more custom options
        minimalPlugins = true;
      }
    ];
  };
}
```

**Use it:**
```bash
nix build .#nvim-minimal
```

## Comparing with nixCats

### Same behavior test

Both should work identically:

```bash
# Your current nixCats version
cd ..
nix build
./result/bin/nvim --version

# POC version
cd nix-wrapper-poc
nix build
./result/bin/nvim --version
```

### Plugin test

Open a file and check:
```vim
:Lazy
:LspInfo
:checkhealth
```

Both should show the same plugins and LSP servers.

## Troubleshooting

### "error: experimental feature 'nix-command' not enabled"

Enable flakes:
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### "error: getting status of '/nix/store/...': No such file or directory"

Make sure files are git-staged (nix-wrapper-modules requires this like nixCats):
```bash
git add flake.nix module.nix
nix build
```

### Build takes a long time

First build downloads and builds everything. Subsequent builds are cached.

### Lua config not found

The `settings.config_directory` in `module.nix` points to `"${./..}"` (parent directory).
If you move this POC elsewhere, update that path.

## Next Steps

1. **Read `README.md`** - Understand the differences
2. **Read `COMPARISON.md`** - See your config mapped 1-to-1
3. **Test functionality** - Make sure everything works
4. **Experiment** - Try creating custom variants
5. **Decide** - Keep nixCats or migrate later

## Questions?

Compare these files to understand the structure:
- `flake.nix` - Simpler than nixCats version
- `module.nix` - Where nixCats' categoryDefinitions went
- `../flake.nix` - Your current nixCats config

Notice how your lua config in `../lua/` doesn't change at all!
