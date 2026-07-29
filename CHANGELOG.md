# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## NEXT VERSION

### Changed
- **NixOS 26.05 update**: Updated nixpkgs pin from `nixos-24.05` to `nixos-26.05`, bringing in Go 1.26.5, glibc-2.42, and the full updated toolchain
- **Static binary**: Added `CGO_ENABLED = "0"` to `package.nix` — the binary is now fully statically linked, eliminating glibc version mismatches for consumers on any NixOS version
- **Go API modernisation**: Replaced deprecated `io/ioutil.WriteFile` with `os.WriteFile`; updated `go.mod` directive to Go 1.26

### Fixed
- Removed broken `nixosModules.default` export that referenced a non-existent `module.nix`
