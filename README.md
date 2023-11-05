### how to setup     

`git clone https://github.com/TigerClips1/Automatic_PS4_mesa_libdrm_Xorg`

`cd Automatic_PS4_mesa_libdrm_Xorg`


`chmod +x *`

### if you want new mesa to test aka 23.0 run for 64bit

`./build_mesa_new_config64.sh`  this works for debian/Ubuntu and fedora

### now you need 32bit so run

`./build_mesa_new_config32.sh` 

#### only works for debian  distro that 32bit support reson why i did not include the commands to comepile 32bit mesa on a 64bit mesa is becuse that hard and you will have alot of issue

now if you have an error for the mesa drivers then add those missing mesa drives patch in the mesa.patch file so find out the path where you got a hulk error then add the patches where there error are at then try to comepile it and it will this is an issue only for the mesa 23.0 the old one don't have that issue

###### now if you want to comepile the old mesa drivers run 

`./build_mesa_old_config64.sh` and this work for debian and ubuntu and fedora 

### if you want to comepile old 32bit drivers mesa 22.0.4 run
`/build_mesa_old_config32.sh`

that it everything if you any issue go ask for help in the htttps://ps4linux.com/forums



special thanks to [marcan](https://github.com/marcan)- without him then linux will not be posable for the ps4

special thanks to [Noob404](https://github.com/noob404yt) - for contirb to ps4linux

special thanks to [zerbuu](https://ps4linux.com/forums/u/zerobou)-without him we would not have newer mesa drivers

special thanks to [codedwrench](https://github.com/codedwrench)-5.15 kernel

Copyright ©TigerClips1 2023 All Rights Reserved
