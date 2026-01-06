# todo

these are parts from the old wiscobash that need to be integrated

# environment variables

## set system context for normal user

```shell
export LIBVIRT_DEFAULT_URI="qemu:///system"
```

# init

this is all the "good" stuff but only for rhel

```shell

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
virsh pool-define-as --name wiscobash-cloud --type dir --target /home/tech/wiscobash/virt/boot && \
virsh pool-start wiscobash-cloud && \
virsh pool-autostart wiscobash-cloud

virsh pool-define-as --name wiscobash-iso --type dir --target /home/tech/wiscobash/virt/iso && \
virsh pool-start wiscobash-iso && \
virsh pool-autostart wiscobash-iso

virsh pool-define-as --name wiscobash-disks --type dir --target /home/tech/wiscobash/virt/disks && \
virsh pool-start wiscobash-disks && \
virsh pool-autostart wiscobash-disks

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
```

# miniconda

## install

```shell
mkdir ~/wiscobash/opt/miniconda && \
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/wiscobash/opt/miniconda/installer.sh && \
bash ~/wiscobash/opt/miniconda/installer.sh -b -u -m -p ~/wiscobash/opt/miniconda
```

## intialize

```shell
tee ~/.wiscobash/applications.d/miniconda.sh > /dev/null << 'EOF'
__conda_setup="$('/home/tech/wiscobash/opt/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tech/wiscobash/opt/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/tech/wiscobash/opt/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/tech/wiscobash/opt/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
export CONDARC=~/.wiscobash/etc/condarc
conda deactivate
EOF
```

>the last line (`conda deactivate`) is a fix/patch to address the `(base)` env loading even though it shouldn't based on conda config below

## configure

in order to store the `.condarc` in `~/.wiscobash/etc/condarc` we'll use the environment variable `CONDARC`

>this is already in the initialize script

create the directory that will contain the environments:

```shell
mkdir ~/wiscobash/envs
```

```shell
tee ~/.wiscobash/etc/condarc > /dev/null << 'EOF'
channel_priority: strict
channels:
  - conda-forge
  - defaults
default_channels:
  - https://repo.anaconda.com/pkgs/main
envs_dirs:
  - ~/wiscobash/envs
auto_activate: false
EOF
```

## aliases

should make some aliases for:

* activate env
* deactivate env
* update/update all

# sudo

```shell
sudo tee /etc/sudoers.d/tech > /dev/null << 'EOF'
tech ALL=(ALL) NOPASSWD: ALL
EOF
```

# base apps

```shell
sudo dnf install -y btop ripgrep bat ncdu gnome-extensions-app p7zip-gui xmlstarlet
```

# ssh

```shell
tee ~/.ssh/config > /dev/null << 'EOF'
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
```

# git

configure basic settings:

```shell
git config --global user.email "lee@wiscovitch.org" && \
git config --global user.name "Lee Wiscovitch"
```

# vscode

>currently only for rhel

add official repo:

```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
```

then install:

```shell
sudo dnf install -y code
```

set as default text editor:

```shell
xdg-mime default code.desktop text/plain
```

# eza

it's not included in the default repos anymore, but there is a community maintained [repo](https://copr.fedorainfracloud.org/coprs/alternateved/eza/) that seems to be active/up to date

```shell
sudo dnf copr enable -y alternateved/eza && \
sudo dnf install -y eza
```









the rest are scripts that some have been implimented but most haven't...and also need some things installed first

#### applications

##### starship

enable the starship shell enchancement

```shell
tee ~/.wiscobash/applications.d/starship.sh > /dev/null << 'EOF'
eval "$(starship init bash)"
EOF
```

#### aliases

##### eza

this will replace `ls` with `eza`
also adds `lsx` which will run `eza -la`

```shell
tee ~/.wiscobash/aliases.d/eza.sh > /dev/null << 'EOF'
alias ls="eza"
alias lsx="eza -la"
EOF
```

##### bat

this will replace `cat` with `bat` and configure it to act like it (no line numbers or pager)

```shell
tee ~/.wiscobash/aliases.d/bat.sh > /dev/null << 'EOF'
alias cat="bat --style=plain --paging=never"
EOF
```

##### dnf

this will run: update, autoremove and clean all

```shell
tee ~/.wiscobash/aliases.d/dnf.sh > /dev/null << 'EOF'
alias update="sudo dnf update -y &&  sudo dnf autoremove -y && sudo dnf clean all -y"
EOF
```

##### ports

this will run `ss` with all the parameters to see open/listening ports

```shell
tee ~/.wiscobash/aliases.d/ss.sh > /dev/null << 'EOF'
alias ports="sudo ss -tunlap"
EOF
```

##### meminfo

this will run `free` with all the parameters to show current memory statistics

```shell
tee ~/.wiscobash/aliases.d/meminfo.sh > /dev/null << 'EOF'
alias meminfo="free -mlth"
EOF
```

##### df

this will make `df` always use `-h`

```shell
tee ~/.wiscobash/aliases.d/df.sh > /dev/null << 'EOF'
alias df="df -h"
EOF
```

##### psx

this will create a new command `psx` that uses `ps` to show the processes from all users

