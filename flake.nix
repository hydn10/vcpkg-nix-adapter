{
  description = "Map vcpkg dependencies to caller-provided Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    lib = import ./lib;

    checks = nixpkgs.lib.genAttrs
      [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ]
      (system: {
        default = import ./tests {
          pkgs = nixpkgs.legacyPackages.${system};
          adapter = self.lib;
        };
      });
  };
}
