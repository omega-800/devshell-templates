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

      templates = lib.mapAttrs (n: _: {
        path = ./src/${n};
        /*
          "${fs.toSource {
                      root = ./.;
                      fileset = fs.unions [
                        ./.envrc
                        ./src/${n}
                      ];
                    }}";
        */
        description = "${n} development environment";
      }) (builtins.readDir ./src);
    };
}
