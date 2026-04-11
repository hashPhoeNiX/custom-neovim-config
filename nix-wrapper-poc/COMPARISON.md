# Side-by-Side Comparison: nixCats vs nix-wrapper-modules

## Your Config Mapped 1-to-1

### Plugin Management

**nixCats (`flake.nix` lines 209-303):**
```nix
categoryDefinitions = { pkgs, ... }: {
  startupPlugins = {
    gitPlugins = with pkgs.neovimPlugins; [
      { name = "obsidian.nvim"; plugin = obsidian-nvim; }
      { name = "molten-nvim"; plugin = molten-nvim; }
      { name = "dbtpal"; plugin = dbtpal; }
    ];
    general = with pkgs.vimPlugins; [
      catppuccin-nvim
      telescope-nvim
      plenary-nvim
      # ... 30+ more plugins
    ];
  };
};
```

**nix-wrapper-modules (`module.nix` lines 15-50):**
```nix
{
  specs.general = with pkgs.vimPlugins; [
    catppuccin-nvim
    telescope-nvim
    plenary-nvim
    # ... 30+ more plugins
  ];

  specs.gitPlugins = with pkgs.neovimPlugins; [
    obsidian-nvim
    molten-nvim
    dbtpal
  ];
}
```

**Difference:** No need for `{ name = "..."; plugin = ...; }` wrapper, simpler attribute naming.

---

### LSPs and Runtime Dependencies

**nixCats (`flake.nix` lines 159-206):**
```nix
categoryDefinitions = { pkgs, ... }: {
  lspsAndRuntimeDeps = {
    general = with pkgs; [
      fd
      ripgrep
      nixd
      ruff
      pyright
      basedpyright
      lua-language-server
      # ... more tools
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      dbt-language-server
    ];
  };
};
```

**nix-wrapper-modules (`module.nix` lines 55-90):**
```nix
{
  extraPackages = with pkgs; [
    fd
    ripgrep
    nixd
    ruff
    pyright
    basedpyright
    lua-language-server
    # ... more tools
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    dbt-language-server
  ];
}
```

**Difference:** More intuitive naming (`extraPackages` vs `lspsAndRuntimeDeps`).

---

### Python Environment

**nixCats (`flake.nix` lines 354-373):**
```nix
categoryDefinitions = { pkgs, ... }: {
  python3.libraries = {
    general = (ps: with ps; [
      pynvim
      jupyter-client
      cairosvg
      pnglatex
      pyperclip
      nbformat
      jupytext
      ipykernel
      pillow
    ]);
  };
};
```

**nix-wrapper-modules (`module.nix` lines 95-108):**
```nix
{
  extraPython3Packages = ps: with ps; [
    pynvim
    jupyter-client
    cairosvg
    pnglatex
    pyperclip
    nbformat
    jupytext
    ipykernel
    pillow
  ];
}
```

**Difference:** Direct function instead of nested category structure. No need for the `general` category wrapper.

---

### Lua Packages

**nixCats (`flake.nix` lines 375-392):**
```nix
categoryDefinitions = { pkgs, ... }: {
  extraLuaPackages = {
    general = [
      (lr: with lr; [
        luasocket
        luasec
        lrexlib-pcre
        cjson
        penlight
        jsregexp
        busted
        magick
      ])
    ];
  };
};
```

**nix-wrapper-modules (`module.nix` lines 113-127):**
```nix
{
  extraLuaPackages = [
    (lr: with lr; [
      luasocket
      luasec
      lrexlib-pcre
      cjson
      penlight
      jsregexp
      busted
      magick
    ])
  ];
}
```

**Difference:** No category nesting required.

---

### Environment Variables

**nixCats (`flake.nix` lines 323-327):**
```nix
categoryDefinitions = { pkgs, ... }: {
  environmentVariables = {
    test = {
      CATTESTVAR = "It worked!";
    };
  };
};
```

**nix-wrapper-modules (`module.nix` lines 139-143):**
```nix
{
  extraEnvVars = {
    CATTESTVAR = "It works!";
  };
}
```

**Difference:** Direct key-value mapping, no category needed.

---

### Package Settings

**nixCats (`flake.nix` lines 400-439):**
```nix
packageDefinitions = {
  nvim = { pkgs, name, ... }: {
    settings = {
      suffix-path = true;
      suffix-LD = true;
      wrapRc = true;
      aliases = [ "vim" "nv" ];
      hosts.python3.enable = true;
      hosts.node.enable = true;
    };
    categories = {
      general = true;
      gitPlugins = true;
      customPlugins = true;
      test = true;
    };
  };
};
```

