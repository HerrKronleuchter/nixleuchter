{
  description = "NixOS on Raspberry Pi 5";

  inputs.nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  #inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";

  # nixConfig = {
  #   extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
  #   extra-trusted-public-keys = [
  #     "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
  #   ];
  # };

  outputs =
    { self, nixos-raspberrypi, ... }@inputs:
    {
      nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          { imports = [ nixos-raspberrypi.nixosModules.raspberry-pi-5.base ]; }
          ./modules/hardware.nix
          ./modules/adguard.nix
          ./modules/tailscale.nix
          (
            { pkgs, ... }:
            {
              networking.hostName = "rpi5";

              boot.loader.raspberry-pi.bootloader = "kernel";

              users.users.kronleuchter = {
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

              services = {
                openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = "no";
                    PasswordAuthentication = false;
                  };
                };
                avahi = {
                  enable = true;
                  nssmdns4 = true;
                  publish = {
                    enable = true;
                    addresses = true;
                  };
                };
              };

              environment.systemPackages = with pkgs; [
                git
                vim
                htop
                btop
              ];

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

      formatter = builtins.mapAttrs (
        _system: pkgs: pkgs.nixfmt-tree
      ) nixos-raspberrypi.inputs.nixpkgs.legacyPackages;

      # devShells.${system}.default = pkgs.mkShell {
      #   packages = with pkgs; [
      #     nixfmt
      #     deadnix
      #     statix
      #     nixos-rebuild
      #     nix-tree
      #     nix-diff
      #   ];
      #   shellHook = ''
      #     export TMPDIR=/tmp
      #     echo "Welcome to the NixOS Raspberry Pi 5 development shell!"
      #   '';
      # };
      devShells =
        let
          eachSupportedSystem = nixos-raspberrypi.inputs.nixpkgs.lib.genAttrs supportedSystems;
          supportedSystems = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ];

          mkDevShells =
            system:
            let
              pkgs = import nixos-raspberrypi.inputs.nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
            in
            {
              default = pkgs.mkShell {
                strictDeps = true;
                nativeBuildInputs = with pkgs; [
                  # Nix development
                  deadnix
                  nixd
                  nix-diff
                  nixfmt
                  nixfmt-tree
                  nixos-rebuild
                  statix

                  # Bash development
                  shellcheck
                  shfmt

                  # Visual Studio Code (and plugins)
                  (vscode-with-extensions.override {
                    vscodeExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                      {
                        # https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide
                        publisher = "jnoortheen";
                        name = "nix-ide";
                        version = "0.5.13";
                        sha256 = "sha256-0pMMnYFX+Ghs42Tvfcv9QqwhrEhCjIa7+6xJ51Fa0Dk=";
                      }
                      {
                        # https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck
                        publisher = "timonwong";
                        name = "shellcheck";
                        version = "0.48.1";
                        sha256 = "sha256-c0K5rqbz96OYMYL/+uKs/eeHJ3IrPfhZt+U/X4gSoDQ=";
                      }
                      {
                        # https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt
                        publisher = "mkhl";
                        name = "shfmt";
                        version = "1.5.2";
                        sha256 = "sha256-Mff3ZpxnLp/cEB17T0KGZ4GWG8jN4VxrfR/wIEi2ouM=";
                      }
                      {
                        # https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph
                        publisher = "mhutchie";
                        name = "git-graph";
                        version = "1.30.0";
                        sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
                      }
                    ];
                  })
                ];
                shellHook = ''
                  export TMPDIR=/tmp
                  echo "Welcome to the NixOS Raspberry Pi 5 development shell!"
                '';
              };
            };
        in
        eachSupportedSystem mkDevShells;

      checks = builtins.mapAttrs (_system: pkgs: {
        nixfmt =
          pkgs.runCommand "lint: formatting"
            {
              nativeBuildInputs = [ pkgs.nixfmt-tree ];
            }
            ''
              cd ${inputs.self}
              treefmt --ci
              touch $out
            '';

        statix =
          pkgs.runCommand "lint: statix"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              cd ${inputs.self}
              statix check
              touch $out
            '';

        deadnix =
          pkgs.runCommand "lint: deadnix"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              cd ${inputs.self}
              deadnix --fail
              touch $out
            '';
      }) nixos-raspberrypi.inputs.nixpkgs.legacyPackages;

    };
}
