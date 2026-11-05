# How to add a Kubernetes Service as a Tailscale machine

1. Create an `Ingress` in the same namespace as the service, pointed to the service, with the hostname set under `spec.tls.host`.
2. Connect to the at <hostname>.<tailnet name>.ts.net!
