# Linux Fundamentals for DevOps

Linux is the backbone of most DevOps infrastructure. Knowing the command line
fluently is non-negotiable for anyone working in cloud, containers, or CI/CD.

## File System Hierarchy

```
/       root of the file system
/etc    configuration files
/var    variable data (logs, caches)
/tmp    temporary files (cleared on reboot)
/home   user home directories
/proc   virtual filesystem for process and kernel info
```

## File Permissions

```bash
chmod u+x script.sh            # add execute for owner
chmod 755 script.sh            # rwxr-xr-x (octal)
chmod 600 secret.conf          # rw------- owner only
chown -R www-data:www-data /var/www/app
find /etc -perm 644 -type f    # find files by permission
```

## Process Management

```bash
ps aux | grep nginx            # list and filter processes
htop                           # interactive process viewer
kill 1234                      # SIGTERM (graceful)
kill -9 1234                   # SIGKILL (force)
pkill nginx                    # kill by name
nohup ./app.sh &               # run immune to logout
```

## systemctl — Service Management

```bash
systemctl status nginx
systemctl start / stop / restart nginx
systemctl enable nginx         # start on boot
systemctl list-units --type=service --state=running
journalctl -u nginx --since "1 hour ago"
```

## Package Management

```bash
# Debian/Ubuntu
apt update && apt upgrade -y
apt install nginx -y && apt remove nginx -y

# RHEL/CentOS/Fedora
yum install nginx -y
dnf install nginx -y           # modern yum replacement
```

## Networking Commands

```bash
ip addr show                   # IP addresses
ip route show                  # routing table
ss -tlnp                      # TCP listening ports + process
dig +short example.com         # DNS lookup
curl -s -o /dev/null -w "%{http_code}" https://example.com
ping -c 4 8.8.8.8
nc -zv host 443               # test port connectivity
```

## Disk and Memory

```bash
df -h                         # filesystem usage
du -sh /var/log               # directory size
free -h                       # RAM and swap
find / -type f -size +100M 2>/dev/null   # large files
```

## Users and Groups

```bash
useradd -m -s /bin/bash deploy
usermod -aG devops deploy      # add to group
visudo                         # edit sudoers safely
```

## Logs and journald

```bash
tail -f /var/log/syslog        # follow system log
grep "error" /var/log/app.log
journalctl -f                  # follow all journal logs
journalctl -p err              # errors only
journalctl --vacuum-size=500M  # limit journal size
```

## Cron Jobs

```bash
crontab -e                     # edit current user's cron

# minute hour day month weekday command
0 2 * * * /opt/scripts/backup.sh        # daily at 2 AM
*/5 * * * * /opt/scripts/healthcheck.sh # every 5 minutes
```

## SSH

```bash
ssh-keygen -t ed25519 -C "devops@example.com"
ssh-copy-id user@host
ssh -L 8080:localhost:80 user@host     # local port forward
```

## Interview Q&As

### 1. What is the difference between SIGTERM and SIGKILL?

**Answer:** SIGTERM (15) asks the process to terminate gracefully, allowing it
to clean up resources, close connections, and flush buffers. SIGKILL (9) is
immediate and unconditional — the kernel destroys the process without any
cleanup. Always try SIGTERM first; only use SIGKILL when the process is
unresponsive.

### 2. How would you find which process is using a specific port?

**Answer:** Use `ss -tlnp | grep :80` or `lsof -i :80` to see which process
holds a port. `ss` is faster and preferred on modern systems. For example:
`ss -tlnp | grep :443` shows the PID, user, and process name listening on
port 443. If the port is UDP, use `ss -ulnp` instead.
