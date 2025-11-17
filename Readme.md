# Cuckoo loader for Nest Gen 1 Thermostats (diamond)
This is a fork of [cuckoo_loader](https://github.com/cuckoo-nest/cuckoo_loader) for Nest Gen1 Thermostats. It has been slightly (poorly) modified to force the x-loader to boot from usb when it doesn't want to.

## Usage
There are two main steps to getting this to run:

### Build
Run the build.sh script. This will download numerous sources, apply patches and build all the various binaries.

### Run the exploit
Run the ./load_firmware.sh script. Once started, press and hold down the screen on the nest for approx 10s. You should see activity as follows:
```
[+] jump command: 0x6a425355
[+] jump command le: 0x6a425355
OMAP Loader 1.0.0
File 'x-load.bin' at 0x40200000, size 27868
File 'u-boot.bin' at 0x80100000, size 246572
File 'uImage' at 0x80a00000, size 6972252
[+] scanning for USB device matching 0451:d00e...
[+] successfully opened 0451:d00e (Texas Instruments OMAP3630)
[+] got ASIC ID - Num Subblocks [05], Device ID Info [01050136300707], Reserved [13020100], Ident Data [1215010000000000000000000000000000000000000000], Reserved [1415010000000000000000000000000000000000000000], CRC (4 bytes) [15090113bf3eef00000000]
[+] uploading 'u-boot.bin' (size 246572) to 0x80100000
[+] uploading 'uImage' (size 6972252) to 0x80a00000
[+] sending jump command: 0x6a425355, 0x80100000, 12
[+] jumping to address 0x80100000
[+] successfully transfered 3 files
```

The nest will then reboot and apply the original exploit which will install an ssh server and reset the root password

The new default root password is: `gtvh4ckr`

Note: This has only been ran on an older linux laptop. Millage may vary but feel free to open issues.

# Issues building
The script has been fully tested on a Ubuntu 24.04 64-Bit system, alongside a Debian 13 64-Bit system. I haven't tested any other distros, but as a hint you can check build.sh for the packages that are being inspected on a dpkg system.

## What next
Well.. you have root. There is a lot you can do from here. Please remember to change the default password. 

I will be adding more repos in relation to this project as time goes on. 

## Whats the name about
This forms part of a project I am naming Cuckoo. It is taken from the bird that moves into other species nests and lays their own eggs. Feels fitting.

## credits
The following repos have been inredibly helpful in getting this working:

https://github.com/exploiteers/NestDFUAttack

https://github.com/grant-h/omap_loader

https://github.com/dougg3/omap_loader/tree/reliability-fixes

## support
If this work is useful for you and you want to support me in some way, feel free to use the following link.

https://buymeacoffee.com/ajb34

