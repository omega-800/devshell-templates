{
  description = "zig development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls-overlay = {
      url = "github:omega-800/zls-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      zig-overlay,
      zls-overlay,
      ...
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
      version = "0.14.0";
    in
    {

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            zig-overlay.packages.${pkgs.system}."${version}"
            zls-overlay.packages.${pkgs.system}."${version}"
            pkgs.lldb
          ];
        };
      });

      /*
        TODO:
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
      */
    };
}
