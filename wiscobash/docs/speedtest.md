
how to add speedtest.net cli? sadly no `latest` link, current one is:

https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz


or maybe use iperf3 with public servers

<https://iperf.fr/iperf-servers.php>

or there is this older application called `fast` that seems to work and has an AUR

<https://github.com/ddo/fast?tab=readme-ov-file>

paru -S fast

can't tell for sure but sounds like it's hitting fast.com (official site offered up by netflix)



then there is this, which is a small single binary with no dependencies

<https://github.com/mikkelam/fast-cli>

```shell
./fast-cli -u
✔ 🏓 45ms | ⬇️ Download: 288.3 Mbps | ⬆️ Upload: 21.1 Mbps
```

looks like the current winner



but then there is librespeed

https://github.com/librespeed/speedtest-cli

has a web interface: https://librespeed.org/

cli is pretty robust, it picks a server at random but you can specify one, the list of servers is here:

https://librespeed.org/backend-servers/servers.php

atlanta is server id `53` so the commmand used was `librespeed-cli --server 53` and looked fairly accurate

this one gets me approval so far



and this seems to be a one-liner that works well:

curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
