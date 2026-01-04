# openstack

setting up a simple poc using a libvirt vm with bare minimum specs running rocky 10

in this scenario we are doing the `developer` deployment...which not sure what is different than the `deployment/evaluation` version but we'll know by the end of this!

<https://docs.openstack.org/kolla-ansible/latest/user/quickstart-development.html>

<https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html>

***SPOILER ALERT!!!*** absolutely nothing different from what we could tell...very curious, maybe they used to deviate?

## post os install

full system update:

```shell
sudo dnf update -y && \
sudo dnf autoremoce -y && \
sudo dnf clean all
```

enable epel repo:

```shell
sudo dnf install -y epel-release && \
sudo dnf update -y && \
sudo dnf clean all
```

sudo tweak:

```shell
sudo tee /etc/sudoers.d/tech > /dev/null << 'EOF'
tech ALL=(ALL) NOPASSWD: ALL
EOF
```

updated hosts/hostname files

gnome tweaks:

* enable dark mode
* disable screen lock

## prereqs

### apps

```shell
sudo dnf install -y git python3-devel libffi-devel gcc openssl-devel python3-libselinux
```

### docker

even though it doesn't mention it, we need it and will be following the official documentation:

<https://docs.docker.com/engine/install/rhel/>

```shell
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc && \
sudo dnf install -y dnf-plugins-core && \
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo && \
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo systemctl enable --now docker && \
sudo usermod -aG docker $USER && \
newgrp docker
```

## install

### virtual environment

create a new virtual environment:

```shell
mkdir -p ~/openstack && \
python3 -m venv ~/openstack && \
source ~/openstack/bin/activate && \
pip install -U pip && \
git clone --branch master https://opendev.org/openstack/kolla-ansible && \
pip install -e ./kolla-ansible && \
sudo mkdir -p /etc/kolla && \
sudo chown $USER:$USER /etc/kolla && \
cp -r kolla-ansible/etc/kolla/* /etc/kolla && \
cp kolla-ansible/ansible/inventory/* . && \
kolla-ansible install-deps
```

## configure

### kolla-ansible

#### passwords

pretty much each server, object, endpoint etc has a password...so there are like 40,000 to set!

luckily we don't need to know them, and this script/process sets them all for us:

```shell
cd kolla-ansible/tools && \
./generate_passwords.py
...
WARNING: Passwords file "/etc/kolla/passwords.yml" is world-readable. The permissions will be changed.
```

#### globals.yml

`/etc/kolla/globals.yml` is the main config file, so you'll be accessing/editing it the most

the flle in it's current state is just a heavily documented/commented yml. there is only one active/uncommented line:

```yaml
workaround_ansible_issue_8743: true
```

>and that is just to address an `ansible` edge-case

so with that in mind, we'll just append our required settings to the end of the file for now.

those settings are:

```yml
kolla_base_distro: "rocky"
network_interface: "enp1s0"
neutron_external_interface: "enp2s0"
kolla_internal_vip_address: "192.168.122.254"
```

and here in the appending process:

```shell
tee -a /etc/kolla/globals.yml > /dev/null << 'EOF'

###config###
kolla_base_distro: "rocky"
network_interface: "enp1s0"
neutron_external_interface: "enp2s0"
kolla_internal_vip_address: "192.168.122.254"
###config###
EOF
```

## deploy

now we're ready to run the configure ansible playbooks to deploy the environment!

### quickfix

found these out at the last minute:

>these should be ran in venv (`source ~/openstack/bin/activate`)

```shell
sudo dnf install -y dbus-devel glib2-devel && \
pip install dbus-python
```

### run playbooks

now we run the playbooks to get everything deployed

```shell
cd ~ && \
kolla-ansible bootstrap-servers -i ./all-in-one && \
kolla-ansible prechecks -i ./all-in-one && \
kolla-ansible deploy -i ./all-in-one
```

>had to re=run the last one, sounded like a temporary internet/server glitch outside of my control

finally finished, powerer off and take a snapshot!

## usage

we'll be referencing the official documentation for a lot of this:

<https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html#using-openstack>

but also other sources, when noted

### cli client

this is the latest office cli client we can install:

>this should be done in the venv (`source ~/openstack/bin/activate`)

```shell
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
```

### post-deploy

not 100% sure, but I believe this playbook uses the previously install cli client for some of it's tasks:

