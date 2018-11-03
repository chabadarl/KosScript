
if exists ("1:/boot") deletepath("1:/boot").
createdir("1:/boot/").
copypath("0:/boot/boot.ks","1:/boot/boot.ks").
set core:bootfilename to "/boot/boot.ks".
reboot.
