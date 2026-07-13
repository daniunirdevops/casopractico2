#!/bin/bash

IP_PODMAN=$1

curl -k https://$IP_PODMAN/                      # 401 Unauthorized (sin credenciales)
curl -k -u alumno:unir2026 https://$IP_PODMAN/   # 200 OK (con credenciales)
