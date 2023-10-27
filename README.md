# fast-flake-update

> Written next to a pool in Mahalapye, Botswana.

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

This is conceptually similar to
`nix flake lock --update-input inputA ~/code/inputA` but avoids the round-trip
of pushing to a git remote, and then re-acquiring the git archive. Since this
copies to the store, and uses the same archive format, it results in the same
diff to `flake.lock`.

## Usage

<!-- `$ python ./bin/fast-flake-update --help` -->

```
usage: fast-flake-update [-h] [--rev REV] inputname repo

Update flake.lock with the latest commit of a local checkout

positional arguments:
  inputname   Name of the input in flake.lock to update
  repo        Path to the local checkout

options:
  -h, --help  show this help message and exit
  --rev REV   Revision to use
```

## Example

Let's say you have a project with the following `flake.nix`:

```nix
{
  description = "Your flake with the nixpkgs input";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { ... }: {
    # ...
  };
}
```

Now you can quickly do some commits in your local nixpkgs fork that is located
at `../nixpkgs`. Then you can update your project's flake.lock to the same
commit like that:

```
fast-flake-update nixpkgs ../nixpkgs
```

## Installation

You can run fast-flake-update like this from the repository:

```
nix run github:Mic92/fast-flake-update nixpkgs ../nixpkgs
```
