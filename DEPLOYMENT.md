# Deployment

This repository builds a static MkDocs site and deploys it as the `swe-docs`
Docker app on the shared VPS.

The VPS is provisioned from:

```sh
/home/kali/repositories/vps-setup
```

That setup defines the production app as:

| Field | Value |
| --- | --- |
| Domain | `swe-docs.ideacraft.dev` |
| Type | Docker app behind host Nginx |
| Server path | `/opt/apps/swe-docs` |
| Host port | `127.0.0.1:8081` from the server-managed `.env` |

## GitHub Secrets

Add these repository secrets in GitHub under
`Settings -> Secrets and variables -> Actions`:

| Secret | Value |
| --- | --- |
| `VPS_HOST` | VPS IP address or hostname |
| `VPS_SSH_KEY` | Private key matching the deploy public key in `vps-setup/vars.yml` |
| `VPS_USER` | Optional; defaults to `deploy` |
| `VPS_PORT` | Optional; defaults to `22` |

`VPS_PATH` is no longer used. The production path comes from the VPS setup and
is fixed in the workflow as `/opt/apps/swe-docs`.

## Deployment Flow

Every push to `main` runs `.github/workflows/deploy.yml`.

The workflow:

1. Installs Python dependencies from `requirements.txt`.
2. Runs `mkdocs build --strict` as a CI validation step.
3. Rsyncs the project files to `/opt/apps/swe-docs`.
4. Preserves the server-managed `/opt/apps/swe-docs/.env`.
5. Runs `docker compose up -d --build --remove-orphans` on the VPS.

The Docker image builds the MkDocs site in a Python build stage and serves the
generated files with Nginx.

## VPS Requirements

Before deploying, run the Ansible playbook in `/home/kali/repositories/vps-setup`
so the server has:

- the `deploy` user with the GitHub Actions public key;
- Docker Engine and the Compose plugin;
- `/opt/apps/swe-docs` owned by the deploy user;
- `/opt/apps/swe-docs/.env` containing `PORT=127.0.0.1:8081`;
- host Nginx proxying `swe-docs.ideacraft.dev` to `127.0.0.1:8081`.

## Manual Deployment

For a manual deploy, run this from the repository root:

```sh
rsync -az --delete \
  --exclude .env \
  --exclude .git/ \
  --exclude .github/ \
  --exclude infra/ansible/inventory.ini \
  --exclude infra/ansible/vars.yml \
  --exclude site/ \
  --exclude venv/ \
  --exclude __pycache__/ \
  ./ deploy@YOUR_VPS_IP:/opt/apps/swe-docs/

ssh deploy@YOUR_VPS_IP \
  'cd /opt/apps/swe-docs && docker compose up -d --build --remove-orphans'
```

## Troubleshooting

If GitHub Actions fails with `Permission denied (publickey,password)`, SSH
reached the VPS but the key was not accepted. Confirm that the private key in
`VPS_SSH_KEY` matches the public key in the VPS setup repo's `deploy_public_key`
value.

If the workflow fails because `/opt/apps/swe-docs/.env` is missing, rerun the
VPS setup playbook. The workflow intentionally does not create or overwrite that
file because it is managed by the server provisioning.

If the site is unreachable but the deploy succeeded, check the container and
host proxy:

```sh
ssh deploy@YOUR_VPS_IP 'cd /opt/apps/swe-docs && docker compose ps'
ssh deploy@YOUR_VPS_IP 'curl -I http://127.0.0.1:8081'
```

On the VPS, Nginx should terminate HTTPS for `swe-docs.ideacraft.dev` and proxy
traffic to the loopback Docker port.
