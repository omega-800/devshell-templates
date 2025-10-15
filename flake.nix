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

      templates = lib.mapAttrs' (
        n: _:
        let
          name = lib.removeSuffix ".nix" n;
        in
        lib.nameValuePair name {
          path = fs.toSource {
            root = ./.;
            fileset = fs.unions [
              ./.envrc
              ./src/${n}
            ];
          };
          description = "${name} development environment";
        }
      ) (builtins.readDir ./src);
    };
}
