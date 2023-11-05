#!/bin/bash

pkgname=mesa
pkgver=22.0
pkgver_libdrm=2.4.117
pkgname_libdrm=libdrm

echo "Ubuntu/debian please enable deb-src"
mkdir 64-bit-old
cd 64-bit-old

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
    sudo apt update
    sudo apt-get build-dep -y $pkgname $pkgname_libdrm xserver-xorg-core 
    sudo apt-get install wget curl
else
    echo "Unsupported package manager. Please install either DNF or APT and run the script again."
    exit 1
fi

# Download the source files
curl -O "https://gitlab.freedesktop.org/mesa/mesa/-/archive/$pkgver/mesa-$pkgver.tar.gz"
curl -O "https://raw.githubusercontent.com/Hakkuraifu/PS4Linux-ArchDrivers/main/SRC/mesa-ps4/mesa.patch"
curl -O "https://gitlab.freedesktop.org/mesa/drm/-/archive/libdrm-$pkgver_libdrm/drm-libdrm-$pkgver_libdrm.tar.gz"
curl -O "https://raw.githubusercontent.com/Hakkuraifu/PS4Linux-ArchDrivers/main/SRC/libdrm-ps4/libdrm.patch"
# Extract the source files
tar -xvzf "mesa-$pkgver.tar.gz"
mv mesa-$pkgver mesa-ps4

cd mesa-ps4

patch  -Np1 < ../mesa.patch

# Build and install the package
meson setup  build32 \
    -D b_ndebug=true \
    -D b_lto=true \
    -D buildtype=plain \
    --wrap-mode=nofallback \
    -D prefix=/usr \
    -D sysconfdir=/etc \
    --libdir=/usr/i386 \
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
    -D gallium-xvmc=disabled \
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
meson configure bulid32
ninja $NINJAFLAGS -C bulid32
sudo ninja $NINJAFLAGS -C bulid32  install

# remove files provided by mesa-git
rm -rf "$pkgdir"/etc
rm -rf "$pkgdir"/usr/include
rm -rf "$pkgdir"/usr/share/glvnd/
rm -rf "$pkgdir"/usr/share/drirc.d/
rm -rf "$pkgdir"/usr/share/vulkan/explicit_layer.d/
rm -rf "$pkgdir"/usr/share/vulkan/implicit_layer.d/VkLayer_MESA_device_select.json

# remove script file from /usr/bin
# https://gitlab.freedesktop.org/mesa/mesa/issues/2230
rm "${pkgdir}/usr/bin/mesa-overlay-control.py"
rmdir "${pkgdir}/usr/bin"

ln -s /usr/lib32/libGLX_mesa.so.0 "${pkgdir}/usr/lib32/libGLX_indirect.so.0"

cd ..
mv drm-libdrm-$pkgver_libdrm.tar.gz libdrm-ps4.tar.gz

tar -xvzf libdrm-ps4.tar.gz

mv drm-libdrm-$pkgver_libdrm libdrm

cd libdrm 

patch -Np1 < ../libdrm.patch

meson setup build32 \
    --prefix /usr \
    --libdir i386 \
    --buildtype plain \
    --wrap-mode      nofallback \
    -D udev=false \
    -D valgrind=false
    -D intel=true

meson configure bulid32

ninja -C build32

meson test -C build32 -t 10

sudo ninja -C build32 install

rm -rf "$pkgdir"/usr/{include,share,bin}

echo "Script By TigerClips1"


exit
