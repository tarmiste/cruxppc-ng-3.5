
25Sep2019S

## General development and usage ideas and notes:

A hodge podge of crux ppc thoughts and notes without much organization.

### General ports

.footprints sometimes mismatch simply due to building on powerpc vs x86.   Also the package .footprints can sometimes change a bit based on what was built
installed (or not) prior to the package build.    The packaging build tools provide an option to ignore .footprint files during the build.

It would be useful to be able to cross compile or distcc build of ports that take a long time to build natively.  Use at least for flushing out the 
initial build problems after which, the final packages could be built natively.


### Core ports

cruxppc does not support multi-lib.   Support for multilib was removed from glibc for powerpc.

PowerPC 32 bit seems to have a bug with stack protection checking so it is disabled for powerpc.   Hopefully it will get fixed in an upcoming 
release but I couldn't find a bug report in the gcc data base regarding it.

x86 specific core ports are lilo, glibc-32 (multilib), bin86, and grub

The powerpc yaboot cannot be built from source.   The port in here simply downloads the most recent working debian yaboot binary package and
repackages it into a crux package.  This is not ideal but works for now.   It looks like gentoo now uses grub instead of yaboot so grub might be usable as a replacement 
for yaboot.  



### Opt ports


### Xorg ports



