#!/bin/bash

# Set the namespace
namespace="app"

# Get all pod names in the namespace
pod_names=($(kubectl get pods -n "$namespace" -o jsonpath="{.items[*].metadata.name}"))

# Print table header
printf "%-20s | %-20s | %-6s\n" "Pod From" "Pod To" "Result"
printf "%-20s | %-20s | %-6s\n" "--------------------" "--------------------" "------"

# Loop through each pod
for from_pod in "${pod_names[@]}"; do
    from_pod_ip=$(kubectl get pod "$from_pod" -n "$namespace" -o=jsonpath='{.status.podIP}')

    # Loop through each pod again to perform curl request
    for to_pod in "${pod_names[@]}"; do
        if [ "$from_pod" != "$to_pod" ]; then
            to_pod_ip=$(kubectl get pod "$to_pod" -n "$namespace" -o=jsonpath='{.status.podIP}')
            curl_output=$(kubectl exec -n "$namespace" "$from_pod" -- curl -m 1 -s -o /dev/null -w "%{http_code}" "$to_pod_ip:8080" 2>/dev/null)

            if [ "$curl_output" -eq 200 ]; then
                result="Pass"
            else
                result="Fail"
            fi

            # Print table row
            printf "%-20s | %-20s | %-6s\n" "$from_pod" "$to_pod" "$result"
        fi
    done
done
