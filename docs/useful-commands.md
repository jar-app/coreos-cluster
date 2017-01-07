# Useful commands for machines

#### Check cluster health
```bash
$ coreos@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/home/core/coreos.pem --key-file=/home/core/coreos-key.pem --ca-file=/home/core/ca.pem cluster-health
```


#### List cluster members
```bash
$ coreos@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/home/core/coreos.pem --key-file=/home/core/coreos-key.pem --ca-file=/home/core/ca.pem member list
```
