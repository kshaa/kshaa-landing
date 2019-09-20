with import <nixpkgs> {};

{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:

let
  inherit (pkgs.stdenv) mkDerivation;
  inherit (import (builtins.fetchTarball "https://github.com/hercules-ci/gitignore/archive/master.tar.gz") { }) gitignoreSource;
in rec {
  derivation = stdenv.mkDerivation {
    src = gitignoreSource ./.;
    name = "kshaa-landing-app";
    description = "Kshaa landing project code";
    installPhase = ''
      mkdir -p $out/
      cp -a * $out/
    '';
  };
}