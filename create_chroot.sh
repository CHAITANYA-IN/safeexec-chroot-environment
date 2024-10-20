#!/bin/bash

# Constants
CHROOT_DIR="./chroot_dir"
DOWNLOADED_APT_PACKAGES_DIR="/tmp/chroot_packages"
PATH_ENV_VAR_IN_CHROOT="/usr/bin"
REQUIRED_PYTHON_PACKAGES=("python3" "python3-minimal" "python3-dev" "python3-doc" "python3-tk" "python3-venv" "python3.12" "libpython3-stdlib") # $ apt-cache depends python3

# Save the current directory
currentDirectory=$(pwd)

# Create chroot directory
mkdir -p $CHROOT_DIR
cd $CHROOT_DIR

# Create common directories and links of chrooted /
mkdir -p ./usr
mkdir -p ./usr/bin
mkdir -p ./usr/lib
mkdir -p ./usr/lib/x86_64-linux-gnu
mkdir -p ./lib64
mkdir -p ./etc
mkdir -p ./root
mkdir -p ./home
# mkdir -p ./submissions

ln -s usr/bin bin
ln -s usr/lib lib

# Setup Environment
cp /usr/bin/env ./usr/bin
touch ./etc/environment ./root/.bashrc

echo PATH=\"$PATH_ENV_VAR_IN_CHROOT\" > ./etc/environment
echo HOME='"/root"' >> ./etc/environment
echo USER='"root"' >> ./etc/environment
echo HOST='"safeexec-chroot"' >> ./etc/environment
echo PS1='"(chrooted) \$ "' > ./root/.bashrc

# C | C++ | SimpleCPP Libraries Setup
cp /usr/lib/x86_64-linux-gnu/{libgcc_s,libexpat,libz}.so.1 ./usr/lib/x86_64-linux-gnu
cp /usr/lib/x86_64-linux-gnu/{libstdc++,libm,libc}.so.6 ./usr/lib/x86_64-linux-gnu
cp /lib64/ld-linux-x86-64.so.2 ./lib64

# Python Setup
for pkg_name in ${REQUIRED_PYTHON_PACKAGES[@]}; do
    apt download $pkg_name
done
for pkg in ./*.deb; do
    dpkg-deb -x "$pkg" .
done
rm ./*.deb

# Tests
# cp /usr/bin/{bash,tree} ./usr/bin
# sudo chroot ./chroot_dir /bin/bash -c "source /root/.bashrc /etc/environment; exec /bin/bash"
# rm ./usr/bin/{bash,tree}

# Restore the current directory
cd $currentDirectory
