#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixos-rebuild

cd ~/.config/dotfiles

sudo nixos-rebuild switch --flake .#
