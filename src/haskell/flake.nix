{
  description = "haskell development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          )
        );
      pname = "";
    in
    {
      devShells = eachSystem (
        pkgs:
        let
          stack-wrapped = pkgs.symlinkJoin {
            name = "stack";
            paths = [ pkgs.stack ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/stack \
                --add-flags "\
                  --nix \
                  --no-nix-pure \
                  --system-ghc \
                  --no-install-ghc \
                "
            '';
          };
          buildInputs = with pkgs; [
            ghcid
            stack-wrapped
            (ghc.withPackages (
              p: with p; [
                haskell-language-server
              ]
            ))
          ];
        in
        {
          default = pkgs.mkShellNoCC {
            inherit buildInputs;
            NIX_PATH = "nixpkgs=" + pkgs.path;
          };
        }
      );

      packages = eachSystem (
        pkgs:
        let
          fs = pkgs.lib.fileset;
          root = ./.;
        in
        {
          default = pkgs.haskell.lib.buildStackProject {
            inherit (pkgs) ghc;
            name = pname;
            src = fs.toSource {
              inherit root;
              fileset = fs.intersection (fs.gitTracked root) (
                fs.unions [
                  ./stack.yaml
                  ./stack.yaml.lock
                  ./package.yaml
                  (fs.fileFilter (f: f.hasExt "hs") ./src)
                ]
              );
            };
          };
        }
      );

      apps = eachSystem (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/${pname}";
        };
      });
    };
}
