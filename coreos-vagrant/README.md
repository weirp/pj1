# CoreOS Vagrant

This repo provides a template Vagrantfile to create a CoreOS virtual machine using the VirtualBox software hypervisor.
After setup is complete you will have a single CoreOS virtual machine running on your local machine.

## Streamlined setup

1) Install dependencies

* [VirtualBox][virtualbox] 4.3.10 or greater.
* [Vagrant][vagrant] 1.6 or greater.

2) Clone this project and get it running!

```
git clone https://github.com/coreos/coreos-vagrant/
cd coreos-vagrant
```

3) Startup and SSH

There are two "providers" for Vagrant with slightly different instructions.
Follow one of the following two options:

**VirtualBox Provider**

The VirtualBox provider is the default Vagrant provider. Use this if you are unsure.

```
vagrant up
vagrant ssh
```

**VMware Provider**

The VMware provider is a commercial addon from Hashicorp that offers better stability and speed.
If you use this provider follow these instructions.

```
vagrant up --provider vmware_fusion
vagrant ssh
```

``vagrant up`` triggers vagrant to download the CoreOS image (if necessary) and (re)launch the instance

``vagrant ssh`` connects you to the virtual machine.
Configuration is stored in the directory so you can always return to this machine by executing vagrant ssh from the directory where the Vagrantfile was located.

3) Get started [using CoreOS][using-coreos]

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[using-coreos]: http://coreos.com/docs/using-coreos/

#### Shared Folder Setup

There is optional shared folder setup.
You can try it out by adding a section to your Vagrantfile like this.

```
config.vm.network "private_network", ip: "172.17.8.150"
config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']
```

After a 'vagrant reload' you will be prompted for your local machine password.

#### Provisioning with user-data

The Vagrantfile will provision your CoreOS VM(s) with [coreos-cloudinit][coreos-cloudinit] if a `user-data` file is found in the project directory.
coreos-cloudinit simplifies the provisioning process through the use of a script or cloud-config document.

To get started, copy `user-data.sample` to `user-data` and make any necessary modifications.
Check out the [coreos-cloudinit documentation][coreos-cloudinit] to learn about the available features.

[coreos-cloudinit]: https://github.com/coreos/coreos-cloudinit

#### Configuration

The Vagrantfile will parse a `config.rb` file containing a set of options used to configure your CoreOS cluster.
See `config.rb.sample` for more information.

## Cluster Setup

Launching a CoreOS cluster on Vagrant is as simple as configuring `$num_instances` in a `config.rb` file to 3 (or more!) and running `vagrant up`.
Make sure you provide a fresh discovery URL in your `user-data` if you wish to bootstrap etcd in your cluster.

## New Box Versions

CoreOS is a rolling release distribution and versions that are out of date will automatically update.
If you want to start from the most up to date version you will need to make sure that you have the latest box file of CoreOS.
Simply remove the old box file and vagrant will download the latest one the next time you `vagrant up`.

```
vagrant box remove coreos --provider vmware_fusion
vagrant box remove coreos --provider virtualbox
```

## Docker Forwarding

By setting the `$expose_docker_tcp` configuration value you can forward a local TCP port to docker on
each CoreOS machine that you launch. The first machine will be available on the port that you specify
and each additional machine will increment the port by 1.

Follow the [Enable Remote API instructions][coreos-enabling-port-forwarding] to get the CoreOS VM setup to work with port forwarding.

[coreos-enabling-port-forwarding]: https://coreos.com/docs/launching-containers/building/customizing-docker/#enable-the-remote-api-on-a-new-socket

Then you can then use the `docker` command from your local shell by setting `DOCKER_HOST`:

    export DOCKER_HOST=tcp://localhost:2375
; Start container and store the id:
CONTAINER=$(docker run -d zaiste/postgresql)

; get ip address
CONTAINER_IP=$(docker inspect $CONTAINER | grep IPAddress | awk '{ print $2 }' | tr -d ',"')

; get container id (if you know image name)
sudo docker ps |grep 'postgres'|awk '{print $NF}'

; get ip address
sudo docker inspect grave_mccarthy|grep IPAddress|awk '{print $2}'|tr -d ',"'

sudo docker inspect -f '{{ .NetworkSettings.IPAddress }}' <name>

=====
THe aim is to create a bunch of vagrant-based boxes running docker containers. SOme of these will be apps written in clojure, along with infrastructure boxen.

Management of these boxes should be straightforward; rather than having to directly fire up the individual boxen and work out any links between the boxes (like a reference to the database etc)

Current flavour:
docker, vagrant, virtualbox, fleetctl, coreos.

Probably want to provision a windows box amongst all these too.


coreos:
https://www.digitalocean.com/community/tutorials/how-to-troubleshoot-common-issues-with-your-coreos-servers


Latest direction based fairly much on this series:

