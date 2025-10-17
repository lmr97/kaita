{ config, lib, pkgs, ... }:

let
  kubeMasterIP = "192.168.0.111";
  localValues = lib.importJSON "/etc/nixos/this-machine.json";
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
	token = localValues.k8sToken;
   	serverAddr = "https://${kubeMasterIP}:6443";
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
