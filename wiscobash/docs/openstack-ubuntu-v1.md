# openstack

setting up a simple poc using a libvirt vm with bare minimum specs running ubuntu 24.04

>this flavor uses ansible to do everything

## prereqs

```shell
sudo apt update && \
sudo apt install -y git python3-dev libffi-dev gcc libssl-dev libdbus-glib-1-dev python3-venv
```

## install

```shell
mkdir ~/openstack && \
python3 -m venv ~/openstack && \
source ~/openstack/bin/activate && \
pip install -U pip && \
cd ~/openstack && \
pip install git+https://opendev.org/openstack/kolla-ansible@master && \
sudo mkdir -p /etc/kolla && \
sudo chown $USER:$USER /etc/kolla && \
cp -r ~/openstack/share/kolla-ansible/etc_examples/kolla/* /etc/kolla && \
cp ~/openstack/share/kolla-ansible/ansible/inventory/all-in-one . && \
kolla-ansible install-deps
```

## configure

`/etc/kolla/passwords.yml` has a fuckton of accounts/services that need a password...we could (and might) edit ourselves...

or we can run `kolla-genpwd` and let it handle everything...feel like that will come back to bite us later but moving on!

`/etc/kolla/globals.yml` is the main config file, so you'll be accessing/editing it the most

need to add/enable/uncomment (not sure best action yet) the following:

* kolla_base_distro: "ubuntu"
* network_interface: "enp1s0"
* neutron_external_interface: "enp2s0"
* kolla_internal_vip_address: "192.168.122.254"
  * not sure what to use here..."should be set to be not used address in management network that is connected to our network_interface" so does that mean just an un-used ip that isn't in the dhcp range? if so that would be `192.168.122.254` so we'll try that

the only actual line in the file is:

```yaml
workaround_ansible_issue_8743: true
```

and the comment says that is there just so ansible accepts the file...so for now we can just append the settings to the file:

```shell
tee -a /etc/kolla/globals.yml > /dev/null << 'EOF'

###config###
kolla_base_distro: "ubuntu"
network_interface: "enp1s0"
neutron_external_interface: "enp2s0"
kolla_internal_vip_address: "192.168.122.254"
###config###
EOF
```

## deploy

this is where it gets messy! taking a snapshot first

>don't forget to go back into the venv with `source ~/openstack/bin/activate`

```shell
kolla-ansible bootstrap-servers -i ./all-in-one && \
kolla-ansible prechecks -i ./all-in-one && \
kolla-ansible deploy -i ./all-in-one
```

once it's done openstack is functional!

sadly it failed, wasn't able to confirm the `docker sdk` so fixed that by installing:

well turns out they don't mention it the documentation but you need the official docker engine installed

so we'll use the official steps provided from here:

<https://docs.docker.com/engine/install/ubuntu/>

```shell
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) && \
sudo apt update && \
sudo apt install -y ca-certificates curl && \
sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
sudo chmod a+r /etc/apt/keyrings/docker.asc && \
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null << EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo usermod -aG docker $USER && \
newgrp docker
```

then ran into a missing `dbus` issue that was fixed with running this in the activated venv:

```shell
pip install dbus-python
```

finally finished, powering off and take a snapshot!

## usage

<https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html#using-openstack>

there is a cli client we can install:

```shell
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
```

>that installs a lot for just a cli client

this does some things...not sure why it comes after the cli client but whatever:

```shell
kolla-ansible post-deploy
```

but that doesn't work, it's looking for an inventory in a path that doesn't exist...I think just need to pass along the all-in-one inventory file like on the previous playbooks

```shell
kolla-ansible post-deploy -i ./all-in-one
```

so that creates some files, of most importance is `/etc/kolla/clouds.yaml`

for a quick test you can set it as specific variable and it should allow you to interact with openstack:

```shell
export OS_CLIENT_CONFIG_FILE=/etc/kolla/clouds.yaml
openstack image list
```

that didn't work, gave some `Missing value auth-url required for auth plugin password` response...but at least it wasn't an error?

