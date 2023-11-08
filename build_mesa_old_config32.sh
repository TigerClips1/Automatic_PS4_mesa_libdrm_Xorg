#!/bin/bash

pkgname=mesa
pkgver=22.0
pkgver_libdrm=2.4.116
pkgname_libdrm=libdrm

echo "Ubuntu/debian please enable deb-src"
mkdir 32-bit-old
cd 32-bit-old

rm -rf bulid32
#make sure to use a debian 32bit base distro
# Install build dependencies
sudo apt update
sudo apt-get install wget curl
sudo apt-get build-dep -y $pkgname $pkgname_libdrm xserver-xorg-core directx-headers-dev

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

sleep 10
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
meson configure build32
ninja $NINJAFLAGS -C build32
sudo ninja $NINJAFLAGS -C build32  install

sudo ln -s /usr/i386/libGLX_mesa.so.0 "${pkgdir}/usr/i386/libGLX_indirect.so.0"
sudo ln -s /usr/i386/x86_64/libOSMesa.so.8.0.0 "${pkgdir}/usr/i386/libOSMesa.so.6"

cd ..
mv drm-libdrm-$pkgver_libdrm.tar.gz libdrm-ps4.tar.gz

tar -xvzf libdrm-ps4.tar.gz

mv drm-libdrm-$pkgver_libdrm libdrm

cd libdrm 


patch -Np1 < ../libdrm.patch

sleep 10

meson setup build32 \
    --prefix /usr \
    --libdir i386 \
    --buildtype plain \
    --wrap-mode      nofallback \
    -D udev=false \
    -D valgrind=disabled \
    -D intel=enabled

meson configure build32s

ninja -C build32

meson test -C build32 -t 10

sudo ninja -C build32 install

cd ../
sudo cp -r mesa-ps4 libdrm /usr/i386/
sudo tar -cvzf ps4_mesa.tar.gz /usr/i386/

cd ../
read -p "Do you want to 32-bit-old folder? (Y/N) " answer
if [[ $answer == "Y" ]]; then
  echo "Deleteing, 32-bit-old make sure you install everything right and fix the patch error you see for mesa libdrm"
  rm -rf 32-bit-old
else
  exit 1
fi
 
echo "Script By TigerClips1"

echo "ps4linux.com"

exit
