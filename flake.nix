{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # Code formatting tools
        treefmt
        alejandra
        mdl
        typos

        # Rust toolchain
        rustup
        probe-rs-tools
      ];
    };
  };
}
