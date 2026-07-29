## 1. Nix Configuration

- [x] 1.1 Update `flake.nix`: change nixpkgs URL from `nixpkgs/nixos-24.05` to `nixpkgs/nixos-26.05`
- [x] 1.2 Remove the broken `nixosModules.default = import ./module.nix self;` line from `flake.nix`
- [x] 1.3 Add `env.CGO_ENABLED = "0";` to `package.nix` to produce a statically-linked binary
- [x] 1.4 Set `vendorHash = "";` in `package.nix` to force recomputation

## 2. Go Source Updates

- [x] 2.1 Replace `"io/ioutil"` import with `"os"` in `main.go`
- [x] 2.2 Replace `ioutil.WriteFile(...)` call with `os.WriteFile(...)` in `main.go`
- [x] 2.3 Update the `go` directive in `go.mod` to match the Go version shipped with nixos-26.05

## 3. Lock File and Hash Recomputation

- [x] 3.1 Run `nix flake update` to regenerate `flake.lock` against nixos-26.05
- [x] 3.2 Run `nix build` and copy the expected `vendorHash` from the error output into `package.nix`
- [x] 3.3 Run `nix build` again and verify it succeeds

## 4. Verification

- [x] 4.1 Run the built binary with `--help` and confirm it exits cleanly
- [x] 4.2 Run the built binary against actual `~/.aws/config` and `~/.aws/credentials` and confirm JSON output is correct
- [x] 4.3 Verify the binary is statically linked: `ldd result/bin/jsonify-aws-dotfiles` should output "not a dynamic executable"
