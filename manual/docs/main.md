# wiscofed

## hardware

HP EliteBook 640 G11

* cpu: ultra 7 155u
* ram: 16gb
* nvme: 500gb

## os

installed fedora 43 workstation, enabled 3rd party repo, updated everything and set basic settings without any third party tools/apps

## sudo

```shell
sudo tee /etc/sudoers.d/tech > /dev/null << 'EOF'
tech ALL=(ALL) NOPASSWD: ALL
EOF
```

## base apps

```shell
sudo dnf install -y btop ripgrep bat ncdu gnome-extensions-app p7zip-gui xmlstarlet
```

### ssh

```shell
tee ~/.ssh/config > /dev/null << 'EOF'
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
```

### cockpit

```shell
sudo dnf install -y cockpit cockpit-files cockpit-podman cockpit-selinux cockpit-machines libvirt && \
sudo systemctl enable --now cockpit.socket && \
sudo firewall-cmd --add-service=cockpit --permanent && \
sudo firewall-cmd --reload
```

you can now access locally via <http://localhost:9090> or remotely via <http://IP:9090>

### gnome extensions

after installing `gnome-extensions-app` we also need to install the [firefox extension](https://extensions.gnome.org/local/)

### git

configure basic settings:

```shell
git config --global user.email "lee@wiscovitch.org" && \
git config --global user.name "Lee Wiscovitch"
```

### vscode

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

### eza

it's not included in the default repos anymore, but there is a community maintained [repo](https://copr.fedorainfracloud.org/coprs/alternateved/eza/) that seems to be active/up to date

```shell
sudo dnf copr enable -y alternateved/eza && \
sudo dnf install -y eza
```

### starship

#### nerdfont

```shell
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git && \
cd nerd-fonts/ && \
./install.sh FiraCode
```

##### install

```shell
curl -sS https://starship.rs/install.sh | sh
```

##### configure

for now just use one of the presets, in this case `gruvbox-rainbow`

```shell
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

##### time

to change to 12 hour (am/pm) edit `~/.config/starship.toml` and set the following values:

```ini
[time]
disabled = false
style = "bg:color_bg1"
format = '[[  $time ](fg:color_fg0 bg:color_bg1)]($style)'
use_12hr = true
```

##### conda

add the following to the `[conda]` section to show the conda `(base)` environment:

```ini
ignore_base = false
```

## bashrc

to minimize the edits directly to `.bashrc` there will be an external bash script that will be sourced that contains all the relevant tweaks

the only edit to `.bashrc` is:

```shell
for bashrc_file in ~/.bashrc; do
    if ! grep -qF 'source ~/.wiscobash.sh' $bashrc_file; then
        echo "" >> $bashrc_file
        echo "#wiscobash.sh" >> $bashrc_file
        echo "source ~/.wiscobash.sh" >> $bashrc_file
    fi
done
```

### wiscobash.sh

this file sets up all the custom entries normally included in `.bashrc` organized by categories

each category is handled by having a directory containing bash scripts/snippets that are loaded

currently there are three categories being loaded:

* applications
* aliases
* functions

>it's important applications is first, since it will load things like `starship` that should be loaded before anything else

make sure to create each supporting directory

```shell
mkdir -p ~/.wiscobash/applications.d/ && \
mkdir -p ~/.wiscobash/aliases.d/ && \
mkdir -p ~/.wiscobash/functions.d/
```


create the `.wiscobash.sh` file with the following contents:

```shell
tee ~/.wiscobash.sh > /dev/null << 'EOF'
if [ -d ~/.wiscobash/applications.d/ ]; then
    for wiscobash_file in ~/.wiscobash/applications.d/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi

if [ -d ~/.wiscobash/aliases.d/ ]; then
    for wiscobash_file in ~/.wiscobash/aliases.d/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi

if [ -d ~/.wiscobash/functions.d/ ]; then
    for wiscobash_file in ~/.wiscobash/functions.d/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi
EOF
```

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