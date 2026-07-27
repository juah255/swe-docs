# Ansible

Ansible is a configuration management tool that uses YAML playbooks to
define and enforce desired state on target hosts.

## Inventories and Host Groups

Inventories define which hosts Ansible manages, grouped logically.

```ini
[webservers]
web1.example.com
web2.example.com
[dbservers]
db1.example.com
```

Dynamic inventories can pull host lists from cloud APIs or CMDBs.

## Playbooks, Plays, and Tasks

Playbooks contain plays. Each play targets hosts and runs ordered tasks.

```yaml
- name: Configure web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Install nginx
      apt: { name: nginx, state: present }
    - name: Start nginx
      service: { name: nginx, state: started, enabled: yes }
```

## Modules, Variables, and Templates

Modules are units of work (`apt`, `yum`, `service`, `template`, `user`).
Variables customize playbooks. Templates use Jinja2 for config files.

```yaml
vars:
  http_port: 80
  server_name: example.com
tasks:
  - name: Deploy nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx
```

## Roles and Handlers

Roles organize tasks, handlers, templates, and variables into reusable
packages. Handlers run only when notified, ideal for restarting services.

```
roles/webserver/{tasks,handlers,templates,vars}/
```

```yaml
handlers:
  - name: Restart nginx
    service: { name: nginx, state: restarted }
```

## Ansible Vault

Vault encrypts sensitive data like passwords and API keys.

```bash
ansible-vault create secrets.yml
ansible-playbook site.yml --ask-vault-pass
```

## Idempotency

An idempotent playbook runs repeatedly and leaves the system in the same
state. Using `apt` with `state: present` is idempotent; running raw
`apt-get install` every time is not.

## Practical Examples

### Install Packages

```yaml
- name: Ensure required packages are installed
  apt:
    name: [curl, git, python3]
    state: present
    update_cache: yes
```

### Configure Nginx

```yaml
- name: Deploy nginx configuration
  template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: "0644"
  notify: Restart nginx
```

### Manage Users

```yaml
- name: Create deploy user
  user:
    name: deploy
    shell: /bin/bash
    groups: sudo
    append: yes
    create_home: yes

- name: Set up SSH key for deploy user
  authorized_key:
    user: deploy
    key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```

## Interview Questions and Answers

### 1. What makes an Ansible task idempotent?

An idempotent task can run repeatedly and leave the system in the same
desired state without unnecessary changes. Using a package module to ensure
a package is present is idempotent; running a raw install command every time
is not. Idempotency makes automation safe for repeated deployments, recovery,
and drift correction.

### 2. How does Ansible Vault protect sensitive data?

Ansible Vault encrypts files in place using AES-256. Encrypted files can be
stored in version control safely. At runtime, the vault password decrypts
variables and files only during execution. Never pass vault passwords via
command line in production; use `--vault-password-file` or environment
variables instead.

### 3. When should you use roles versus inline playbooks?

Use roles when logic is reusable across multiple playbooks or projects.
Roles provide structure with separate directories for tasks, handlers,
templates, and variables. Inline playbooks are fine for simple, single-use
plays. As complexity grows, refactor into roles to keep playbooks readable
and maintainable.
