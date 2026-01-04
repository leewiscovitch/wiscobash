# hashicorp

mostly will focus on `terraform` but there are other tools that may be used eventually

## repo

install the official repo:

```shell
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
```

## terraform

### install

```shell
sudo dnf install -y terraform
```

### configure

## packer

### install

```shell
sudo dnf install -y packer
```