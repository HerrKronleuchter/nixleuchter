{ pkgs, ... }:
{

  boot.loader.raspberry-pi.bootloader = "kernel";

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
    vim
    btop
  ];

  nix.settings = {
    # Enable flakes
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

}
