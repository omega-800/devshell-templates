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
    in
    {
      overlays.default = final: prev: {
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
    };
}
