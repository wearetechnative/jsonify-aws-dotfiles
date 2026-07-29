## Why

The flake is pinned to `nixos-24.05` (glibc-2.39), which causes version mismatches when consumers run a newer NixOS release — particularly visible as unexpected glibc-2.39 binaries on systems running nixos-26.05. Additionally, `main.go` uses the deprecated `io/ioutil` API that generates warnings under newer Go toolchains shipped with nixos-26.05.

## What Changes

- Update `flake.nix` nixpkgs input from `nixos-24.05` to `nixos-26.05`
- Regenerate `flake.lock` to match the new nixpkgs pin
- Add `CGO_ENABLED = "0"` to `package.nix` so the binary is fully statically linked (eliminates glibc version dependency for all consumers)
- Replace deprecated `io/ioutil.WriteFile` with `os.WriteFile` in `main.go`
- Update `go.mod` Go directive to match the Go version shipped with nixos-26.05
- Remove the broken `nixosModules.default = import ./module.nix self` reference from `flake.nix` (`module.nix` does not exist)

## Capabilities

### New Capabilities
<!-- None — this is a pure tooling/infra update with no new user-visible behavior -->

### Modified Capabilities
<!-- None — tool behavior is unchanged -->

## Impact

- **`flake.nix`**: nixpkgs pin updated, broken nixosModules reference removed
- **`flake.lock`**: regenerated via `nix flake update`
- **`package.nix`**: adds `CGO_ENABLED = "0"` and updated `vendorHash` (must be recomputed after any dep changes)
- **`main.go`**: `io/ioutil` import replaced with `os`
- **`go.mod`**: Go directive version bumped to match nixos-26.05 toolchain
- **Breaking**: `nixosModules.default` is removed — any consumer importing it will break (but the module never worked since `module.nix` was missing)
