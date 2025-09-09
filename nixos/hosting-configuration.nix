{ config, lib, pkgs, ... }:

let
  kubeMasterIP = "192.168.0.111";
  kubeMasterHostname = "archie";
  kubeMasterAPIServerPort = 6443;
in
{
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
	docker-compose
	kompose
	kubectl
	
      ];
   
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      services.nfs.settings.mountd.manage-gids = true;
    

      services.kubernetes = let 
	api = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
      in 
      {
	enable = true;
      	roles = [ "node" ];
	masterAddress = kubeMasterHostname;
	easyCerts = true;

	kubelet.kubeconfig.server = api;
	apiserverAddress = api;
	addons.dns.enable = true;
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
