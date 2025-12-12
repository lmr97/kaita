# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  thisMachine = lib.importJSON "/etc/nixos/this-machine.json";
in  
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      /home/martin/kaita/nixos/hosting-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "Rust Support";
        patch = null;
        features = { 
          rust = true; 
        };
      }
    ];
    supportedFilesystems = [ "nfs" ];
  };

  

  networking = {
    hostName = thisMachine.hostName;
    interfaces.wlp2s0 = {
      ipv4.addresses = [
        {
          address = thisMachine.ipAddress;
          prefixLength = 24;
        }
      ];
    };
    wireless = {
      enable = true;
      secretsFile = "/etc/wpa_supplicant/wireless.conf";
      networks.Alpha6.pskRaw = "ext:psk_home";
    };
    nameservers = [ "192.168.0.1" "8.8.8.8" ];
    defaultGateway = "192.168.0.1";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22    # SSH
        443   # HTTPS
        1918  # SSH (via router redirect)
        2049  # NFS
	6443  # Kubernetes / K3s
	2379  # for Flannel
	2380  # for k8s/Flannel
	8472  # for k8s/Flannel
      ];
      allowedUDPPorts = [ 
	8472  # Flannel
      ];
    };
    hosts = {
      "192.168.0.111" = [ "archie" ];
    };
    # keeping `enable` on its own line so I can bring in the other
    # commented-out options easier
    networkmanager = {
      enable = false;
    };
 #     ensureProfiles.profiles = {
 #       Alpha6 = {
 #         connection = {
 #           type = "wifi";
 #           id = "Alpha6";
 #           interface-name = "wlp2s0";
 #           autoconnect = true;
 #         };
 #         ipv4 = (netId); 
 #       };
 #     };
 #   };
  };


  
  # SSH configuration
  services.openssh = {
    enable = true;
    ports  = [ 22 ];
    settings = {
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.martin = {
    isNormalUser = true;
    extraGroups = [ 
      "martin"
      "wheel" 
      "sudo" 
      "docker" 
      "networkmanager" 
      "nogroup"
    ];
  };
  
  programs = {
    git = {
      enable = true;
      config = {
	user = {
	  name = "lmr97";
          email = "lmreid1997@gmail.com";
	};
        init.defaultBranch = "main";
      };
    };
    bash = {
      shellInit = 
	''
	  if [[ $SSH_CONNECTION ]]
	  then
	      	cd ~/kaita/nixos
		neofetch
	  fi
      	'';
    };
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    htop
    neofetch
    jq
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
