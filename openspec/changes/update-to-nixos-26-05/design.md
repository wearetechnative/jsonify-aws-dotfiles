## Context

The repo currently pins `nixpkgs/nixos-24.05` in `flake.nix`. nixos-24.05 ships glibc-2.39 and Go 1.22. When used as a flake input, the package is always built against the flake's own nixpkgs — not the consumer's — so consumers on newer NixOS releases see a glibc-2.39 binary regardless of their system's glibc version. See proposal.md for motivation.

`main.go` uses `io/ioutil` (deprecated since Go 1.16); the Go toolchain shipped with nixos-26.05 will warn on this. `flake.nix` references a `module.nix` that has never existed.

## Goals / Non-Goals

**Goals:**
- Pin nixpkgs to `nixos-26.05` so the package builds with the current stable toolchain
- Produce a fully statically-linked binary (no glibc dependency) so the tool runs on any Linux regardless of NixOS version
- Remove the `io/ioutil` deprecation warning
- Remove the dead `nixosModules.default` reference

**Non-Goals:**
- No behavior changes to the tool itself
- No new NixOS module — `nixosModules.default` is removed, not implemented
- No goreleaser or CI pipeline changes

## Decisions

### 1. Static linking via `CGO_ENABLED = "0"`

`buildGoModule` in nixpkgs enables CGo by default. With CGo on, the binary links against libc (for NSS lookups in `os/user`). With `CGO_ENABLED = "0"`, Go uses its pure-Go fallbacks — `os/user.Current()` reads `/etc/passwd` directly, which is correct for normal Linux systems.

**Alternatives considered:**
- `pkgsStatic.callPackage` — musl-based static build; heavier approach, breaks binary cache interop, not needed since CGo isn't required functionally.
- Leave dynamic — perpetuates the glibc version problem for all consumers.

### 2. Remove `nixosModules.default`, don't implement it

The reference `import ./module.nix self` is broken (file never existed). Implementing a NixOS module is out of scope. Removing it is safer than silently leaving a broken export.

**Alternatives considered:**
- Stub `module.nix` with `{}` — deceptive, consumers might silently depend on an empty module.

### 3. `vendorHash` recomputation

After bumping the nixpkgs pin and potentially updating Go deps, the `vendorHash` in `package.nix` must be recomputed. The standard workflow: set `vendorHash = "";`, run `nix build`, copy the expected hash from the error output.

## Risks / Trade-offs

- **`nixosModules.default` removal is breaking** — any consumer importing it via `inputs.jsonify-aws-dotfiles.nixosModules.default` will get an attribute error. Risk is low since the module was always broken (referencing a missing file), so no consumer could have been using it successfully.
- **Pure-Go `os/user` behavior** — on systems without `/etc/passwd` (containers, exotic setups) `user.Current()` may fail with CGo off. Risk is the same as before since the tool already panics on this path.
- **`vendorHash` requires a build step** — this cannot be pre-computed without running `nix build`. Tasks must account for this iterative step.

## Migration Plan

1. Edit `flake.nix`: update nixpkgs URL, remove nixosModules line
2. Edit `package.nix`: add `CGO_ENABLED = "0"`, set `vendorHash = ""`
3. Edit `main.go`: replace `io/ioutil`
4. Edit `go.mod`: bump `go` directive
5. Run `nix flake update` to regenerate `flake.lock`
6. Run `nix build` — copy correct `vendorHash` from error, update `package.nix`
7. Run `nix build` again — verify it succeeds and the binary runs
