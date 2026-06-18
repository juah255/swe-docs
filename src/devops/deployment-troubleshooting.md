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

## Mid/Senior Interview Questions and Answers

### 1. The app works locally but fails after deployment. How would you debug it?

**Answer:** Start from the user-visible symptom and trace the request path:
DNS, TLS, load balancer, reverse proxy, application process, database, cache,
queues, and external services.

Check recent changes, deployment status, health checks, application logs,
container logs, environment variables, secrets, migrations, file permissions,
ports, and runtime versions. If impact is high, mitigate or roll back before
continuing deep diagnosis.

### 2. What environment differences commonly break deployed applications?

**Answer:** Common differences include missing environment variables, wrong
runtime versions, different dependency versions, filesystem case sensitivity,
network restrictions, unavailable services, incorrect secrets, unapplied
migrations, and different build-time versus runtime configuration.

Senior engineers reduce this risk with containerization, lockfiles, deployment
manifests, environment parity, smoke tests, and explicit configuration checks.

### 3. How do you verify ports, DNS, TLS, and proxy configuration?

**Answer:** Use `dig` or `nslookup` for DNS, `curl -v` for HTTP/TLS behavior,
`openssl s_client` for certificates, `ss` or `netstat` for listening ports, and
proxy logs to confirm upstream routing.

Test each hop directly where possible. A failing public URL does not prove the
application process is broken; the problem may be DNS, certificate, firewall,
proxy, or load balancer configuration.

### 4. When should you roll back instead of continuing to debug?

**Answer:** Roll back or mitigate when the user impact exceeds the acceptable
recovery window and the cause is not immediately clear. Debugging during an
active outage should be balanced against service restoration.

After recovery, preserve logs and deployment metadata so the team can identify
the cause and prevent recurrence.
