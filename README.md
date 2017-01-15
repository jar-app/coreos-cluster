# CoreOS Cluster

Scripts and config to help bootstrap a CoreOS cluster on DigitalOcean with:
- etcd2 configured with TLS



#### To bootstrap the cluster
- Pre-reqs:
  - Generate an ssh key and upload it to your digital ocean account
  - Copy `config.example.yml` to `config.yml` and configure `local_ssh_private_key_path`

```bash
bundle && DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec rake cluster:up
```

#### List members in the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec rake cluster:list
```

#### Take down all nodes in the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec rake cluster:down
```

### SSH into first cluster member
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec rake cluster:ssh
```

#### Reboot the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec rake cluster:reboot
```

### Checkout the docs for more info