**nix-wrapper-modules (`module.nix` lines 152-154):**
```nix
{
  settings.withPython3 = true;
  settings.withNodeJs = true;
  # Aliases handled by shell or home-manager
}
```

**Difference:** Settings are module options, categories are replaced by direct inclusion. You enable features by including them in `specs.*` or `extraPackages`.

---

### Conditional Features

**nixCats (implicit in categories):**
```nix
packageDefinitions = {
  nvim-light = { pkgs, ... }: {
    categories = {
      general = true;
      gitPlugins = false;  # Disable custom plugins
      dataTools = false;    # Would need to create this category
    };
  };
};
```

**nix-wrapper-modules (explicit module options):**
```nix
# In flake.nix:
nvim-light = nix-wrapper-modules.lib.evalPackage [
  ./module.nix
  { inherit pkgs inputs; enableDataTools = false; }
];

# In module.nix:
specs.general = [ ... ] ++ lib.optionals enableDataTools [
  quarto-nvim
  jupyter-nvim
  # ... data tools
];
```

**Difference:** More explicit control via module parameters instead of category enable/disable.

---

## File Size Comparison

| File | nixCats | nix-wrapper-modules |
|------|---------|---------------------|
| `flake.nix` | 532 lines | 80 lines |
| `module.nix` | (merged in flake) | 180 lines |
| **Total** | **532 lines** | **260 lines** |

**Result:** 51% reduction in code, better organization.

---

## Building Comparison

### nixCats
```bash
# From your project root
nix build                          # Builds default package
nix run                            # Run Neovim directly
nix develop                        # Enter dev shell with nvim

# Creating variants requires editing flake.nix packageDefinitions
```

### nix-wrapper-modules
```bash
# From nix-wrapper-poc/
nix build                          # Builds default (full)
nix build .#nvim-light            # Builds lightweight version
nix run                            # Run Neovim directly
nix develop                        # Enter dev shell with nvim

# Creating variants: just add to flake.nix outputs
```

---

## What Stays the Same

✅ **Your entire Lua configuration** (`lua/`, `init.lua`, `lsp/`)
✅ **Plugin management approach** (lazy.nvim)
✅ **LSP configuration** (native vim.lsp)
✅ **Your workflow** (edit lua files, rebuild)
✅ **The resulting Neovim** (functions identically)

## What Changes

### Better
- ✅ Smaller, more modular flake
- ✅ Standard Nix module system
- ✅ Easier to create variants
- ✅ More composable (`.override`, `.extendModules`)
- ✅ Better documentation (NixOS module docs apply)

### Different
- 🔄 Learn module system instead of categories
- 🔄 Different option names (`extraPackages` vs `lspsAndRuntimeDeps`)
- 🔄 Explicit feature flags instead of category toggles

### Trade-offs
- ⚠️ Newer, less proven
- ⚠️ Smaller community (for now)
- ⚠️ Migration effort required

---

## Example: Adding a New Plugin

### nixCats
```nix
# 1. Add to flake inputs (if custom)
inputs.plugins-new-plugin = { url = "..."; flake = false; };

# 2. Add to categoryDefinitions.startupPlugins
startupPlugins.gitPlugins = [ ... { name = "new-plugin"; plugin = new-plugin; } ];

# 3. Enable in packageDefinitions (already enabled via gitPlugins = true)

# 4. Configure in lua/plugins/new-plugin.lua
```

### nix-wrapper-modules
```nix
# 1. Add to flake inputs (if custom)
inputs.plugins-new-plugin = { url = "..."; flake = false; };

# 2. Add to module.nix specs
specs.gitPlugins = [ ... new-plugin ];

# 3. Configure in lua/plugins/new-plugin.lua
```

**Difference:** One fewer step, no category management needed.

---

## Verdict for Your Config

**Current State:** Your nixCats config is excellent and production-ready.

**Should you migrate?**
- **Not immediately** - your config works great
- **Monitor** nix-wrapper-modules maturity
- **Experiment** with this POC to understand the approach
- **Migrate later** if you need:
  - Multiple Neovim variants
  - Configuration for other programs
  - More derivation control
  - Active development/new features

**This POC gives you:**
- Understanding of the alternative
- Reference for future migration
- Basis for experimenting with new features
