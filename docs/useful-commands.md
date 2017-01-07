# Useful commands for machines

#### Check cluster health
```bash
$ coreos@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/home/core/coreos.pem --key-file=/home/core/coreos-key.pem --ca-file=/home/core/ca.pem cluster-health
```


#### List cluster members
```bash
$ coreos@remote: etcdctl --endpoints="https://0.0.0.0:2379" --cert-file=/home/core/coreos.pem --key-file=/home/core/coreos-key.pem --ca-file=/home/core/ca.pem member list
```


#### SSH into a cluster member
```bash
$ user@local: bundle exec rake cluster:list
I, [2017-01-06T23:53:01.618255 #17380]  INFO -- : Droplet: 'waistcoat-narwhal'       ipv4: 198.199.90.227
$ user@local: ssh core@198.199.90.227
```
