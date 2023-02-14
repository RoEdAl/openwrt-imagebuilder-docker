# Image builders of thin OpenWRT-based Docker hosts for specific platforms

## Supported platforms

* [`friendlyarm_nanopi-neo`](platform/friendlyarm_nanopi-neo) - [NanoPi NEO](//www.friendlyelec.com/index.php?route=product/product&product_id=132),
* [`xunlong_orangepi-one`](platform/xunlong_orangepi-one) - [OrangePi One](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-One.html),
* [`xunlong_orangepi-zero`](platform/xunlong_orangepi-zero) - OrangePi Zero *(experimental)*,
* [`olimex_a10-olinuxino-lime`](platform/olimex_a10-olinuxino-lime) - [Olimex OLinuXino LIME A10](//www.olimex.com/Products/OLinuXino/A10/A10-OLinuXino-LIME-n4GB/open-source-hardware),
* [`rpi`](platform/rpi) - Raspberry Pi B(+)/Zero *(1st gen)*.

## Requirements

* Linux machine,
* [OpenWRT imagebuilder](//openwrt.org/docs/guide-user/additional-software/imagebuilder) requirements,
* `fuse-overlayfs` - userspace support of *overlay2* filesystem.

## Image building

1. Clone this repository:

    ```.bash
    git clone https://github.com/RoEdAl/openwrt-imagebuilder-docker.git
    cd openwrt-imagebuilder-docker
    ```

2. Select platform:

    ```.bash
    cd platform/olimex_a10-olinuxino-lime
    ```

3. Run `mkimg.sh` script.

    ```.bash
    ./mkimg.sh
    ```

   First run of this script fails.
   You must manually change configuration of image builder:

   ```.bash
   cd ../../openwrt/openwrt-imagebuilder-22.03.3-sunxi-cortexa8.Linux-x86_64
   nano .config
   ```

   find `CONFIG_TARGET_ROOTFS_PARTSIZE` config option and change its value to `280`:

   ```
   CONFIG_TARGET_ROOTFS_PARTSIZE=280
   ```

   Now back to platform's directory and run `mkimg.sh` again:

   ```.bash
   cd ../../platform/olimex_a10-olinuxino-lime
   ./mkimg.sh
   ```

  After successful execution you should find uncompressed image file at current directory.

## Booting OpenWRT

- First boot may take a long time.
- IP address is obtained from DHCP (**no static address**). DHCP server should also serve address of NTP server(s). Docker daemon starts **after** NTP synchronization.
- `root` account **is disabled** - login via SSH as `admin` (password `admin`). Use `sudo` in order to execute commands with elevated priviledges.
- There's **no web interface**.

## Composing Docker images

Make sure you're synced with NTP and `dockerd` is running:

```.bash
date
sudo service dockerd start
```

### Pi-hole

```.bash
cd /etc/pi-hole
./compose-pi-hole.sh
```

See: [Pi-hole in a docker container](//github.com/pi-hole/docker-pi-hole).

## Blocky

```.bash
cd /etc/blocky
./compose-blocky
```

See: [Fast and lightweight DNS proxy as ad-blocker for local network with many features](//github.com/0xERR0R/blocky).
