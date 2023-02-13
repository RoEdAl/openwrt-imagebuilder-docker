# Image builders of thin OpenWRT-based Docker hosts for specific platforms

## Supported platforms

* NanoPi NEO,
* OrangePi One,
* OrangePi Zero *(experimental)*,
* Olimex oLinuXino Lime A10,
* Raspberry Pi A/B/B+/Zero.

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
   ...

  After successful execution you should find uncompressed image file at current directory.

## Booting OpenWRT

- First boot may take a long time.
- IP address is obtained from DHCP (NO STATIC ADDRESS). DHCP server should also serve address of NTP server.
- `root` account **is disabled** - login via SSH as `admin` (password `admin`). Use `sudo` in order to execute commands with elevated priviledges.
- There's no web interface.

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

## Blocky

```.bash
cd /etc/blocky
./compose-blocky
```

