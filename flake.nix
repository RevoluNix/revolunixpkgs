{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = inputs @ { self, nixpkgs }: let
    defaultSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
 
    forAllSystems = function:
      nixpkgs.lib.genAttrs defaultSystems
      (system: function nixpkgs.legacyPackages.${system});
    in {
      nixosModules = {
        auto-passthrough = import ./modules/auto-passthrough.nix;
        default = self.nixosModules.auto-passthrough;
      };

      overlays.default = (final: prev:
        (self.packages."x86_64-linux"));

      packages = forAllSystems (pkgs:
        let
          scope = pkgs.lib.makeScope
            pkgs.newScope (self: { inherit inputs; });
        in
        pkgs.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (scope) callPackage;
          directory = ./pkgs/by-name;
        });
    };
}