```shell
kolla-ansible post-deploy -i ./all-in-one
```

that playbook creates several files, but the one we're primarily concerned with is:

* `/etc/kolla/clouds.yaml`

that is the magic file that makes things like the cli client (and terraform) work with this environment

in order for it to be used in needs to be placed in one of two places:

* `/etc/openstack/clouds.yaml`
  * that would be for system-wide and/or service-level access
* `~/.config/openstack/clouds.yaml`
  * that would be for per-user access

>since the ultimate goal of this is to have a cloud-compatible platform in which to use standard devops tools again, we'll focus on the per-user access method.

#### per-user

for any user to be able to access the openstack instance they will need three things:

* `clouds.yaml`
  * this is file that contains all the necessary info to connect to the openstack instance
* `$OS_CLOUD`
  * this will describe what openstack access group you are apart of
* some form of compatible client
  * for this we'll use the previously mentioned cli client, but eventually terraform becomes the client

##### clouds.yaml

this was generated during the `post-deploy` task

it is located at `/etc/kolla/clouds.yaml`

we need to create the directory that will hold the file, and set proper permissions as well:

```shell
mkdir -p ~/.config/openstack && \
sudo cp /etc/kolla/clouds.yaml ~/.config/openstack/clouds.yaml && \
sudo chown $USER:$USER ~/.config/openstack/clouds.yaml
```

##### $OS_CLOUD

this is a simple environment variable that describes what openstack access group you are a member of

we just need to add this to the end the user's `.bashrc` file and then close/open their terminal session

```shell
export OS_CLOUD=kolla-admin
```

>what does that value mean? can you change/rename it? where does it come from? don't know...yet!

##### compatible client

as mentioned the official cli client is probably the most popular for dev/test and more low-level access to it

other compatible clients would be terraform, opentofu, ansible and numerous other devops applications/platforms

for now we will focus on the cli client...its already installed to the user in this scenario

but it's easy to install if you need to. make sure you're in the correct venv and then run:

```shell
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
```

>looking into how/why/if it can be installed system-wide

##### verification

assuming you have the previous sections/requirements handled, you should be execute the following (from inside the venv):

```shell
openstack --version
openstack token issue
openstack compute service list
```

that should respond with:

```shell
openstack 8.2.0
+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                                        |
+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
| expires    | 2025-12-22T01:59:48+0000                                                                                                                     |
| id         | gAAAAABpR1SU_6oHMtEUGfJUu4Lv4VG9cCKzl0R4Tn6gQMCUMrtFfabNONhP0qEhnaGxjLOwNBmpyoZib63Qvp1eOtZPDULxuxw9eJSv1_ygV38bD0wNZeotzbMZj3ixmmU0ISTzBpJV |
|            | lmadLVz-qejDQKhVZC7MlDvsDDswmpzyGK-KkMsz4Qs                                                                                                  |
| project_id | 05d595e14659437f9ef2af6425dd8a51                                                                                                             |
| user_id    | 1bc1a1119f1249a2bd73d74c4630cbb7                                                                                                             |
+------------+----------------------------------------------------------------------------------------------------------------------------------------------+
+--------------------------------------+----------------+--------------------------------+----------+---------+-------+----------------------------+
| ID                                   | Binary         | Host                           | Zone     | Status  | State | Updated At                 |
+--------------------------------------+----------------+--------------------------------+----------+---------+-------+----------------------------+
| d1a12ea4-0521-4bf3-b66b-a0c80fff0374 | nova-scheduler | openstack-rocky.wiscovitch.org | internal | enabled | up    | 2025-12-21T01:59:47.000000 |
| 62434e08-9032-47c6-bba0-0b0c94f08982 | nova-conductor | openstack-rocky.wiscovitch.org | internal | enabled | up    | 2025-12-21T01:59:44.000000 |
| f5567a8e-3b74-436e-b4fd-70276ac85096 | nova-compute   | openstack-rocky.wiscovitch.org | nova     | enabled | up    | 2025-12-21T01:59:44.000000 |
+--------------------------------------+----------------+--------------------------------+----------+---------+-------+----------------------------+
```

>do we know what any of the means? no...not yet!!!

## notes

### client environment setup

you'll see/hear people say to use the `admin-openrc.sh` script or something like that
that's the old way of doing things and not really great anymore, but apparently there may be situations it could be useful to have
