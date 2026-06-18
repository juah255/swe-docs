# DevOps Fundamentals

DevOps combines development and operations practices to deliver software quickly, consistently, and safely.

## DevOps Principles

- Shared ownership between development and operations
- Automation of repetitive delivery and operational work
- Small, frequent, and reversible changes
- Fast feedback from tests and production systems
- Continuous improvement through measurement and incident reviews
- Infrastructure and operational knowledge stored as code and documentation

## Linux Fundamentals

- Files, directories, permissions, ownership, and links
- Package management
- Users, groups, and privilege escalation
- Processes, signals, jobs, and resource usage
- Services and `systemd`
- Environment variables and shell configuration
- Logs and common locations under `/var/log`
- Disk, memory, and CPU inspection

## Shell Scripting

- Commands, arguments, pipes, and redirection
- Variables, quoting, exit codes, and conditionals
- Loops and functions
- Text-processing tools such as `grep`, `sed`, `awk`, and `jq`
- Scheduling work with `cron`
- Writing scripts that fail clearly and can be run repeatedly

## Operating System Concepts

- Processes and threads
- Memory and virtual memory
- Filesystems and mounts
- Standard input, output, and error
- Signals and process termination
- Resource limits

## Mid/Senior Interview Questions and Answers

### 1. What happens between entering a command and receiving its output?

**Answer:** The shell parses the command, expands variables and globs, resolves
the executable through `PATH`, starts a process, connects standard input,
output, and error, then waits for the process to exit unless it is backgrounded.

For pipelines, the shell connects the output of one process to the input of the
next. The final exit status and captured output depend on shell configuration
and pipeline behavior.

### 2. How do you find which process is consuming CPU, memory, disk, or a port?

**Answer:** Use `top` or `htop` for CPU and memory, `ps` for process details,
`du` and `df` for disk usage, `iotop` or service metrics for disk I/O, and `ss
-ltnp` or `lsof -i` to identify listening ports.

Senior-level debugging correlates process data with logs, deployment changes,
traffic, and resource limits instead of treating one command output as the full
answer.

### 3. How do file permissions differ for users, groups, and others?

**Answer:** Unix permissions are evaluated for the file owner, group, and
others. Read, write, and execute bits control access, while ownership and group
membership determine which permission set applies.

For directories, execute means traversal. A user may be unable to access a file
if they lack execute permission on a parent directory.

### 4. How do you inspect and restart a failed service?

**Answer:** With `systemd`, inspect status with `systemctl status`, logs with
`journalctl -u`, and configuration with the unit file and environment files.
After fixing the cause, reload configuration if needed and restart the service.

Avoid blind restarts in production. First capture the failure state, recent
logs, exit code, resource usage, and dependency status.
