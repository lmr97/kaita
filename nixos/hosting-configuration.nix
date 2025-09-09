{ config, lib, pkgs, ... }:

let
  kubeMasterIP = "192.168.0.111";
in
{
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
	docker-compose
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
	token = "K10de70da372eaf0b629b3b58284c49a5039b4fc7fa049c827be99f38612cd02561::9nix64.z3y3zriq7dq3apyh";
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
