# nix-wrapper-modules Proof of Concept

This directory demonstrates how your nixCats configuration would look when migrated to nix-wrapper-modules.

## Key Differences from nixCats

### 1. **Simpler Flake Structure**

**nixCats** (your current setup):
- ~530 lines in `flake.nix`
- `categoryDefinitions` (complex function)
- `packageDefinitions` (complex function)
- Custom category system

**nix-wrapper-modules** (this POC):
- ~80 lines in `flake.nix` (just inputs and outputs)
- Most config moved to `module.nix`
- Uses standard Nix module system

### 2. **Module System Instead of Categories**

**nixCats categories:**
```nix
categoryDefinitions = { pkgs, ... }: {
  lspsAndRuntimeDeps.general = [ ripgrep fd ];
  startupPlugins.general = [ telescope-nvim ];
  python3.libraries = (ps: [ pynvim ]);
};

packageDefinitions = {
  nvim = { pkgs, ... }: {
    categories = { general = true; };
  };
};
```

**nix-wrapper-modules options:**
```nix
# module.nix
{
  specs.general = [ telescope-nvim ];
  extraPackages = [ ripgrep fd ];
  extraPython3Packages = ps: [ ps.pynvim ];
}
```

### 3. **Multiple Variants Made Easy**

Create different Neovim configs easily:

```nix
# In flake.nix
nvim-full = nix-wrapper-modules.lib.evalPackage [
  ./module.nix
  { inherit pkgs inputs; enableDataTools = true; }
];

nvim-light = nix-wrapper-modules.lib.evalPackage [
  ./module.nix
  { inherit pkgs inputs; enableDataTools = false; }
];
```

### 4. **Your Lua Config Stays Identical**

The `lua/` directory, `init.lua`, and all your Neovim configuration remain **exactly the same**. You still:
- Configure in Lua
- Use lazy.nvim
- Query categories (if needed) with `nixCats()`

### 5. **Better Composability**

```nix
# Override specific parts
myNvim = nvim.override {
  extraPackages = old: old ++ [ pkgs.jq ];
};

# Extend with more modules
myNvim = nvim.extendModules {
  modules = [
    { specs.extra = [ pkgs.vimPlugins.some-plugin ]; }
  ];
};
```

## Building and Testing

### Build the package

```bash
cd nix-wrapper-poc
nix build
./result/bin/nvim
```

### Try in a development shell

```bash
nix develop
nvim
```

### Build the lightweight variant

```bash
nix build .#nvim-light
./result/bin/nvim
```

## Migration Strategy

If you decide to migrate, here's a gradual approach:

### Phase 1: Side-by-side (Current)
- Keep your nixCats config working
- Test nix-wrapper-modules in this subdirectory
- Compare behavior

### Phase 2: Feature Parity
1. Migrate all plugins from `categoryDefinitions.startupPlugins`
2. Migrate all LSPs/tools from `categoryDefinitions.lspsAndRuntimeDeps`
3. Migrate Python/Lua packages
4. Test all functionality

### Phase 3: Advanced Features
1. Experiment with multiple package variants
2. Create custom module options
3. Use derivation hooks if needed
4. Export as overlay for use in other flakes

### Phase 4: Full Migration (Optional)
1. Replace root `flake.nix` with nix-wrapper-modules version
2. Archive old nixCats config as reference
3. Update build commands

## Advantages You'd Gain

1. **Standard Module System**
   - Use familiar Nix patterns
   - Better documentation (NixOS module system)
   - More flexible composition

2. **Reduced Complexity**
   - No custom category system to learn
   - Clearer separation of concerns
   - Less boilerplate

3. **Better Multi-Package Support**
   - Easily create variants (light, full, specialized)
   - Share configuration between packages
   - Conditional features via module options

4. **Future-Proof**
   - Active development
   - Community momentum (aiming for nix-community)
   - May land in nixpkgs eventually

5. **Derivation Control**
   - Full access to wrapper derivation
   - Custom build hooks
   - Multiple wrapper backends

## Disadvantages/Considerations

1. **Newer Project**
   - Less battle-tested than nixCats
   - Documentation still evolving
   - Smaller user base

2. **Different Paradigm**
   - Need to learn module system (if unfamiliar)
   - Different mental model from categories

3. **Migration Effort**
   - Takes time to convert
   - Need to test thoroughly
   - Lose nixCats-specific features/helpers

## Recommendation

**For your use case:**
- ✅ Your nixCats config works great
- ✅ You're not hitting limitations
- ✅ Stability matters for data work

**Verdict:** **Stay with nixCats for now**, but:
- Keep this POC to understand the alternative
- Monitor nix-wrapper-modules development
- Consider migrating when:
  - You need multiple Neovim variants
  - You want to configure other programs the same way
  - The project reaches nix-community

## Comparing Both Approaches

| Aspect | nixCats | nix-wrapper-modules |
|--------|---------|---------------------|
| **Maturity** | Stable, proven | Newer, evolving |
| **Scope** | Neovim only | Any program |
| **Config System** | Custom categories | Nix modules |
| **Flake Size** | Large (~530 lines) | Small (~80 lines) |
| **Learning Curve** | nixCats-specific | Standard Nix modules |
| **Multi-package** | Possible but verbose | Designed for it |
| **Control** | Good | More granular |
| **Community** | Established | Growing |

## Questions?

Compare:
- `../flake.nix` (your current nixCats)
- `./flake.nix` (this POC)
- `./module.nix` (where the magic happens)

Notice how the Lua config in `../lua/` doesn't need to change at all!
