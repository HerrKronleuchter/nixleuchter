{
  description = "NixOS on Raspberry Pi 5";

  inputs.nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    { self, nixos-raspberrypi, ... }@inputs:
    {
      nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          { imports = [ nixos-raspberrypi.nixosModules.raspberry-pi-5.base ]; }
          ./hardware.nix
          (
            { pkgs, ... }:
            {
              networking.hostName = "rpi5";

              boot.loader.raspberry-pi.bootloader = "kernel";

              services.openssh.enable = true;
              users.users.root.openssh.authorizedKeys.keys = [
                "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAb6rbZq2Yi1KYq5UmPxcKx/nTTzM/o7RvrbWihB7o8kgdzMXnJIasJC35c2fg+gvxe/uI5I2YhmNhxazreoJwaeQE+DLbX0QIGr1Al86sMIhrPrsIxvgRlQvSPC2BEMJvLJuCOo4d0cj3RWXfH6zl/qDGUZbWcACjTy5CMROtjezVXGg== kronleuchter"
              ];
              users.users.kronleuchter = {
                # # TODO_ user zusammenfassen
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ];
                openssh.authorizedKeys.keys = [
                  "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAb6rbZq2Yi1KYq5UmPxcKx/nTTzM/o7RvrbWihB7o8kgdzMXnJIasJC35c2fg+gvxe/uI5I2YhmNhxazreoJwaeQE+DLbX0QIGr1Al86sMIhrPrsIxvgRlQvSPC2BEMJvLJuCOo4d0cj3RWXfH6zl/qDGUZbWcACjTy5CMROtjezVXGg== kronleuchter"
                ];
              };
              security.sudo.wheelNeedsPassword = false;

              services.openssh.settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };

              services.avahi = {
                # TODO_ services zusammenfassen
                enable = true;
                nssmdns4 = true;
                publish = {
                  enable = true;
                  addresses = true;
                };
              };

              environment.systemPackages = with pkgs; [
                git
                vim
                htop
                btop
              ];
              # nix.settings.experimental-features = [
              #   "nix-command"
              #   "flakes"
              # ];
              # nix.settings.trusted-users = [
              #   "root"
              #   "@wheel"
              # ]; #### TODO settings zusammenfassen

              nix.settings = {
                # Enable flakes
                extra-experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                # Enable non-root users to use nix commands
                trusted-users = [
                  "root"
                  "@wheel"
                ];
              };

              system.stateVersion = "26.05";
            }
          )
        ];
      };
    };
}
