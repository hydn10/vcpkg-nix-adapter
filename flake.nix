{
  description = "Map vcpkg dependencies to caller-provided Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      #nixFormatter = nixpkgs.nixfmt-tree;
    in
    {
      lib = import ./lib;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./tests {
            inherit pkgs;
            adapter = self.lib;
          };

          nix-format = self.formatter.${system}.check self;
        }
      );
    };
}
