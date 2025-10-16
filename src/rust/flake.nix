{
  description = "rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      pname = "";
    in
    {
      overlays.default = _: prev: {
        rustToolchain = prev.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
          ];
        };
      };
      devShells = eachSystem (
        pkgs:
        let
          rustPkgs = import nixpkgs {
            inherit (pkgs) system;
            overlays = [
              rust-overlay.overlays.default
              self.overlays.default
            ];
          };
        in
        {
          default = rustPkgs.mkShellNoCC {
            packages = with rustPkgs; [
              rustToolchain
              openssl
              pkg-config
              cargo-deny
              cargo-edit
              cargo-watch
              rust-analyzer
            ];
            env = {
              RUST_BACKTRACE = 1;
              RUST_SRC_PATH = "${rustPkgs.rustToolchain}/lib/rustlib/src/rust/library";
            };
          };
        }
      );
      packages = eachSystem (
        pkgs:
        let
          fs = pkgs.lib.fileset;
          root = ./.;
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            inherit pname;
            version = "0.0.1";
            src = fs.toSource {
              inherit root;
              fileset = fs.intersection (fs.gitTracked root) (
                fs.unions [
                  ./Cargo.toml
                  ./Cargo.lock
                  (fs.fileFilter (f: f.hasExt "rs") ./src)
                ]
              );
            };
            cargoLock.lockFile = ./Cargo.lock;
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
