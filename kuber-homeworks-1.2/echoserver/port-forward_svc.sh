#!/bin/bash
# Push commands in the background, when the script exits, the commands will exit too
kubectl port-forward -n default --address 192.168.171.200 services/netology-svc 18081:8081 & \
kubectl port-forward -n default --address 192.168.171.200 services/netology-svc 18082:8082 & \
echo "Press CTRL-C to stop port forwarding and exit the script"
wait