```shell
tee ~/.wiscobash/aliases.d/psx.sh > /dev/null << 'EOF'
alias psx="sudo ps auxf"
EOF
```

##### mkdir

this will make `mkdir` use more desired parameters

```shell
tee ~/.wiscobash/aliases.d/mkdir.sh > /dev/null << 'EOF'
alias psx="mkdir -pv"
EOF
```

##### root

this will use `sudo` to switch to `root`

```shell
tee ~/.wiscobash/aliases.d/root.sh > /dev/null << 'EOF'
alias root="sudo -i"
EOF
```

##### reboot/poweroff

this will simply prepend `sudo` to the `reboot` and `poweroff` commands

```shell
tee ~/.wiscobash/aliases.d/power.sh > /dev/null << 'EOF'
alias reboot="sudo /sbin/reboot"
alias poweroff="sudo /sbin/poweroff"
EOF
```

##### wget

this will set `wget` always in resume mode

```shell
tee ~/.wiscobash/aliases.d/wget.sh > /dev/null << 'EOF'
alias wget="wget -c"
EOF
```

##### cpx

this will use `rsync` to mimic `cp` but with a progress bar, recurisive and resumable

```shell
tee ~/.wiscobash/aliases.d/cpx.sh > /dev/null << 'EOF'
alias cpx="rsync -ah --info=progress2"
EOF
```

##### cd..

catch a common issue where you enter `cd..` instead of `cd ..`

```shell
tee ~/.wiscobash/aliases.d/cd.sh > /dev/null << 'EOF'
alias cd..="cd .."
EOF
```

##### refresh

reloads the `.bashrc` so you can see any changes made without having to logout/login

```shell
tee ~/.wiscobash/aliases.d/refresh.sh > /dev/null << 'EOF'
alias refresh="source ~/.bashrc"
EOF
```

##### editrc

open `.bashrc` in `nano` for quick editing

```shell
tee ~/.wiscobash/aliases.d/editrc.sh > /dev/null << 'EOF'
alias editrc="nano ~/.bashrc"
EOF
```

##### systemd

these are shortcuts for enabling, stopping, starting, restarting and status for systemd services

```shell
tee ~/.wiscobash/aliases.d/systemd.sh > /dev/null << 'EOF'
alias sysd-enable="sudo systemctl enable --now"
alias sysd-disable="sudo systemctl disable"
alias sysd-start="sudo systemctl start"
alias sysd-stop="sudo systemctl stop"
alias sysd-restart="sudo systemctl restart"
alias sysd-status="sudo systemctl status"
alias sysd-reload="sudo systemctl daemon-reload"
EOF
```

##### extip

this will show the external ip address of the network the host is on

```shell
tee ~/.wiscobash/aliases.d/extip.sh > /dev/null << 'EOF'
alias extip="curl ifconfig.co -4"
EOF
```

>update/change to function so you can run something ilke `extip -v` and it will get the external ip and get info using `curl "https://api.ipapi.is/?q=97.201.53.173"`

##### terraform

>should shrink the names eventually, to like `terra-apply` and such

```shell
tee ~/.wiscobash/aliases.d/terraform.sh > /dev/null << 'EOF'
alias terraform-apply="sudo time -f "%E" terraform apply"
alias terraform-destroy="sudo terraform destroy"
alias terraform-init="sudo terraform init"
alias terraform-validate="sudo terraform validate"
EOF
```

##### opentofu

>should shrink the names eventually, to like `tofu-apply` and such

```shell
tee ~/.wiscobash/aliases.d/opentofu.sh > /dev/null << 'EOF'
alias tofu-apply="time tofu apply"
alias tofu-destroy="tofu destroy"
alias tofu-init="tofu init"
alias tofu-validate="tofu validate"
EOF
```


##### default text editor

```shell
tee ~/.wiscobash/aliases.d/editor.sh > /dev/null << 'EOF'
export EDITOR=nano
export VISUAL=nano
EOF
```

#### functions

##### mkcd

this is a function that will create a new directory and then cd into it

```shell
tee ~/.wiscobash/functions.d/mkcd.sh > /dev/null << 'EOF'
function mkcd {
  mkdir -p $1
  cd $1
}
EOF
```

##### extract

this function should accept a compressed file and then extract it with the correct app based off file extension, or ignore it

```shell
tee ~/.wiscobash/functions.d/extract.sh > /dev/null << 'EOF'
function extract {
 if [ -z "$1" ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 else
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "Error: File '$n' does not exist"
          return 1
      fi
    done
fi
}
EOF
```

##### tailx

this will tail a file with wanted parameters, if no file is provided it will default to `/var/log/messages`

```shell
tee ~/.wiscobash/functions.d/tailx.sh > /dev/null << 'EOF'
function tailx {
    local file="${1:-/var/log/messages}" 
    if [[ -f "$file" ]]; then
        sudo tail -F -n 1000 "$file"
    else
        echo "Error: File '$file' does not exist"
        return 1
    fi
}
EOF
```





while working with packer can see the need for a function that:
* deletes the `build` folder
* some other small tweaks
* starts `time` with saner parameters and make it survive the stops

also...what is a good `time` output?!? I just want `it took xxx.xxss` and nothing else