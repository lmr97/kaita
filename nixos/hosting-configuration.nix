{ config, lib, pkgs, ... }:

let
  kubeMasterIP = "192.168.0.111";
  thisMachine = lib.importJSON "/etc/nixos/this-machine.json";
in
{
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
	docker-compose
	openiscsi
      ];
   
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      services.k3s = {
    	enable = true;
    	role = "agent";   
	# temp token, invalid by the time you're seeing this 
	token = thisMachine.k8sToken;
   	serverAddr = "https://${kubeMasterIP}:6443";
      };
       
      services.openiscsi = {
	enable = true;
	name = "open-iscsi-nix";  # name may not matter
	discoverPortal = "ip:3260";
      };
 
      services.nfs.settings.mountd.manage-gids = true;
      
      fileSystems = {
        "/nfs/jellyfin" = {
          device = "archie:/jellyfin";
          fsType = "nfs";
          options = [ 
            "x-systemd.automount" 
            "noauto" 
            "noatime"
          ];
        };
      };
    }  
 ]; 
}
