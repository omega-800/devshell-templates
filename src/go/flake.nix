{
  description = "go development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      pname = "";
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            go
            gotools
            golangci-lint
          ];
        };
      });

      packages = eachSystem (
        pkgs:
        let
          fs = pkgs.lib.fileset;
          root = ./.;
        in
        {
          default = pkgs.buildGoModule {
            inherit pname;
            version = "0.0.1";
            vendorHash = null;
            src = fs.toSource {
              inherit root;
              fileset = fs.intersection (fs.gitTracked root) (
                fs.unions [
                  ./go.mod
                  (fs.fileFilter (f: f.hasExt "go") ./src)
                  (fs.fileFilter (f: f.hasExt "go") ./.)
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
