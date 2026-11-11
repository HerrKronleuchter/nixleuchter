{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP 41641 -> direct connection to Tailscale network
    useRoutingFeatures = "server"; # for Exit Node / Subnet Router
    authKeyFile = pkgs.writeText "ts-authkey" "tskey-auth-blablablawurstsalat"; # Single use auth key for Tailscale auth, replace with your own key
    extraUpFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.178.0/24"
      "--ssh"
    ];
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.178.0/24"
      "--ssh"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
