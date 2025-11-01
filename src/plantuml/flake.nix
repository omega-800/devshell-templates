{
  description = "plantuml development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      pumlLib =
        pkgs:
        let
          ### config

          plantumlFiles = [ ];
          fonts = [ ];

          ### lib

          inherit (pkgs) lib;
          inherit (builtins) length replaceStrings;
          fontsConf = pkgs.makeFontsConf {
            fontDirectories = fonts;
          };
          pumlExt = [
            ".puml"
            ".plantuml"
            ".pu"
          ];
          mapFilesOr =
            f: def: if (length plantumlFiles) == 0 then def else lib.concatMapStringsSep " " f plantumlFiles;
          toWatch = mapFilesOr (f: f) "-r --include '.*\\.p(lant)?u(ml)?$' ./";
          toOpen = mapFilesOr (
            f: (replaceStrings pumlExt (lib.replicate 3 ".png") f)
          ) ''$(${pkgs.toybox}/bin/find . -type f -iname \*.png)'';
          toCompile =
            mapFilesOr (f: f)
              ''$(${pkgs.toybox}/bin/find . -type f \( ${
                lib.concatMapStringsSep " -o " (e: "-iname \\*${e}") pumlExt
              } \))'';
          mkScript =
            name: text:
            pkgs.writeShellApplication {
              excludeShellChecks = [ "SC2046" ];
              inherit text;
              name = "${name}-puml";
            };
          watchScript = mkScript "watch" ''
            ${pkgs.inotify-tools}/bin/inotifywait -m --format '%f' -e create -e modify ${toWatch} |
            	while read -r file; do
                ${pkgs.plantuml}/bin/plantuml "$file"
            	done
          '';
          openScript = mkScript "open" "${pkgs.feh}/bin/feh ${toOpen}";
          # FIXME: watch-puml doesn't get killed if open-puml dies
          devScript =
            mkScript "dev" "(trap 'kill 0' SIGINT; ${watchScript}/bin/watch-puml & ${openScript}/bin/open-puml)";
          compileScript = mkScript "compile" "${pkgs.plantuml}/bin/plantuml ${toCompile}";
        in
        {
          inherit
            watchScript
            openScript
            devScript
            compileScript
            fontsConf
            ;
        };

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
      devShells = eachSystem (
        pkgs:
        let
          inherit (pumlLib pkgs)
            watchScript
            openScript
            devScript
            compileScript
            fontsConf
            ;
          scripts = [
            watchScript
            openScript
            devScript
            compileScript
          ];
        in
        {
          default = pkgs.mkShellNoCC {
            packages = scripts ++ [
              pkgs.plantuml
            ];
            FONTCONFIG_FILE = "${fontsConf}";
          };
          server = pkgs.mkShellNoCC {
            packages =
              scripts
              ++ (with pkgs; [
                plantuml
                plantuml-server
              ]);
            FONTCONFIG_FILE = "${fontsConf}";
          };
        }
      );
    };
}
