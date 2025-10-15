{
  description = "haskell development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 

  outputs =
    { self, nixpkgs }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem =
        f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
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
        in
        {
          default = pkgs.haskell.lib.buildStackProject {
            inherit (pkgs) ghc;
            name = pname;
            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./src/Main.hs
                ./stack.yaml
                ./stack.yaml.lock
                ./package.yaml
              ];
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
