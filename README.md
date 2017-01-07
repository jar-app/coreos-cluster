# CoreOS Cluster

Scripts and config to help bootstrap a CoreOS cluster on DigitalOcean with:
- etcd2 configured with TLS



#### To bootstrap the cluster
- Pre-reqs:
  - Generate an ssh key and upload it your digital ocean account
  - Have the private key be located in `~/.ssh/id_rsa` locally

```bash
bundle && DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec cluster:up
```

#### List members in the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec cluster:list
```

#### Take down all nodes in the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec cluster:down
```


#### Reboot the cluster
```bash
DIGITAL_OCEAN_ACCESS_TOKEN=XXX bundle exec cluster:reboot
```

### Checkout the docs for more info
