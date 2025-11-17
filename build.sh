#/bin/bash
packages=(
    "build-essential"
    "git"
    "cmake"
    "u-boot-tools"
    "libusb-1.0-0-dev"
    "pkg-config"
    "libc6:i386"
    "libstdc++6:i386"
    "zlib1g:i386"
)

if command -v dpkg >/dev/null 2>&1; then
    for pkg in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
            echo "Package '$pkg' is not installed. Exiting."
            exit 1
        fi
    done
    echo "All packages are installed."
else
    echo "Non-Debian system detected. Skipping package checks."
fi

mkdir -p build
cd ./build

echo "[I] - Downloading Nest toolchain."
mkdir -p  toolchain
cd toolchain
wget -c http://files.chumby.com/toolchain/arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2

echo "[I] - Extracting and setting up toolchain."
tar --skip-old-files -xjvf arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
PATH=$PATH:`pwd`/arm-2008q3/bin
echo $PATH
cd ..

if [ -d "NestDFUAttack-master/.git" ]; then
    echo "[I] - NestDfuAttack exists, updating..."
    cd NestDFUAttack-master
    git pull
    cd ..
else
    echo "[I] - Cloning NestDfuAttack..."
    git clone https://github.com/exploiteers/NestDFUAttack NestDFUAttack-master
fi

if [ -d "x-loader/.git" ]; then
    echo "[I] - x-loader exists, updating..."
    cd x-loader
    git pull
    cd ..
else
    echo "[I] - Cloning x-loader..."
    git clone https://nest-open-source.googlesource.com/nest-learning-thermostat/5.9.4/x-loader
fi

if [ -d "omap_loader/.git" ]; then
    echo "[I] - omap_loader exists, updating..."
    cd omap_loader
    git pull
    cd ..
else
    echo "[I] - Cloning omap_loader..."
    git clone https://github.com/ajb142/omap_loader.git
fi

echo "[I] - Cross compiling x-loader."
cd x-loader/x-loader
sed -i '/^[[:space:]]*puts("Images exhausted\\n");[[:space:]]*$/i\        do_usb();' lib/board.c # force x-loader to load usb when it fails to load anything else (instead of hang)
make HOSTCFLAGS+=" -std=gnu89" ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean 
make HOSTCFLAGS+=" -std=gnu89" ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- diamond-usb-loader_config # change j49 (gen2) to diamond (gen1)
make HOSTCFLAGS+=" -std=gnu89" ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
cd ../..
if [ ! -f x-loader/x-loader/x-load.bin ]
    then
        echo "[E] - Error, x-loader compile failed."
        exit
    fi

echo "[I] - Cross compiling u-boot."
pwd
cd NestDFUAttack-master/Dev/u-boot
cp ../../../../mods_u-boot/* ./
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- diamond
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
cd ../../..

if [ ! -f NestDFUAttack-master/Dev/u-boot/u-boot.bin ]
    then
        echo "[E] - Error, u-boot compile failed."
        exit
    fi

echo "[I] - Cross compiling Linux (this could take a few minutes.)"
cd NestDFUAttack-master/Dev/linux
cp -vR ../../../../mods_linux/* ./
make ARCH=arm distclean gtvhacker_defconfig
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- uImage
cd ../../..

if [ ! -f NestDFUAttack-master/Dev/linux/arch/arm/boot/uImage ]
    then
        echo "[E] - Error, Linux kernel compile failed."
        exit
    fi

echo "[I] - Compiling omap_loader for host machine."
cd omap_loader
git checkout send_correct_jump_for_nest
make clean
make
cd ..

mkdir -p bin
cd bin 
mkdir -p nest
mkdir -p host
cp ../omap_loader/omap_loader ./host
cp ../x-loader/x-loader/x-load.bin ./nest
cp ../NestDFUAttack-master/Dev/u-boot/u-boot.bin ./nest
cp ../NestDFUAttack-master/Dev/linux/arch/arm/boot/uImage ./nest
cd ../..
