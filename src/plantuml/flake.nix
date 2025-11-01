{
  description = "plantuml development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      plantumlFiles = [ ];
      fonts = pkgs: [ pkgs.roboto ];

      systems = nixpkgs.lib.platforms.unix;
      inherit (nixpkgs) lib;
      inherit (builtins) length replaceStrings;
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

      fontsConf =
        pkgs:
        pkgs.makeFontsConf {
          fontDirectories = fonts pkgs;
        };
      pumlExt = [
        ".puml"
        ".plantuml"
        ".pu"
      ];
      mapFilesOr =
        f: def: if (length plantumlFiles) == 0 then def else lib.concatMapStringsSep " " f plantumlFiles;
      toWatch = mapFilesOr (f: f) "-r --include '.*\\.p(lant)?u(ml)?$' ./";
      toOpen =
        pkgs:
        mapFilesOr (
          f: (replaceStrings pumlExt (lib.replicate 3 ".png") f)
        ) ''$(${pkgs.toybox}/bin/find . -type f -iname \*.png)'';
      watchCmd = pkgs: ''
        ${pkgs.inotify-tools}/bin/inotifywait -m --format '%f' -e create -e modify ${toWatch} |
        	while read -r file; do
            ${pkgs.plantuml}/bin/plantuml "$file"
        	done
      '';
      openCmd = pkgs: "${pkgs.feh}/bin/feh ${toOpen pkgs}";
      mkScript =
        pkgs: name: text:
        pkgs.writeShellApplication {
          excludeShellChecks = [ "SC2046" ];
          inherit text;
          name = "${name}-puml";
        };
      watchScript = pkgs: mkScript pkgs "watch" "${watchCmd pkgs}";
      openScript = pkgs: mkScript pkgs "open" "${openCmd pkgs}";
      # FIXME: watch-puml doesn't get killed if open-puml dies
      devScript =
        pkgs:
        mkScript pkgs "dev"
          "(trap 'kill 0' SIGINT; ${watchScript pkgs}/bin/watch-puml & ${openScript pkgs}/bin/open-puml)";
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            (watchScript pkgs)
            (openScript pkgs)
            (devScript pkgs)
            pkgs.plantuml
          ];
          FONTCONFIG_FILE = "${fontsConf pkgs}";
        };
        server = pkgs.mkShellNoCC {
          packages = with pkgs; [
            (watchScript pkgs)
            (openScript pkgs)
            (devScript pkgs)
            plantuml
            plantuml-server
          ];
          FONTCONFIG_FILE = "${fontsConf pkgs}";
        };
      });
    };
}
