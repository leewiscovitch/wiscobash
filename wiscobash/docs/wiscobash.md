# wiscobash

custom folders/files/configs deployed in a way that should work across any linux distro

there are two main parts to this:

* ~/.wiscobash
  * this will contain custom configs, aliases, functions and scripts
* ~/wiscobash
  * this will contain any binaries/files used...it should mimic the standard linux files system:
    * ~/wiscobash/bin
      * use this for single-file binaries
    * ~/wiscobash/opt
      * use this for directories hosting complex multi-file applications

## ~/.wiscobash

all of this content is currently in `README.md` and needs to be migrated here

one new thing to add is support for static config files for applications

```shell
mkdir ~/.wiscobash/etc
```

## ~/wiscobash

create folders

```shell
mkdir ~/wiscobash && \
mkdir ~/wiscobash/bin && \
mkdir ~/wiscobash/git && \
mkdir ~/wiscobash/opt
```

## configs

### add to path

we'll want to add select directories to the `$PATH`

#### wiscovitch/bin

add ~/wiscobash/bin to `$PATH`

```shell
tee ~/.wiscobash/applications.d/wiscobash.bin.sh > /dev/null << 'EOF'
export PATH="/home/tech/wiscobash/bin:$PATH"
EOF
```

