
#devops

##install repo
sudo tee /etc/yum.repos.d/hashicorp.repo > /dev/null << 'EOF'
[hashicorp]
name=Hashicorp Stable - $basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg

[hashicorp-test]
name=Hashicorp Test - $basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/$releasever/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF

##install applications
sudo dnf install -y opentofu && \
sudo dnf install -y terraform && \
sudo dnf install -y packer && \
sudo dnf install -y ansible ansible-collection-community-general

#virtualization

##install applications
sudo dnf install -y virt-manager libguestfs cloud-init

##add user to groups
sudo usermod -aG libvirt $USER && \
sudo usermod -aG kvm $USER

##storage pools
```shell
virsh pool-define-as --name wiscobash-cloud --type dir --target /home/tech/wiscobash/virt/boot && \
virsh pool-start wiscobash-cloud && \
virsh pool-autostart wiscobash-cloud

virsh pool-define-as --name wiscobash-iso --type dir --target /home/tech/wiscobash/virt/iso && \
virsh pool-start wiscobash-iso && \
virsh pool-autostart wiscobash-iso

virsh pool-define-as --name wiscobash-disks --type dir --target /home/tech/wiscobash/virt/disks && \
virsh pool-start wiscobash-disks && \
virsh pool-autostart wiscobash-disks
```

##safe shutdown
sudo tee /etc/sysconfig/libvirt-guests > /dev/null << 'EOF'
ON_SHUTDOWN="shutdown"
SHUTDOWN_TIMEOUT=60
EOF
sudo systemctl enable --now libvirt-guests

#miniconda

##install application
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/wiscobash/opt/miniconda/installer.sh && \
bash ~/wiscobash/opt/miniconda/installer.sh -b -u -m -p ~/wiscobash/opt/miniconda 


#cockpit

<https://wiki.archlinux.org/title/Cockpit>

##install application
sudo dnf install -y cockpit cockpit-files cockpit-podman cockpit-selinux cockpit-machines libvirt && \
sudo systemctl enable --now cockpit.socket && \
sudo firewall-cmd --add-service=cockpit --permanent && \
sudo firewall-cmd --reload

#eza
sudo dnf install -y eza

#starship

##install application
curl -sS https://starship.rs/install.sh | sh

##configure
starship preset gruvbox-rainbow -o ~/.config/starship.toml

#need to figure out how to do this idempotently
#needs to be in starship.toml
[time]
disabled = false
style = "bg:color_bg1"
format = '[[  $time ](fg:color_fg0 bg:color_bg1)]($style)'
use_12hr = true

[conda]
ignore_base = false