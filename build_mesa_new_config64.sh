#!/bin/bash

pkgname=mesa
pkgver=23.0
pkgver_libdrm=2.4.117
pkgname_libdrm=libdrm
xorg_ver=22.0.0

echo "Ubuntu/debian please enable deb-src"
mkdir 64-bit
cd 64-bit

rm -rf bulid64

# Install build dependencies
# Check if the system uses DNF (Fedora) or APT (Debian/Ubuntu)
if command -v dnf &> /dev/null; then
    # Use DNF for Fedora
    if [ -n "$(sudo dnf 2>&1 | grep 'apt-get')" ]; then
        echo "Fedora is detected, but you have APT installed. Please install DNF and run the script again."
        exit 1
    fi
    echo "this not all of xorg build dep there still need to be install i will update this once i find it"
    sudo dnf update
    sudo dnf install curl wget
    sudo dnf builddep -y $pkgname $pkgname_libdrm xorg-x11-server
elif command -v apt-get &> /dev/null; then
    # Use APT for Debian/Ubuntu
    if [ -n "$(sudo apt-get 2>&1 | grep 'dnf')" ]; then
        echo "Debian/Ubuntu is detected, but you have DNF installed. Please install APT and run the script again."
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install curl wget
    sudo apt-get build-dep -y $pkgname $pkgname_libdrm xserver-xorg-core
else
    echo "Unsupported package manager. Please install either DNF or APT and run the script again."
    exit 1
fi

# Download the source files
curl -O "https://gitlab.freedesktop.org/mesa/mesa/-/archive/$pkgver/mesa-$pkgver.tar.gz"
curl -O "https://gitlab.freedesktop.org/mesa/drm/-/archive/libdrm-$pkgver_libdrm/drm-libdrm-$pkgver_libdrm.tar.gz"
curl -O "https://raw.githubusercontent.com/Hakkuraifu/PS4Linux-ArchDrivers/main/SRC/libdrm-ps4/libdrm.patch"
curl -O "https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu/-/archive/xf86-video-amdgpu-$xorg_ver/xf86-video-amdgpu-xf86-video-amdgpu-$xorg_ver.tar.gz"
curl -O "https://raw.githubusercontent.com/Hakkuraifu/PS4Linux-ArchDrivers/main/SRC/xf86-video-amdgpu-ps4/xf86-video-amdgpu.patch"
# Extract the source files
tar -xvzf "mesa-$pkgver.tar.gz"
mv mesa-$pkgver mesa-ps4

cd mesa-ps4

patch  -Np1 < ../../mesa.patch

sleep 10

# Build and install the package
meson setup  build64 \
    -D b_ndebug=true \
    -D b_lto=true \
    -D buildtype=plain \
    --wrap-mode=nofallback \
    -D prefix=/usr \
    -D sysconfdir=/etc \
    --libdir=/usr/x86_64 \
    -D platforms=x11,wayland \
    -D gallium-drivers=kmsro,radeonsi,r300,r600,nouveau,freedreno,swrast,v3d,vc4,etnaviv,tegra,i915,svga,virgl,panfrost,iris,lima,zink,d3d12,asahi,crocus \
    -D vulkan-drivers=amd,swrast,intel \
    -D dri3=enabled \
    -D egl=enabled \
    -D gallium-extra-hud=true \
    -D gallium-nine=true \
    -D gallium-omx=bellagio \
    -D gallium-va=enabled \
    -D gallium-vdpau=enabled \
    -D gallium-xa=enabled \
    -D gallium-omx=disabled \
    -D gbm=enabled \
    -D gles1=disabled \
    -D gles2=enabled \
    -D glvnd=true \
    -D glx=dri \
    -D libunwind=enabled \
    -D llvm=enabled \
    -D lmsensors=enabled \
    -D osmesa=true \
    -D shared-glapi=enabled \
    -D gallium-opencl=icd \
    -D valgrind=disabled \
    -D vulkan-layers=device-select,overlay \
    -D tools=[] \
    -D zstd=enabled \
    -D microsoft-clc=disabled \

#configue and install mesa for the ps4 in the /usr/x86_64 folder or path
meson configure build64
ninja $NINJAFLAGS -C build64 
sudo ninja $NINJAFLAGS -C build64  install
sudo rm "${pkgdir}/usr/bin/mesa-overlay-control.py"
sudo rmdir "${pkgdir}/usr/bin"
sudo ln -s /usr/x86_64/libGLX_mesa.so.0 "${pkgdir}/usr/x86_64/libGLX_indirect.so.0"
cd ..
mv drm-libdrm-$pkgver_libdrm.tar.gz libdrm-ps4.tar.gz

tar -xvzf libdrm-ps4.tar.gz

mv drm-libdrm-$pkgver_libdrm libdrm

cd libdrm 

patch -Np1 < ../libdrm.patch

sleep 10

meson setup build64 \
    --prefix /usr \
    --libdir x86_64 \
    --buildtype plain \
    --wrap-mode      nofallback \
    -D udev=false \
    -D valgrind=disabled \
    -D intel=true

meson configure build64

ninja -C build64

meson test -C build64 -t 10

sudo ninja -C build64 install

read -p 'How many cpu threads you want to comepile xorg-ps4: ' threads
cd ..
mv xf86-video-amdgpu-xf86-video-amdgpu-23.0.0.tar.gz ps4-xorg.tar.gz
tar -xvzf ps4-xorg.tar.gz
mv xf86-video-amdgpu-xf86-video-amdgpu-23.0.0 xorg-ps4

cd xorg-ps4

patch -Np1 < ../xf86-video-amdgpu.patch

sleep 10

echo "export CFLAGS=${CFLAGS/-fno-plt}
      export CXXFLAGS=${CXXFLAGS/-fno-plt}
      export LDFLAGS=${LDFLAGS/,-z,now}" | tee ~/.bashrc

source ~/.bashrc

./autogen.sh

./configure 
    --prefix=/home/$USER \
    --enable-glamor
  make -j $threads

make check

sudo make install

echo "Script By TigerClips1"

cd ../..
read -p "Do you want to Delete 64-bit folder? (Y/N) " answer
if [[ $answer == "Y" ]]; then
  echo "Deleteing, 64-bit make sure you install everything right and fix the patch error you see for mesa libdrm"
  rm -rf 64-bit
else
  exit 1
fi

echo "Please run bulid_mesa_new_config32.sh on a 32bit debian distro in a vm"

exit
