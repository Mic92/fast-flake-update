# fast-flake-update

This tool improves the _efficiency_ of updating flake inputs in
[nix](https://nixos.org) from local git repository checkouts.

When using `nix flake update` with inputs from GitHub or GitLab, the entire
archive needs to be re-downloaded for every commit change. This process becomes
especially slow for repositories like
[nixpkgs](https://github.com/NixOS/nixpkgs).

`fast-flake-update` uses of a local git checkout for updating the flake lock.
Additionally, it adds the checkout to the nix store. This approach allows for
faster iterations when testing changes, significantly improving development
efficiency.
