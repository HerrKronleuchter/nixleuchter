{ ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP 41641 -> direct connection to Tailscale network
    useRoutingFeatures = "server"; # for Exit Node / Subnet Router
    authKeyFile = "/var/lib/tailscale/authkey"; # siehe unten
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.178.0/24"
      "--ssh"
    ];
  };

  # Verkehr über das Tailscale-Interface vertrauen
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
