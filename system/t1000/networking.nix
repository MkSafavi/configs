{ config, pkgs, ... }:
{

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.avahi = {
   enable = true;
   nssmdns4 = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  networking.hostName = "t1000"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 
1716 #kdeconnect
 ];
  networking.firewall.allowedUDPPorts = [ 
1716 #kdeconnect
];
}
