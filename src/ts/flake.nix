{
  description = "ts development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, self }:
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
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            nodejs_22
            typescript
          ];
        };
      });

      packages = eachSystem (pkgs: {
        default =
          let
            fs = pkgs.lib.fileset;
            root = ./.;
            package-json = builtins.fromJSON (builtins.readFile (root + /package.json));
            exts = [
              "ts"
              "js"
              "json"
              "css"
              "html"
            ];
          in
          pkgs.buildNpmPackage {
            pname = package-json.name;
            inherit (package-json) version;
            src = fs.toSource {
              inherit root;
              fileset = fs.intersection (fs.gitTracked root) (fs.fileFilter (f: builtins.any f.hasExt exts) root);
            };
            npmDepsHash = "";
          };
      });

      apps = eachSystem (
        pkgs:
        pkgs.lib.mapAttrs (_: drv: {
          type = "app";
          program = "${drv}${drv.passthru.exePath or "/bin/${drv.pname or drv.name}"}";
        }) self.packages.${pkgs.stdenv.hostPlatform.system}
      );
    };
}