http://lukebond.ghost.io/getting-started-with-coreos-and-docker-using-vagrant/
http://lukebond.ghost.io/deploying-docker-containers-on-a-coreos-cluster-with-fleet/
http://lukebond.ghost.io/service-discovery-with-etcd-and-node-js/


http://www.rkn.io/

ansible:
http://aruizca.com/steps-to-create-a-vagrant-base-box-with-ubuntu-14-04-desktop-gui-and-virtualbox/

dokku:
http://blog.clearbit.co/ec2-heroku?hn

shipyard:
http://shipyard-project.com/docs/usage/cli/

networking using weave (haven't looked at this yet!)
http://java.dzone.com/articles/how-network-docker-containers

working in git/coreos-vagrant

So, currently trying to work through the example/s @ http://lukebond.ghost.io/.



To install fleet, browse the coreos/fleet releases directory and find latest for the appropriate platform. (Example given is for osx)


Cloning the coreos-vagrant repository step includes setting a DISCOVERY_TOKEN. After shutdown this needs to re-obtained; so I have pushed this into a script.

$ git clone https://github.com/coreos/coreos-vagrant/
$ cd coreos-vagrant
$ DISCOVERY_TOKEN=`curl -s https://discovery.etcd.io/new` && perl -p -e "s@#discovery: https://discovery.etcd.io/<token>@discovery: $DISCOVERY_TOKEN@g" user-data.sample > user-data
$ export NUM_INSTANCES=1

Damn, as a script will need to source it to propogate the environment variable to the hosting environment.
Can just alter the script to export the variable as an alternative.
No, need to source it, or include it as a part of the normal environmental flow.....
sourcing will be required to avoid it just running in a separate subshell!

Some host/key issues:
See https://groups.google.com/forum/#!topic/coreos-user/rxD-X_1b6jU

This recommends:
------ begin ------
From your workstation/laptop/etc, do the following ....

ssh-keygen -t rsa
 - you may accept all default without passphrase

ssh-copy-id -i ~/.ssh/id_rsa.pub core@<ip>
 - do this to all your coreos clusters

eval `ssh-agent`

ssh-add ~/.ssh/id_rsa

copy the ~/.ssh/know_hosts to ~/.fleetctl/

fleetctl --tunnel=<one of your clusters> list-units -l
 - you may use the env vars of fleet for the tunnel and remove the --tunnel when executing fleetcl 
------  end  ------

This may be better described @ 
https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/


Ahhhh, so just run it on the coreos machine :-
vagrant ssh ; to ssh onto the coreos machine, and
fleetctl

You can do it remotely using the FLEETCTL_TUNNEL variable.




----- 
recloned.

seems to work.

DISCOVERY_TOKEN=`curl -s https://discovery.etcd.io/new` && perl -p -e "s@#discovery: https://discovery.etcd.io/<token>@discovery: $DISCOVERY_TOKEN@g" user-data.sample > user-data
export NUM_INSTANCES=1
vagrant up

rm ~/.fleetctl/known_hosts

export FLEETCTL_TUNNEL=127.0.0.1:2222
ssh-add ~/.vagrant.d/insecure_private_key
fleetctl list-machines
fleetctl submit dillinger.service
fleetctl list-units
fleetctl start dillinger.service
fleetctl journal dillinger.service


Not 100% convinced that docker was running the container in the vm.

On to part 2.

rm ~/.fleetctl/known_hosts
export FLEETCTL_TUNNEL=127.0.0.1:2222
export NUM_INSTANCES=3
cd ~/git/pj1/coreos-vagrant
vagrant destroy

DISCOVERY_TOKEN=`curl -s https://discovery.etcd.io/new` && perl -i -p -e "s@discovery: https://discovery.etcd.io/\w+@discovery: $DISCOVERY_TOKEN@g" user-data

vagrant up

fleetctl list-machines


fleetctl submit service1/contrived-service-1.service service2/contrived-service-2.service service3/contrived-service-3.service
fleetctl submit postgres.service/postgres-service.service
fleetctl start postgres.service/postgres-service.service

fleetctl list-units

fleetctl start contrived-service-{1,2,3}.service

fleetctl journal contrived-service-1.service


yes, and I can ssh into a vm and set the container runner.... 
Previously I just might not have waited long enough.


export NUM_INSTANCES=4
vagrant up
fleetctl list-machines
fleetctl list-units

vagrant halt core-02


===end of part 2===

===part 3: using etcd===


example services:
http://2mohitarora.blogspot.com.au/2014/05/manage-docker-containers-using-coreos_18.html
http://mattupstate.com/coreos/devops/2014/06/26/running-an-elasticsearch-cluster-on-coreos.html

using eucalyptus:
http://blogs.mindspew-age.com/tag/coreos-fleetctl/

running internal docker registry, other things
https://blog.dropletpay.com/droplet-infrastructure-dockerisation/




To watch:
Black Mirror (SBS); Dr Who
Whitechapel 
