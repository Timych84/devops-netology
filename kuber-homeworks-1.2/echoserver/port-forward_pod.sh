#!/bin/bash
# Push commands in the background, when the script exits, the commands will exit too
kubectl port-forward -n default --address 192.168.171.200 pods/hello-world 8081:8080 & \
kubectl port-forward -n default --address 192.168.171.200 pods/hello-world 8082:8443 & \
echo "Press CTRL-C to stop port forwarding and exit the script"
wait
