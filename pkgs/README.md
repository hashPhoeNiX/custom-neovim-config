# Custom Packages

This directory contains custom Nix package definitions for tools not available in nixpkgs.

## Structure

- `default.nix` - Main entry point that exports all custom packages
- `dbt-language-server.nix` - dbt Language Server (LSP for dbt)

## Adding New Packages

1. Create a new file: `pkgs/my-package.nix`
2. Define the package:
   ```nix
   { pkgs }:

   pkgs.stdenv.mkDerivation {
     pname = "my-package";
     version = "1.0.0";
     # ... package definition
   }
   ```
3. Add to `pkgs/default.nix`:
   ```nix
   my-package = pkgs.callPackage ./my-package.nix { };
   ```
4. Use in `flake.nix` - it will be available automatically through the overlay

## Packages

### dbt-language-server

Language Server Protocol (LSP) implementation for dbt.

- **Version**: 0.3.0
- **Source**: https://github.com/j-clemons/dbt-language-server
- **Features**: Code completion, hover docs, go-to-definition, find references
- **Used for**: Native Neovim LSP support for dbt files

To update the version:
1. Download new binary version hash: `nix-prefetch-url <url>`
2. Update `sha256` in `dbt-language-server.nix`
3. Update `version` field
