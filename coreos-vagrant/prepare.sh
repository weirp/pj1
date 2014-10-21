#!/bin/bash

echo "Make sure you source this using dot or source"

rm ~/.fleetctl/known_hosts
export FLEETCTL_TUNNEL=127.0.0.1:2222
export NUM_INSTANCES=3
cd ~/git/pj1/coreos-vagrant
vagrant destroy -f
ssh-add ~/.vagrant.d/insecure_private_key

DISCOVERY_TOKEN=`curl -s https://discovery.etcd.io/new` && perl -i -p -e "s@discovery: https://discovery.etcd.io/\w+@discovery: $DISCOVERY_TOKEN@g" user-data

vagrant up

