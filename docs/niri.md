# niri

tile-based display manager

<https://github.com/YaLTeR/niri>

<https://github.com/YaLTeR/niri/wiki/Getting-Started#main-default-hotkeys>

## install

```shell
sudo dnf copr enable -y avengemedia/dms && \
sudo dnf install -y niri dms mako && \
systemctl --user add-wants niri.service dms
```

reboot and then select `niri` at the login window (gear icon at the bottom-right)

## configure

base configuration is mostly fine, at first start configuration file `~/.config/niri/config.kdl`

>any way to change that to store in `~/.wiscobash/etc`? looks like can set `$NIRI_CONFIG`

edit the file and ensure the following settings are applied:

```ini
// natural-scroll
// spawn-at-startup "waybar"
```

>disabling `waybar` because `dms` is better

>might need to investigate <https://github.com/YaLTeR/niri/wiki/Example-systemd-Setup> but so far default install is fine

use the `dms` config gui to set sane values (dock, autohide, location for weather)

also need to factor in alacritty config...default looks fine, loads `starship` and act well...but are there other options that can be benificial?