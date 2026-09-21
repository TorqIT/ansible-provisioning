# ansible-provisioning

Roles and a playbook used to provision TorqIT's Pimcore/Shopware client
infrastructure: Docker + baseline OS hardening, Opensearch, Mercure,
Gotenberg, Blackfire, Netdata, self-hosted GitHub Actions runners,
nginx-proxy, and MySQL/MariaDB.

This repo is both:

- An **Ansible collection** (`torqit.provisioning`) — the roles, documented
  via `meta/argument_specs.yml` so `ansible-doc` and IDE tooling can show
  each role's variables.
- A **Docker image** (`ghcr.io/torqit/ansible-provisioning`) — a pinned
  `ansible-core` + collection + role-dependency environment, so CI runners
  and local machines don't need Ansible installed or version-matched
  themselves. See [TorqIT/pimcore-github-actions-workflows](https://github.com/TorqIT/pimcore-github-actions-workflows)
  for how the image is used in CI.

## Repo layout

```
galaxy.yml          # collection metadata + dependencies
meta/runtime.yml     # minimum ansible-core version
roles/<role>/        # one role per service; meta/argument_specs.yml documents its variables
playbook.yml         # the actual provisioning playbook, referencing roles as torqit.provisioning.<role>
requirements.yml     # standalone Galaxy roles this playbook depends on (not collections - see below)
Dockerfile           # builds/installs the collection + requirements.yml roles into a pinned image
```

## Documentation

Each role's variables (required/optional, defaults, descriptions) are
documented in its `meta/argument_specs.yml`. Once the collection is
installed, view them with:

```
ansible-doc -t role torqit.provisioning.<role>
```

## Using this as a collection directly (without the Docker image)

```
ansible-galaxy collection install git+https://github.com/TorqIT/ansible-provisioning.git
ansible-galaxy install -r requirements.yml   # geerlingguy.docker, geerlingguy.pip, etc.
```

`galaxy.yml` declares `community.general`, `community.docker`, and
`ansible.posix` as collection dependencies, so `ansible-galaxy collection
install` resolves those automatically. The three entries in
`requirements.yml` are standalone Galaxy *roles*, not collections — Galaxy
collections can't declare a role as a dependency, so they're installed
separately, exactly as the Dockerfile does.

Then reference roles by their fully-qualified name in your own playbook
(see `playbook.yml` for the reference implementation), e.g.:

```yaml
- hosts: netdata
  roles:
    - role: torqit.provisioning.netdata
```

## Using the Docker image

No change from before — pull `ghcr.io/torqit/ansible-provisioning`, mount
your inventory (and its `host_vars`/`group_vars`) into the container, and
run `ansible-playbook -i <your-inventory> playbook.yml` inside it. See
`.github/workflows/meta-ci.yml` for how the image is built/tagged, and the
`run-ansible-playbooks` composite action in
[pimcore-github-actions-workflows](https://github.com/TorqIT/pimcore-github-actions-workflows)
for the CI usage pattern.

### Gotchas

If you ever see the command hanging at "Gathering facts", cancel it and run
`rm -rf ~/.ansible`, followed by re-running `ansible-galaxy install -r
requirements.yml`, then retry.
