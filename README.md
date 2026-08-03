# vcpkg-nix-adapter

`vcpkg-nix-adapter` is a small Nix library for projects that describe their dependencies in `vcpkg.json` but want to consume corresponding Nix packages.

It reads the manifest, preserves dependency metadata, and lets the caller map each external vcpkg dependency to a Nix package. The resulting package groups can be used in shells, derivations, or other Nix expressions.

## Scope

This is a mapping layer, not a replacement for vcpkg. The caller provides the package mappings and remains responsible for choosing Nix packages.

- Root dependencies and project features are exposed separately.
- Host and target dependencies are split into separate package groups.
- Missing or stale mappings fail during evaluation.
- Version constraints, default-feature resolution, feature closure, and platform expressions are not evaluated.
- Dependency feature lists currently use string feature names.

## Usage

Add the flake as an input and map the names from your `vcpkg.json`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    vcpkg-nix-adapter = {
      url = "github:hydn10/vcpkg-nix-adapter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vcpkg-nix-adapter }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      adapter = vcpkg-nix-adapter.lib;

      mapped = adapter.mapDependencies {
        vcpkgJson = ./vcpkg.json;
      } {
        fmt = _: pkgs.fmt;
        cmake = _: pkgs.cmake;
      };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = mapped.allPackages;
      };
    };
}
```

Mapping functions receive normalized dependency records, including the dependency name, host flag, requested features, version constraint, and declaration context. Mapping keys must match every external dependency found in the manifest.

To use only selected project features, select them explicitly:

```nix
let
  selected = mapped.selectProjectFeatures [ "tools" ];
in
  selected.allPackages
```

For manifest inspection without package mappings, use `parseManifest` directly.
