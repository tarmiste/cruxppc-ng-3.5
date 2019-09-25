
2019Jan16

## General development and usage ideas and notes:

A hodge podge of crux ppc thoughts and notes without much organization.

### General ports

.footprints sometimes mismatch simply due to building on powerpc vs x86.   Also the package .footprints can sometimes change a bit based on what was built
installed (or not) prior to the package build. 

It would be useful to be able to cross compile or distcc build of ports that
take a long time to build natively.  Use at least for flushing out the 
initial build problems after which, the final packages could be built 
natively.


### Core ports

The iptables 1.8.2 release does not build on PowerPC.  Bumped iptables down to 1.6.2 for now.   1.8.2 builds on the x86 CRUX so I'm not
exactly sure why it doesn't also build on PowerPC but it may be due to the slightly different kernel version of PowerPC (4.15) vs x86 (4.14).
The most recent snapshot from the iptables git repo builds fine on PowerPC so the problem should be gone when iptables-1.8.3 is released.
The iptables .signature file has to be removed after the change to 1.6.2 so that the build will not fail due to signature mismatch.

cruxppc does not support multi-lib.   Support for multilib was removed from glibc for powerpc.

PowerPC 32 bit seems to have a bug with stack protection checking so it is disabled for powerpc.   Hopefully it will get fixed in an upcoming 
release but I couldn't find a bug report in the gcc data base regarding it.

x86 specific core ports are lilo, glibc-32 (multilib), and grub

The powerpc yaboot cannot be built from source.   The port in here simply downloads the most recent working debian yaboot binary package and
repackages it into a crux package.  This is not ideal but works for now.   It looks like gentoo now uses grub instead of yaboot so grub might be usable as a replacement 
for yaboot.  



### Opt ports

libaio required a small change to CFLAGS to build.  x86 does not require this change.   Not sure why but it may be related to disabling of
stack protection for powerpc.

More recent nss versions don't build in cruxppc.  So, nss rev is backed down for powerpc.



