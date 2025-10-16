{
  description = "Devshell templates";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      fs = lib.fileset;
      systems = lib.platforms.unix;
      eachSystem = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC { };
      });

      templates =
        let
          files = builtins.readDir ./src;
        in
        (lib.mapAttrs (n: _: {
          path = "${fs.toSource {
            root = ./src/${n};
            fileset = fs.fileFilter (f: !(f.hasExt "lock")) ./src/${n};
          }}";
          description = "${n} development environment";
        }) files)
        // lib.mapAttrs' (
          n: _:
          lib.nameValuePair "${n}-lock" {
            path = ./src/${n};
            description = "${n} development environment with flake.lock";
          }
        ) files;
    };
}
