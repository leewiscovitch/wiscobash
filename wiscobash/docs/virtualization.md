# virtualization

we'll be relying on the built-in kvm hypervisor, using `virt-manager` to administer it

## virt-manager

### install

```shell
sudo dnf install -y virt-manager libguestfs cloud-init && \
sudo systemctl start libvirtd
```

### directories

```shell
mkdir ~/wiscobash/virt && \
mkdir ~/wiscobash/virt/boot && \
mkdir ~/wiscobash/virt/boot-scratch && \
mkdir ~/wiscobash/virt/iso && \
mkdir ~/wiscobash/virt/disks
```

### user config

```shell
sudo usermod -aG libvirt $USER && \
sudo usermod -aG kvm $USER && \
newgrp libvirt && \
newgrp kvm
```

#### system context

this makes it so you connect at the system level instead of user...gives you access to a few more things

```shell
tee ~/.wiscobash/applications.d/libvirt.sh > /dev/null << 'EOF'
export LIBVIRT_DEFAULT_URI="qemu:///system"
EOF
```

### storage pools

#### boot

```shell
virsh pool-define-as --name wiscobash-boot --type dir --target /home/tech/wiscobash/virt/boot && \
virsh pool-start wiscobash-boot && \
virsh pool-autostart wiscobash-boot
```

#### boot-scratch

```shell
virsh pool-define-as --name wiscobash-boot-scratch --type dir --target /home/tech/wiscobash/virt/boot-scratch && \
virsh pool-start wiscobash-boot-scratch && \
virsh pool-autostart wiscobash-boot-scratch
```


#### iso

```shell
virsh pool-define-as --name wiscobash-iso --type dir --target /home/tech/wiscobash/virt/iso && \
virsh pool-start wiscobash-iso && \
virsh pool-autostart wiscobash-iso
```

#### disks

```shell
virsh pool-define-as --name wiscobash-disks --type dir --target /home/tech/wiscobash/virt/disks && \
virsh pool-start wiscobash-disks && \
virsh pool-autostart wiscobash-disks
```

### safe shutdown

by default if you have running vms and you shutdown/reboot the host then they are all just immediately powered off

to change that so they safely shutdown, we have to create a config file and enable a service:

```shell
sudo tee /etc/sysconfig/libvirt-guests > /dev/null << 'EOF'
ON_SHUTDOWN="shutdown"
SHUTDOWN_TIMEOUT=60
EOF
sysd-enable libvirt-guests
```

# unconfirmed

could be valid information, but probably isn't. and even if it is, formatting and error checking is on you
## cloning

for now, use `virt-manager` to clone a machine. select the vm then right-click and select clone

change the name of the vm and select the disk and click `Details` to rename the disk file to something logical

after that is complete use `virt-sysprep` to get the new vm ready (mostly changes mac address and system-id)

```shell
sudo virt-sysprep -a $DISK_FILE
```

>replace `$DISK_FILE` with a valid path to the new disk file created when cloning

in most cases after this is done you'll be able to login and the next step would be to change the host name

>this was done manually editing `/etc/hosts` and `/etc/hostname` and then rebooting

more information on automating this can be found here:

<https://dev.to/mediocredevops/cloning-kvm-snapshots-1paj>

## dhcp

when installed a default nat network is created with a dhcp service available

if you need to disable that, find the network in the `virt-manager` and edit the xml

remove the `<dhcp>` section and then save and reboot

however, for some reason if you want to add it back, it won't save the settings via `virt-manager`

although after looking at the xml file (`/etc/libvirt/qemu/networks/default.xml`) it does show there...so maybe just a `virt-manager` glitch

## networks

for various reasons you might want to duplicate the `default` network, which is setup as a nat network.

create the xml file:

```shell
mkdir ~/wiscobash/virt/networks && \
tee ~/wiscobach/virt/networks/secondary.xml > /dev/null << 'EOF'
<network>
  <name>secondary</name>
  <uuid>0a5d698c-8d99-411c-bc9f-df8d0884c4dc</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:eb:66:88'/>
  <ip address='192.168.222.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.222.100' end='192.168.222.199'/>
    </dhcp>
  </ip>
</network>
EOF
```

>that xml is already altered to not interfer with the `default` network

then you have to use `virsh` to apply the network:

```shell
sudo virsh net-define ~/wiscobach/virt/networks/secondary.xml && \
sudo virsh net-start ~/wiscobach/virt/networks/secondary.xml && \
sudo virsh net-autostart ~/wiscobach/virt/networks/secondary.xml
```