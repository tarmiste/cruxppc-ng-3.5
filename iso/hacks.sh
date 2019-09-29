#!/bin/sh

set -ex

# gnu-efi parallel build breakage
sed -i -e '15s/make/make -j1/' ports/opt/gnu-efi/Pkgfile
rm -f ports/opt/gnu-efi/.signature
