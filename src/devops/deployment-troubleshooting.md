# Deployment Troubleshooting

Troubleshoot deployments from the outside in: confirm the symptom, trace the request path, inspect each dependency, and compare the deployed environment with the known working environment.

## Investigation Workflow

1. Reproduce the failure and record the exact error, time, request, and affected environment.
2. Check deployment status, application health, and recent changes.
3. Inspect application, proxy, container, and system logs.
4. Trace DNS, network, firewall, load balancer, proxy, and application connectivity.
5. Verify configuration, secrets, dependencies, permissions, ports, and runtime versions.
6. Compare the server environment with the local or previously working environment.
7. Roll back or mitigate the change when diagnosis will take longer than the acceptable outage.
8. Document the cause, fix, and prevention steps.

## Common Failure Areas

- Missing or incorrect environment variables
- Incorrect runtime or dependency versions
- Database connectivity or unapplied migrations
- Services listening on the wrong host or port
- DNS records pointing to the wrong destination
- Expired or misconfigured TLS certificates
- Firewall or security-group rules
- Reverse proxy and load balancer configuration
- File ownership and permissions
- Missing files, volumes, or build artifacts
- Resource exhaustion
- Failed health checks

## Useful Checks

- Process and service status
- Container status and logs
- Listening ports
- DNS resolution
- HTTP responses from each network hop
- TLS certificate validity
- Disk, memory, and CPU usage
- Database and external-service connectivity

## Deployment Troubleshooting Questions

- The app is working on your local machine, but after deploying it to the server it is not working. How would you debug it?
- What environment differences can break an application after deployment?
- How do you verify environment variables, ports, DNS, SSL, file permissions, and process configuration on a server?
