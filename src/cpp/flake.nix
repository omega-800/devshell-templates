{
  description = "c++ development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
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
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
          packages = with pkgs; [
            cmake
            pkg-config
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
          default = pkgs.mkDerivation {
            inherit pname;
            version = "0.0.1";
            src = fs.toSource {
              inherit root;
              fileset = fs.intersection (fs.gitTracked root) (
                fs.unions [
                  (fs.fileFilter (f: f.hasExt "cpp" || f.hasExt "hpp") ./src)
                ]
              );
            };
          };
        }
      );
      apps = eachSystem (
        pkgs:
        pkgs.lib.mapAttrs (_: drv: {
          type = "app";
          program = "${drv}${drv.passthru.exePath or "/bin/${drv.pname or drv.name}"}";
        }) self.packages.${pkgs.stdenv.hostPlatform.system}
      );
    };
}
