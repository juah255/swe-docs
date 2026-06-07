# Deployment

This repository builds a static MkDocs site and deploys the generated `site/`
directory to a VPS with GitHub Actions.

## Automated VPS setup

Use the Ansible playbook in `infra/ansible` to automate the VPS setup.

Install Ansible on your local machine:

```sh
python3 -m pip install --user ansible
```

Create local config files from the examples:

```sh
cp infra/ansible/inventory.example.ini infra/ansible/inventory.ini
cp infra/ansible/vars.example.yml infra/ansible/vars.yml
```

Edit `infra/ansible/inventory.ini` and replace `YOUR_VPS_IP` with your VPS IP.
Edit `infra/ansible/vars.yml` and paste the deploy public key into
`deploy_public_key`.

Run the playbook:

```sh
ansible-playbook -i infra/ansible/inventory.ini infra/ansible/provision.yml -e @infra/ansible/vars.yml
```

If your inventory uses a non-root user with sudo access, ask Ansible for the
sudo password:

```sh
ansible-playbook -i infra/ansible/inventory.ini infra/ansible/provision.yml -e @infra/ansible/vars.yml --ask-become-pass
```

If your VPS also requires an SSH password instead of SSH key login, ask for both
passwords:

```sh
ansible-playbook -i infra/ansible/inventory.ini infra/ansible/provision.yml -e @infra/ansible/vars.yml --ask-pass --ask-become-pass
```

The playbook installs Nginx and rsync, creates the deploy user, creates the web
root, adds the deploy SSH key, configures Nginx for IP-based serving, and reloads
Nginx.

## Manual VPS setup

Create a deployment user:

```sh
sudo adduser --disabled-password --gecos "" deploy
```

Create the web root and allow the deployment user to write to it:

```sh
sudo mkdir -p /var/www/swe-docs
sudo chown -R deploy:www-data /var/www/swe-docs
sudo chmod -R 775 /var/www/swe-docs
```

Install Nginx and rsync:

```sh
sudo apt update
sudo apt install -y nginx rsync
```

Add an Nginx server block. If you are serving the site directly from the VPS
IP address, use `default_server`:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/swe-docs;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Enable it:

```sh
sudo ln -s /etc/nginx/sites-available/swe-docs /etc/nginx/sites-enabled/swe-docs
sudo nginx -t
sudo systemctl reload nginx
```

If you later add a domain, change `server_name _;` to your domain and update
the `listen` lines if this should no longer be the default site.

For HTTPS with a domain, point DNS at the VPS and issue a certificate with
Certbot:

```sh
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d docs.example.com
```

## SSH key

Generate a dedicated deploy key on your local machine:

```sh
ssh-keygen -t ed25519 -C "github-actions-swe-docs" -f ~/.ssh/swe-docs-deploy
```

Install the public key for the deploy user on the VPS:

```sh
ssh-copy-id -i ~/.ssh/swe-docs-deploy.pub deploy@YOUR_VPS_IP
```

## GitHub secrets

Add these repository secrets in GitHub under
`Settings -> Secrets and variables -> Actions`:

| Secret | Value |
| --- | --- |
| `VPS_HOST` | VPS IP address or hostname |
| `VPS_USER` | `deploy` |
| `VPS_PATH` | `/var/www/swe-docs` |
| `VPS_SSH_KEY` | Contents of `~/.ssh/swe-docs-deploy` |
| `VPS_PORT` | SSH port, optional; defaults to `22` |

## Deployment flow

Every push to `main` runs `.github/workflows/deploy.yml`.

The workflow:

1. Installs Python dependencies from `requirements.txt`.
2. Runs `mkdocs build --strict`.
3. Uploads the generated `site/` directory to `VPS_PATH` with `rsync --delete`.

If you are using only the VPS IP, set `site_url` in `mkdocs.yml` to
`http://YOUR_VPS_IP`. If you later add a domain and HTTPS, change it to the
final `https://...` URL.
