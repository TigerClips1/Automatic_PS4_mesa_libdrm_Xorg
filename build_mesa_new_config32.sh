#!/bin/bash

pkgname=mesa
pkgver=23.0
pkgver_libdrm=2.4.117
pkgname_libdrm=libdrm

echo "debian please enable deb-src"

echo "Plese use a 32bit os for exmple debian it has be an debian base distro not ubuntu ubuntu no longer buliding 32bit version don't use fedora that code remove"
mkdir 32-bit
cd 32-bit

rm -rf bulid32

# Install build dependencies 32bit
sudo apt-get update
sudo apt-get install curl wget
sudo apt-get build-dep -y $pkgname $pkgname_libdrm xserver-xorg-core

# Download the source files
curl -O "https://gitlab.freedesktop.org/mesa/mesa/-/archive/$pkgver/mesa-$pkgver.tar.gz"
curl -O "https://gitlab.freedesktop.org/mesa/drm/-/archive/libdrm-$pkgver_libdrm/drm-libdrm-$pkgver_libdrm.tar.gz"
curl -O "https://raw.githubusercontent.com/Hakkuraifu/PS4Linux-ArchDrivers/main/SRC/libdrm-ps4/libdrm.patch"
# Extract the source files
tar -xvzf "mesa-$pkgver.tar.gz"
mv mesa-$pkgver mesa-ps4

cd mesa-ps4
echo "if the patch feil then see the 2 errors and go to the dir it show the error and open the .patch file and add those patches in that .c file or .h file  that in the .patch file then try to setup it \n"
echo "now the patch command will run again  don't worry about it the patches are there onece you add it in the first error "
patch  -Np1 < ../../mesa.patch

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
meson configure build32
ninja $NINJAFLAGS -C build32 
sudo ninja $NINJAFLAGS -C build32  install
sudo rm "${pkgdir}/usr/bin/mesa-overlay-control.py"
sudo ln -s /usr/i386/libGLX_mesa.so.0 "${pkgdir}/usr/i386/libGLX_indirect.so.0"
sudo ln -s /home/$USER/x86_64/libOSMesa.so.8.0.0 "${pkgdir}/home/$USER/x86_64/libOSMesa.so.6"
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
    -D intel=true

meson configure build32

ninja -C build32

meson test -C build32 -t 10

sudo ninja -C build32 install

echo "Script By TigerClips1"

cd ../..
read -p "Do you want to 32-bit folder? (Y/N) " answer
if [[ $answer == "Y" ]]; then
  echo "Deleteing, 32-bit make sure you install everything right and fix the patch error you see for mesa libdrm"
  rm -rf 32-bit
else
  exit 1
fi

exit
