#!/bin/bash
# Source - https://stackoverflow.com/a/57533340
# Posted by Alex Vorona
# Retrieved 2026-05-07, License - CC BY-SA 4.0

# "scales up" DaemonSets that were "scaled down" for apartment move

kubectl -n longhorn-system patch daemonset engine-image-ei-26bab25d \
	--type json \
	-p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'

kubectl -n longhorn-system patch daemonset longhorn-csi-plugin \
	--type json \
	-p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'

kubectl -n longhorn-system patch daemonset longhorn-manager \
	--type json \
	-p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'

kubectl -n crowdsec patch daemonset crowdsec-agent \
	--type json \
	-p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
