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