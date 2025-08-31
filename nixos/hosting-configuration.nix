{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      environment.systemPackages = [
        pkgs.git
	pkgs.docker-compose
      ];
   
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      services.nfs.settings = {
	mountd.manage-gids = true;
      };
 
      fileSystems."/nfs/media" = {
        device = "archie:/media";
        fsType = "nfs";
        options = [ 
	  "x-systemd.automount" 
	  "noauto" 
	  "noatime"
	];
      };
    }
  ];
}
