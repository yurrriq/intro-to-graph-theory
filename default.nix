let

  fetchTarballFromGitHub =
    { owner, repo, rev, sha256, ... }:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/tarball/${rev}";
      inherit sha256;
    };

  fromJSONFile = f: builtins.fromJSON (builtins.readFile f);

in

{ nixpkgs ? fetchTarballFromGitHub (fromJSONFile ./nixpkgs-src.json) }:

with import nixpkgs {
  overlays = [
    (self: super: {
      xelatex = super.texlive.combine {
        inherit (super.texlive) scheme-small
          braket
          datatool
          ebproof
          glossaries
          hardwrap
          latexmk
          # mathpazo
          mfirstuc
          # microtype
          # palatino
          substr
          titlesec
          tkz-base
          tkz-berge
          tkz-graph
          todonotes
          tufte-latex
          xetex
          xindy
          xfor;
      };
    })
  ];
};

let

  my-ghc = haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
    algebraic-graphs
    # algebraic-graphs_0_3
    # containers
    # hgal
  ]);

in

{

  drv = stdenv.mkDerivation rec {
    name = "intro-to-graph-theory-${version}";
    version = "0.2.7.0";
    src = ./.;

    buildInputs = [
      xelatex
    ];

    installPhase = ''
      install -Dm755 src/exercises.pdf "$out/exercises.pdf"
    '';

    meta = with stdenv.lib; {
      description = "Into to Graph Theory";
      longDescription = ''
        Working through exercises in "Introduction to Graph Theory"
        by Richard J. Trudeau.
      '';
      homepage = https://github.com/yurrriq/intro-to-graph-theory;
      license = licenses.unlicense;
      maintainers = with maintainers; [ yurrriq ];
      platforms = platforms.all;
    };
  };

  shell = mkShell {
    buildInputs = [
      gnumake
      hlint
      my-ghc
      qpdfview
      xelatex
    ];
  };

}