apparently can copy it to either `/etc/openstack` or `~/.config/openstack` but neither of those exist...and are they directories or full paths? the documentation was awesome up to this point, but a little research should sort it out

```shell
sudo mkdir -p /etc/openstack && \
sudo cp /etc/kolla/clouds.yaml /etc/openstack/
```

after doing that, I didn't restart any service or anything, just activated the venv we were previously using and sourcing a script created from the post-deploy playbook:

```shell
source ~/openstack/bin/activate && \
source /etc/kolla/admin-openrc.sh
```

and then these commands showed what looks like valid results of openstack running (too dumb to know better yet):

```shell
openstack endpoint list
openstack service list
openstack compute service list
openstack network agent list
openstack volume service list
```

for now will skip using the `init-runonce` script to load the environment with items...we want it clean so terraform can fuck with it

for terraform, we may want to go with the user-level confirm

```shell
mkdir -p ~/.config/openstack && \
sudo cp /etc/kolla/clouds.yaml ~/.config/openstack/clouds.yaml && \
sudo chown $USER:$USER ~/.config/openstack/clouds.yaml
```

then you should be able to run something like `openstack cloud list` and get a result, but specific command didn't work but I think it's chatgpt's fault

that's because newer clients, like we have, don't have that anymore

the best test to confirm the client is working is running this inside the venv (we might address that later...maybe through some miniconda at it?):

```shell
openstack --version
export OS_CLOUD=kolla-admin
openstack token issue
openstack compute service list
```

the result was:

```shell
openstack 8.2.0
+------------+-------------------------------------------------------------------------------+
| Field      | Value                                                                         |
+------------+-------------------------------------------------------------------------------+
| expires    | 2025-12-21T21:26:58+0000                                                      |
| id         | gAAAAABpRxSicY7hIwrN9rMoK7r02iSQL6BDWlpEz1cVf8OL-hjhRbk46RnU5WSplN7WBFl2Fwazo |
|            | WxKPBwk_tE3GDMiPFybr36NgrJ4Jatnh8-                                            |
|            | zAds2o2aPoHGbUq38x9MuBUO03BQ9_AopGZy5mHMLTTFwEGkvqjzTSmpv0GZhaMqW2RIwHaY      |
| project_id | 645991fee457443f99af44209bfd86e8                                              |
| user_id    | a29a4187f036465daf7a1b5ee34e03f2                                              |
+------------+-------------------------------------------------------------------------------+
+---------------+---------------+---------------+----------+---------+-------+---------------+
| ID            | Binary        | Host          | Zone     | Status  | State | Updated At    |
+---------------+---------------+---------------+----------+---------+-------+---------------+
| f805b589-     | nova-         | openstack-    | internal | enabled | up    | 2025-12-      |
| bf03-4e02-    | scheduler     | ubuntu        |          |         |       | 20T21:26:55.0 |
| 8933-         |               |               |          |         |       | 00000         |
| 9a51a2b4a71d  |               |               |          |         |       |               |
| a5f73452-     | nova-         | openstack-    | internal | enabled | up    | 2025-12-      |
| f6e3-48bc-bd1 | conductor     | ubuntu        |          |         |       | 20T21:26:57.0 |
| 3-            |               |               |          |         |       | 00000         |
| 7af2f6b197e8  |               |               |          |         |       |               |
| dc5832a8-     | nova-compute  | openstack-    | nova     | enabled | up    | 2025-12-      |
| 4ade-4774-    |               | ubuntu        |          |         |       | 20T21:26:56.0 |
| b202-         |               |               |          |         |       | 00000         |
| 237481f64adf  |               |               |          |         |       |               |
+---------------+---------------+---------------+----------+---------+-------+---------------+
```

the key here is the `OS_CLOUD` variable, but the easy fix is to just add this to your `.bashrc`:

```shell
export OS_CLOUD=kolla-admin
```

using the `clouds.yaml` and the `OS_CLOUD` variable is the current best practice.

you'll see/hear people say to use the `admin-openrc.sh` script or something like that, don't...that's the old way of doing things and not really great anymore

