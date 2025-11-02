{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "dbt-language-server";
  version = "0.3.0";

  src = pkgs.fetchurl {
    url = "https://github.com/j-clemons/dbt-language-server/releases/download/v0.3.0/dbt-language-server-darwin-arm64";
    sha256 = "138gcyqns7x3bcgbj88mmi67ps0d6n94my8pr2az3ld1ir8xm1az";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/dbt-language-server
    chmod +x $out/bin/dbt-language-server
  '';

  meta = with pkgs.lib; {
    description = "Language Server for dbt";
    homepage = "https://github.com/j-clemons/dbt-language-server";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
