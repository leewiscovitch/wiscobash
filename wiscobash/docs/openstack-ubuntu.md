# openstack-ubuntu

since the trashcan is x86-64-v2 and rhel10 (and clones) require x86-64-v3 had to make a compromise...ubuntu 24.04 is supported by openstack and can run on my hardware.

## pre-setup

### update

```shell
sudo apt update && \
sudo apt dist-upgrade -y && \
sudo apt autoremove -y && \
sudo apt autoclean && \
sudo snap refresh
```

>reboot if necessary

### sudo

```shell
sudo tee /etc/sudoers.d/tech > /dev/null << 'EOF'
tech ALL=(ALL) NOPASSWD: ALL
EOF
```

### prereqs

```shell
sudo apt update && \
sudo apt install -y git python3-dev libffi-dev gcc libssl-dev libdbus-glib-1-dev python3-venv ca-certificates curl
```

### docker

even though it doesn't mention it, we need it and will be following the official documentation:

<https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository>

```shell
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
sudo systemctl enable --now docker.service && \
sudo systemctl enable --now containerd.service && \
sudo usermod -aG docker $USER && \
newgrp docker
```

## install

### python virtual environment

```shell
mkdir -p ~/openstack && \
python3 -m venv ~/openstack && \
source ~/openstack/bin/activate && \
cd ~/openstack && \
pip install -U pip && \
pip install dbus-python && \
pip install docker && \
git clone --branch master https://opendev.org/openstack/kolla-ansible && \
pip install -e ./kolla-ansible && \
sudo mkdir -p /etc/kolla && \
sudo chown $USER:$USER /etc/kolla && \
cp -r kolla-ansible/etc/kolla/* /etc/kolla && \
cp kolla-ansible/ansible/inventory/* . && \
kolla-ansible install-deps
```

>had to add `pip install docker` for some reason

## configure

### kolla-ansible

#### passwords

pretty much each server, object, endpoint etc has a password...so there are like 40,000 to set!

luckily we don't need to know them, and this script/process sets them all for us:

```shell
cd kolla-ansible/tools && \
./generate_passwords.py
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
kolla_base_distro: "ubuntu"
network_interface: "ens18"
neutron_external_interface: "ens19"
kolla_internal_vip_address: "192.168.1.70"
```

and here in the appending process:

```shell
tee -a /etc/kolla/globals.yml > /dev/null << 'EOF'

###config###
kolla_base_distro: "ubuntu"
network_interface: "ens18"
neutron_external_interface: "ens19"
kolla_internal_vip_address: "192.168.1.70"
###config###
EOF
```

## deploy

now we're ready to run the configure ansible playbooks to deploy the environment!

### run playbooks

now we run the playbooks to get everything deployed

```shell
cd ~/openstack && \
kolla-ansible bootstrap-servers -i ./all-in-one && \
kolla-ansible prechecks -i ./all-in-one && \
kolla-ansible deploy -i ./all-in-one
```

finally finished, powerer off and take a snapshot!
