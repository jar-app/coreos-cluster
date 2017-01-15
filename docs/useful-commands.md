# Useful commands for machines

#### Check cluster health
```bash
$ core@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/etc/etcd/ssl/coreos.pem --key-file=/etc/etcd/ssl/coreos-key.pem --ca-file=/etc/etcd/ssl/ca.pem cluster-health
```


#### List cluster members
```bash
$ core@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/etc/etcd/ssl/coreos.pem --key-file=/etc/etcd/ssl/coreos-key.pem --ca-file=/etc/etcd/ssl/ca.pem member list
```
