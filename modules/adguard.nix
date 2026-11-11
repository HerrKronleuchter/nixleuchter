_: {
  services.adguardhome = {
    enable = true;
    # You can select any ip and port, just make sure to open firewalls where needed
    host = "0.0.0.0";
    port = 3003;
    openFirewall = true;
    mutableSettings = false; # Settings are overwritten on every rebuild
    settings = {
      users = [
        {
          name = "kronleuchter";
          password = "$2y$10$WrolsmZWxuinSxFW94MuQ.hP1O.pK2UWZNEsoM3FF8SEUQ0L1tsPm";
        }
      ];
      dns = {
        bind_hosts = [
          "0.0.0.0"
          "::"
        ];
        port = 53;
        upstream_dns = [
          "tls://dns.digitale-gesellschaft.ch"
          "tls://dns.quad9.net"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters =
        map
          (url: {
            enabled = true;
            inherit url;
          })
          [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://v.firebog.net/hosts/Easylist.txt"
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt"
          ];
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    nameservers = [
      "127.0.0.1"
      "9.9.9.9"
    ];
  };

  services.resolved.enable = false;

}
