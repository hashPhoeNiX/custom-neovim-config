# Custom packages for nixCats Neovim
{ pkgs }:

{
  dbt-language-server = pkgs.callPackage ./dbt-language-server.nix { };
}
