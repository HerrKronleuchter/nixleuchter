# NixOS on Raspberry Pi

This repository contains a NixOS flake for running a Raspberry Pi-based homeserver. It is built on top of the upstream [nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi) flake and configures a small, self-hosted network stack for a Pi 5 and a Pi 4 variant.

## Overview

The flake defines two NixOS configurations:

- `rpi5`: a Raspberry Pi 5 configuration used as the primary home server (used this as testing device)
- `home-pi4`: a Raspberry Pi 4 configuration with the same base setup

The shared system config is split into reusable modules:

- `configuration.nix`: base system settings, OpenSSH, Avahi, and installed packages
- `modules/hardware.nix`: SD card and firmware partition layout for Raspberry Pi
- `modules/iam.nix`: local user setup and sudo policy
- `modules/adguard.nix`: AdGuard Home DNS service with filtering enabled
- `modules/tailscale.nix`: Tailscale node setup with exit node and subnet routing

## Included services

- AdGuard Home for DNS filtering and ad blocking
- Tailscale for secure remote access and mesh networking
- SSH access for administration
- Avahi mDNS publishing for local discovery



## Rebuild commands

When deploying to a remote Raspberry Pi, the usual pattern is:

```bash
nixos-rebuild switch --flake .#home-pi4 \
--target-host kronleuchter@<ipadressofpi> \
--build-host kronleuchter@<ipadressofpi> \
--sudo
```

## Important notes

Before using this config in a real environment, review and adjust:

- the Tailscale auth key in `modules/tailscale.nix`
    - I recommend to use a one time key here, this will be stored public readable in the nix store.
- the AdGuard admin password in `modules/adguard.nix`
    - create a passwd with ```htpasswd -nBC 10 "" | cut -d: -f2```
- the authorized SSH key and user setup in `modules/iam.nix`


## References

- Upstream project: https://github.com/nvmd/nixos-raspberrypi



