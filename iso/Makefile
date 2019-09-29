#
# Makefile for CRUX
# Copyright (c) 2003-2005 Per Liden <per@fukt.bth.se>
#

CRUXVERSION       = 3.5
CUSTOMVERSION     =
COLLECTIONS       = core opt xorg
KERNEL_MIRROR     = https://cdn.kernel.org
KERNEL_VERSION    = 4.19.61
KERNEL_PATCHES    =
BB_VERSION        = 1.25.1
MEMTEST_VERSION   = 5.01
SYSLINUX_VERSION  = 6.03
PKG_EXT           = pkg.tar.xz
PKGMK_CONF        = $(PWD)/pkgmk.conf
PORTS_DIR         = $(PWD)/ports
FAKE_ROOT_DIR     = $(PWD)/tmp/fake_root
ROOTFS_DIR        = $(PWD)/tmp/rootfs
DATE_STR          = $(shell date +'%Y%m%d')
IMG_ROOT_DIR      = $(PWD)/tmp/img_root
SRCISO_ROOT_DIR   = $(PWD)/tmp/srciso_root
ISO_FILENAME      = $(PWD)/crux-$(CRUXVERSION)$(CUSTOMVERSION).iso
SRCISO_FILENAME   = $(PWD)/crux-$(CRUXVERSION)$(CUSTOMVERSION)-source.iso
ISO_PACKAGES      = filesystem bash dash coreutils bzip2 e2fsprogs jfsutils \
                    xfsprogs reiserfsprogs patch findutils glibc grep gzip kbd \
                    kmod less gawk ncurses inetutils pkgutils \
                    procps readline sed shadow sysklogd sysvinit tar \
                    util-linux vim which dialog nano mdadm pciutils libusb libusb-compat \
                    sysfsutils usbutils eudev zlib openssl openssh \
                    dhcpcd wget iproute2 libpcre iputils libgmp libdevmapper lvm2 \
                    attr acl libcap btrfs-progs lzo zstd parted xz \
                    efibootmgr efivar gnu-efi libmpfr dosfstools \
                    libgcrypt libgpg-error popt cryptsetup start-stop-daemon \
                    linux-firmware wpa_supplicant dbus libnl wireless-tools file \
                    elfutils linux-pam libaio json-c

PORTS_core        = $(shell /bin/ls -I README $(PORTS_DIR)/core)
PORTS_opt         = $(shell /bin/cat packages.opt)
PORTS_xorg        = $(shell /bin/cat packages.xorg)

ifeq ($(FORCE),yes)
PKGMK_FORCE=-f
else
PKGMK_FORCE=
endif

ifeq ($(DOWNLOAD),yes)
PKGMK_DOWNLOAD=-do
else
PKGMK_DOWNLOAD=-d
endif

.PHONY: help check-root check-log $(COLLECTIONS) all all-chroot bootstrap \
	initramfs kernel-clean clean iso \
	busybox-clean initramfs-clean memtest-clean syslinux-clean \
	grub2-efi grub2-efi-clean grub2-efi-distclean

help:
	@echo "CRUX Makefile"
	@echo "Targets:"
	@echo "  <collection>   build single collection"
	@echo "  all            build all collections"
	@echo "  bootstrap      bootstrap all collections"
	@echo "  kernel         download and build kernel"
	@echo "  iso            create iso image"
	@echo "Collections:"
	@echo "  $(COLLECTIONS)"

check-root:
	@if [ "$(shell id -u)" != "0" ]; then \
		echo "You need to be root to do this."; \
		exit 1; \
	fi

check-log:
	@grep "^=======> ERROR:"; \
	if [ "$$?" = "0" ]; then \
		echo "(see log file for details)"; \
		exit 1; \
	else \
		exit 0; \
	fi


# kernel
kernel/linux-$(KERNEL_VERSION).tar.xz:
	cd kernel && wget $(KERNEL_MIRROR)/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

kernel/linux-$(KERNEL_VERSION): kernel/linux-$(KERNEL_VERSION).tar.xz
	tar -C kernel -xJmf kernel/linux-$(KERNEL_VERSION).tar.xz
	for FILE in $(KERNEL_PATCHES); do \
		(cd kernel/linux-$(KERNEL_VERSION) && patch -p1 -i ../$$FILE;) \
	done
	sed -i -e 's,\($$(Q)echo "$$(KERNELVERSION)\)$$$$($$(CONFIG_SHELL).*" >,\1" >,' kernel/linux-$(KERNEL_VERSION)/Makefile

kernel/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage: kernel/linux-$(KERNEL_VERSION).config | kernel/linux-$(KERNEL_VERSION)
	make -C kernel/linux-$(KERNEL_VERSION) mrproper
	cp -f kernel/linux-$(KERNEL_VERSION).config kernel/linux-$(KERNEL_VERSION)/.config
	make -C kernel/linux-$(KERNEL_VERSION) oldconfig
	make -j$(shell nproc) -C kernel/linux-$(KERNEL_VERSION) all

kernel: kernel/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage

kernel-clean:
	rm -rf kernel/linux-$(KERNEL_VERSION)

kernel-distclean: kernel-clean
	rm -f kernel/linux-$(KERNEL_VERSION).tar.xz



# busybox
busybox/busybox-$(BB_VERSION).tar.bz2:
	@cd busybox && wget http://busybox.net/downloads/busybox-$(BB_VERSION).tar.bz2

busybox/busybox-$(BB_VERSION): busybox/busybox-$(BB_VERSION).tar.bz2
	@tar -C busybox -xjmf busybox/busybox-$(BB_VERSION).tar.bz2

busybox/busybox: busybox/busybox-$(BB_VERSION)
	@cp -f busybox/busybox-$(BB_VERSION).config busybox/busybox-$(BB_VERSION)/.config
	@make -C busybox/busybox-$(BB_VERSION) oldconfig
	@make -C busybox/busybox-$(BB_VERSION)
	@cp busybox/busybox-$(BB_VERSION)/busybox busybox/busybox

busybox: busybox/busybox

busybox-source: busybox/busybox-$(BB_VERSION).tar.bz2

busybox-clean:
	rm -rf busybox/busybox-$(BB_VERSION) busybox/busybox

busybox-distclean: busybox-clean
	rm -f busybox/busybox-$(BB_VERSION).tar.bz2



# grub2-efi
grub2-efi: /usr/bin/grub-mkimage
	mkdir -p iso/EFI
	/usr/bin/grub-mkimage -c iso/grub-early.cfg -o iso/EFI/bootx64.efi -O x86_64-efi -p "" iso9660 normal search search_fs_file
	/usr/bin/grub-mkimage -c iso/grub-early.cfg -o iso/EFI/bootia32.efi -O i386-efi -p "" iso9660 normal search search_fs_file

iso/efiboot.img: grub2-efi
	dd if=/dev/zero of=iso/efiboot.img count=4096
	mkdosfs -n CRUX-EFI iso/efiboot.img
	mkdir -p iso/efiboot
	mount -o loop iso/efiboot.img iso/efiboot
	mkdir -p iso/efiboot/EFI/boot
	cp iso/EFI/bootx64.efi iso/efiboot/EFI/boot/
	cp iso/EFI/bootia32.efi iso/efiboot/EFI/boot/
	umount iso/efiboot

grub2-efi-clean:
	rm -f iso/EFI/*.efi
	rm -rf iso/efiboot iso/efiboot.img



# memtest86+
iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin.gz:
	cd iso/isolinux && wget http://www.memtest.org/download/$(MEMTEST_VERSION)/memtest86+-$(MEMTEST_VERSION).bin.gz

iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin: iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin.gz
	zcat iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin.gz > iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin

memtest: iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin

memtest-clean:
	rm -f iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin

memtest-distclean: memtest-clean
	rm -f iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin.gz



# syslinux
iso/syslinux-$(SYSLINUX_VERSION).tar.xz:
	cd iso && wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$(SYSLINUX_VERSION).tar.xz

iso/syslinux-$(SYSLINUX_VERSION): iso/syslinux-$(SYSLINUX_VERSION).tar.xz
	tar -C iso -Jxf iso/syslinux-$(SYSLINUX_VERSION).tar.xz

iso/syslinux-$(SYSLINUX_VERSION)/bios/core/isolinux.bin: iso/syslinux-$(SYSLINUX_VERSION)

syslinux: iso/syslinux-$(SYSLINUX_VERSION)/bios/core/isolinux.bin

syslinux-clean:
	rm -rf iso/syslinux-$(SYSLINUX_VERSION)

syslinux-distclean: syslinux-clean
	rm -f iso/syslinux-$(SYSLINUX_VERSION).tar.xz



clean: kernel-clean busybox-clean initramfs-clean grub2-efi-clean rootfs-clean
	@rm -rf tmp modules_install.log $(ISO_FILENAME) \
		`basename $(ISO_FILENAME) .iso`.md5

distclean: clean kernel-distclean setup.dependencies-clean

$(COLLECTIONS): check-root
	@for p in $(PORTS_$(@)); do \
		if [ "$$p" != "COPYING" -a "$$p" != "COPYRIGHT" ]; then \
			echo "port: $$p"; \
			(cd $(PORTS_DIR)/$@/$$p && pkgmk -cf $(PKGMK_CONF) $(PKGMK_DOWNLOAD) $(PKGMK_FORCE)); \
		fi; \
	done

all: $(COLLECTIONS)

all-chroot: check-root
	@echo "Creating chroot environment"
	@rm -rf $(FAKE_ROOT_DIR)
	@mkdir -p $(FAKE_ROOT_DIR)
	@echo "Installing packages"
	@mkdir -p $(FAKE_ROOT_DIR)/var/lib/pkg
	@touch $(FAKE_ROOT_DIR)/var/lib/pkg/db
	@for COLL in $(COLLECTIONS); do \
		for PACKAGE in $(PORTS_DIR)/$$COLL/*/*.$(PKG_EXT); do \
			echo " $$PACKAGE"; \
			pkgadd -r $(FAKE_ROOT_DIR) $$PACKAGE; \
		done; \
	done
	@echo "Installing kernel source (linux-$(KERNEL_VERSION)) into $(FAKE_ROOT_DIR)/usr/src/linux-$(KERNEL_VERSION)..."
	@mkdir -p $(FAKE_ROOT_DIR)/usr/src
	@tar Jxf kernel/linux-$(KERNEL_VERSION).tar.xz -C $(FAKE_ROOT_DIR)/usr/src/
	@for FILE in $(KERNEL_PATCHES); do \
		cp kernel/$$FILE $(FAKE_ROOT_DIR)/usr/src/linux-$(KERNEL_VERSION)/; \
		(cd $(FAKE_ROOT_DIR)/usr/src/linux-$(KERNEL_VERSION) && \
		 patch -p1 -i $$FILE); \
	 done
	@cp kernel/linux-$(KERNEL_VERSION).config $(FAKE_ROOT_DIR)/usr/src/linux-$(KERNEL_VERSION)/.config
	@echo "Preparing kernel source..."
	@(cd $(FAKE_ROOT_DIR)/usr/src/linux-$(KERNEL_VERSION) && \
	  make oldconfig && make)
	@mkdir -p $(FAKE_ROOT_DIR)/lib/modules/$(KERNEL_VERSION)
	@ln -s /usr/src/linux-$(KERNEL_VERSION) $(FAKE_ROOT_DIR)/lib/modules/$(KERNEL_VERSION)/build
	@cp -L /etc/resolv.conf $(FAKE_ROOT_DIR)/etc/
	@cp -L $(PKGMK_CONF) $(FAKE_ROOT_DIR)/etc/
	@echo "Mounting /dev on $(FAKE_ROOT_DIR)/dev"
	@mount --bind /dev $(FAKE_ROOT_DIR)/dev
	@echo "Mounting /proc on $(FAKE_ROOT_DIR)/proc"
	@mount --bind /proc $(FAKE_ROOT_DIR)/proc
	@echo "Mounting $$PWD on $(FAKE_ROOT_DIR)/src"
	@mkdir $(FAKE_ROOT_DIR)/src
	@mount --bind $$PWD $(FAKE_ROOT_DIR)/src
	@echo "Entering chroot enrivonment"
	@chroot $(FAKE_ROOT_DIR) /bin/bash --login -c "cd /src && $(MAKE) FORCE=yes all"
	@echo "Exiting chroot enrivonment"
	@echo "Unmounting $(FAKE_ROOT_DIR)/src"
	@umount $(FAKE_ROOT_DIR)/src
	@rmdir $(FAKE_ROOT_DIR)/src
	@echo "Unmounting $(FAKE_ROOT_DIR)/proc"
	@umount $(FAKE_ROOT_DIR)/proc
	@echo "Unmounting $(FAKE_ROOT_DIR)/dev"
	@umount $(FAKE_ROOT_DIR)/dev
	@echo "Removing chroot environment"
	@rm -rf $(FAKE_ROOT_DIR)

bootstrap: check-root kernel
	$(shell $(PWD)/hacks.sh)
	@echo "Bootstrap started    (`date +'%F %T'`)"
	@echo "- Stage 0            (`date +'%F %T'`)"
	@$(MAKE) all > log.stage0 2>&1
	@$(MAKE) check-log < log.stage0
	@echo "- Stage 1            (`date +'%F %T'`)"
	@$(MAKE) all-chroot > log.stage1 2>&1
	@$(MAKE) check-log < log.stage1
	@echo "- Stage 2            (`date +'%F %T'`)"
	@$(MAKE) all-chroot > log.stage2 2>&1
	@$(MAKE) check-log < log.stage2
	@echo "Bootstrap completed  (`date +'%F %T'`)"



# initramfs
initramfs: kernel busybox initramfs/init | rootfs
	@echo "Creating initramfs..."
	@sed -e "s/#KERNEL_VERSION#/$(KERNEL_VERSION)/g" initramfs/initramfs.lst \
		> initramfs/initramfs.lst-sed
	@cd initramfs && ../kernel/linux-$(KERNEL_VERSION)/usr/gen_init_cpio \
		initramfs.lst-sed > initramfs

initramfs-clean:
	if [ -e initramfs/initramfs.lst-sed ]; then rm -f initramfs/initramfs.lst-sed; fi
	if [ -e initramfs/initramfs ]; then rm -f initramfs/initramfs; fi



# rootfs.tar.xz
rootfs: kernel busybox
	@echo "Creating rootfs..."
	@rm -rf $(ROOTFS_DIR)
	@mkdir -p $(ROOTFS_DIR)
	@echo "- Installing packages..."
	@for PACKAGE in $(ISO_PACKAGES); do \
		bsdtar -C $(ROOTFS_DIR) -xpf $(PORTS_DIR)/*/$$PACKAGE/$$PACKAGE\#*.$(PKG_EXT); \
	done
	@sed -i -e 's/^#PermitRootLogin.*/PermitRootLogin yes/' \
		$(ROOTFS_DIR)/etc/ssh/sshd_config
	@echo "- Installing kernel and modules..."
	@cp kernel/linux-$(KERNEL_VERSION)/System.map $(ROOTFS_DIR)/boot/System.map
	@cp kernel/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(ROOTFS_DIR)/boot/vmlinuz
	@make -C kernel/linux-$(KERNEL_VERSION) INSTALL_MOD_PATH=$(ROOTFS_DIR) modules_install > modules_install.log 2>&1
	@echo "- Deleting superfluous files..."
	@cd $(ROOTFS_DIR) && rm -rf var opt home
	@mkdir -p $(ROOTFS_DIR)/var/empty $(ROOTFS_DIR)/var/lib
	@cd $(ROOTFS_DIR)/usr && rm -rf man include lib/*.a lib/*.o lib/gconv lib/locale src
	@cd $(ROOTFS_DIR)/usr/share && mkdir l v x; cp terminfo/l/linux l; cp terminfo/v/vt100 v; cp terminfo/x/xterm x; rm -rf terminfo/*; mv l v x terminfo
	@cd $(ROOTFS_DIR)/usr/share && rm -rf et ss vim i18n zoneinfo
	@cd $(ROOTFS_DIR)/usr/bin && rm cal locale localedef rpcgen compile_et mk_cmds
	@cd $(ROOTFS_DIR)/usr/sbin && rm groupadd groupdel groupmod useradd userdel usermod grpck pwck iconvconfig
	@cd $(ROOTFS_DIR)/etc && rm -rf cron resolv.conf lilo.conf sysctl.conf pkgadd.conf pkgmk.conf securetty
	@cd $(ROOTFS_DIR)/etc/rc.d && find . -type f ! -name "sshd" -exec rm -f '{}' \;
	@rm $(ROOTFS_DIR)/lib/modules/$(KERNEL_VERSION)/build
	@echo "- Creating symlinks"
	@ln -sf /tmp/var $(ROOTFS_DIR)/var
	@ln -sf /proc/mounts $(ROOTFS_DIR)/etc/mtab
	@echo "- Updating library links and cache"
	@ldconfig -r $(ROOTFS_DIR)
	@echo "- Copying iso/ files..."
	@for F in motd fstab hosts inittab issue ld.so.conf protocols rc rc.shutdown rc.single services shadow; do \
		cp iso/etc/$$F $(ROOTFS_DIR)/etc; \
	 done
	@for F in setup setup-helper setup-chroot serial_console; do \
		cp iso/bin/$$F $(ROOTFS_DIR)/usr/bin; \
	 done
	@echo "- Compressing (rootfs.tar.xz)..."
	@mkdir -p rootfs
	@(cd $(ROOTFS_DIR) && tar -Jcf ../../rootfs/rootfs.tar.xz . 2>/dev/null)

rootfs-clean:
	@rm -rf rootfs


# setup.dependencies
iso/setup.dependencies: packages.opt packages.xorg
	@echo "Creating iso/setup.dependencies ..."
	@for PORT in $(foreach c,$(COLLECTIONS),$(PORTS_$(c))); do \
		if [ "$$PORT" != "COPYING" -a "$$PORT" != "COPYRIGHT" ]; then \
			echo -n $$PORT": "; \
			prt-get \
				--no-std-config \
				$(foreach c,$(COLLECTIONS),--config-append="prtdir $(PORTS_DIR)/$(c)") \
				quickdep $$PORT; \
		fi; \
	done > $@

setup.dependencies: iso/setup.dependencies packages.all check-deps

setup.dependencies-clean:
	@rm iso/setup.dependencies
	@rm packages.all

# Write a file with all packages we provide on the iso
packages.all: packages.opt packages.xorg
	@echo "Writing file packages.all ..."
	@for PORT in $(foreach c,$(COLLECTIONS),$(PORTS_$(c))); do \
		if [ "$$PORT" != "COPYING" -a "$$PORT" != "COPYRIGHT" ]; then \
			echo $$PORT; \
		fi; \
	done | sort > $@

# here we check if we have a dep, listed in a Pkgfile, which we do not provide on the iso
check-deps: packages.all iso/setup.dependencies
	@echo "Check for missing dependencies ..."
	@gawk ' \
		BEGIN { while ((getline p < "packages.all") > 0) { pkgs[p] }} \
		{ for (p=2; p<=NF; p++) { if ( ! ($$p in pkgs)) { printf(" * %s %s\n", $$1, $$p) }}} \
	' iso/setup.dependencies

# check for duplicate, missing and orphan packages in the ports tree
check-portstree: packages.all
	@cd $(PORTS_DIR) && ./checkportstree


##### image building #####
image-base: check-root kernel initramfs rootfs setup.dependencies iso/efiboot.img
	@echo "Creating installation image base"
	@if [ -e $(IMG_ROOT_DIR) ]; then rm -rf $(IMG_ROOT_DIR); fi
	@mkdir -p $(IMG_ROOT_DIR)/boot
	@echo "- Installing kernel"
	@cp kernel/linux-$(KERNEL_VERSION)/System.map $(IMG_ROOT_DIR)/boot/System.map
	@cp kernel/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(IMG_ROOT_DIR)/boot/vmlinuz
	@echo "- Installing initramfs"
	@cp initramfs/initramfs $(IMG_ROOT_DIR)/boot/initramfs
	@echo "- Copying CRUX packages"
	@mkdir -p $(IMG_ROOT_DIR)/crux
	@cp doc/handbook/handbook.txt doc/handbook/releasenotes.txt $(IMG_ROOT_DIR)/crux
	@cp iso/setup.dependencies $(IMG_ROOT_DIR)/crux
	@mkdir -p $(IMG_ROOT_DIR)/crux/kernel
	@cp kernel/linux-$(KERNEL_VERSION).tar.xz $(IMG_ROOT_DIR)/crux/kernel
	@cp kernel/linux-$(KERNEL_VERSION).config $(IMG_ROOT_DIR)/crux/kernel
	@cp kernel/linux-$(KERNEL_VERSION).defconfig $(IMG_ROOT_DIR)/crux/kernel
	@for FILE in $(KERNEL_PATCHES); do \
		cp kernel/$$FILE $(IMG_ROOT_DIR)/crux/kernel; \
	done
	@for COLL in $(COLLECTIONS); do \
		mkdir -p $(IMG_ROOT_DIR)/crux/$$COLL; \
		cp $(PORTS_DIR)/$$COLL/*/*.$(PKG_EXT) $(IMG_ROOT_DIR)/crux/$$COLL; \
	done
	@mkdir -p $(IMG_ROOT_DIR)/tools
	@echo "- Creating a gzip compressed pkgutils package in /tools"
	@cp $(IMG_ROOT_DIR)/crux/core/pkgutils*.$(PKG_EXT) $(IMG_ROOT_DIR)/tools
	@xz -d $(IMG_ROOT_DIR)/tools/pkgutils*.$(PKG_EXT)
	@gzip $(IMG_ROOT_DIR)/tools/pkgutils*.tar
	@echo "- Copying rootfs.tar.xz"
	@cp rootfs/rootfs.tar.xz $(IMG_ROOT_DIR)
	@echo $(CRUXVERSION)-$(DATE_STR) > $(IMG_ROOT_DIR)/crux-media


##### iso image building #####
iso: image-base memtest syslinux
	@echo "Copying ISO specific files"
	@mkdir -p $(IMG_ROOT_DIR)/boot/isolinux
	@cp iso/syslinux-$(SYSLINUX_VERSION)/bios/core/isolinux.bin $(IMG_ROOT_DIR)/boot/isolinux/
	@cp iso/syslinux-$(SYSLINUX_VERSION)/bios/com32/elflink/ldlinux/ldlinux.c32 $(IMG_ROOT_DIR)/boot/isolinux/
	@for F in hdt/hdt.c32 libutil/libutil.c32 gpllib/libgpl.c32 lib/libcom32.c32 cmenu/libmenu/libmenu.c32; do \
		cp iso/syslinux-$(SYSLINUX_VERSION)/bios/com32/$$F $(IMG_ROOT_DIR)/boot/isolinux/; \
	 done
	@cp /usr/share/pci.ids $(IMG_ROOT_DIR)/boot/isolinux/
	@cp iso/isolinux/isolinux.cfg iso/isolinux/*.msg \
		$(IMG_ROOT_DIR)/boot/isolinux
	@cp iso/isolinux/memtest86+-$(MEMTEST_VERSION).bin $(IMG_ROOT_DIR)/boot/isolinux/memtest86plus
	@cp iso/efiboot.img $(IMG_ROOT_DIR)/boot/
	@mkdir -p $(IMG_ROOT_DIR)/boot/grub/x86_64-efi $(IMG_ROOT_DIR)/boot/grub/i386-efi
	@cp -a /usr/lib/grub/x86_64-efi/*.mod /usr/lib/grub/x86_64-efi/*.lst $(IMG_ROOT_DIR)/boot/grub/x86_64-efi/
	@cp -a /usr/lib/grub/i386-efi/*.mod /usr/lib/grub/i386-efi/*.lst $(IMG_ROOT_DIR)/boot/grub/i386-efi/
	@cp iso/grub.cfg $(IMG_ROOT_DIR)/boot/grub/
	@echo "- Creating ISO sort table"
	@echo "$(IMG_ROOT_DIR)/boot 100" > /tmp/iso.sort
	@echo "$(IMG_ROOT_DIR)/boot/isolinux 200" >> /tmp/iso.sort
	@echo "$(IMG_ROOT_DIR)/boot/isolinux/isolinux.bin 300" >> /tmp/iso.sort
	@echo "- Starting genisoimage"
	@if [ -f $(ISO_FILENAME) ]; then rm -f $(ISO_FILENAME); fi
	@genisoimage -R -l -J -V "CRUX-$(CRUXVERSION)$(CUSTOMVERSION)" -A CRUX \
		-b boot/isolinux/isolinux.bin \
		-c boot/isolinux/isolinux.boot -no-emul-boot -boot-load-size 4 \
		-boot-info-table \
		-eltorito-alt-boot -e boot/efiboot.img -no-emul-boot \
		-sort /tmp/iso.sort -input-charset utf-8 -o "$(ISO_FILENAME)" $(IMG_ROOT_DIR)
	@isohybrid -u $(ISO_FILENAME)
	@md5sum `basename $(ISO_FILENAME)` > `basename $(ISO_FILENAME) .iso`.md5
	@rm /tmp/iso.sort
	@echo "Done: $(shell date)"


source-iso: busybox-source packages.all kernel/linux-$(KERNEL_VERSION).tar.xz
	@echo "Creating ISO image with sources ($(SRCISO_FILENAME))"
	@rm -rf $(SRCISO_ROOT_DIR)
	@mkdir -p $(SRCISO_ROOT_DIR)/ports $(SRCISO_ROOT_DIR)/kernel $(SRCISO_ROOT_DIR)/misc
	@echo "- Copying ports"
	@for PORT in $(shell /bin/cat packages.all); do \
		find $(PORTS_DIR) -mindepth 2 -maxdepth 2 -name $$PORT -type d -exec cp -r {} $(SRCISO_ROOT_DIR)/ports \; ; \
		rm -f $(SRCISO_ROOT_DIR)/ports/$$PORT/.footprint \
			$(SRCISO_ROOT_DIR)/ports/$$PORT/.md5sum \
			$(SRCISO_ROOT_DIR)/ports/$$PORT/*.$(PKG_EXT); \
	done
	@echo "- Copying misc sources"
	@cp busybox/busybox-$(BB_VERSION).tar.bz2   $(SRCISO_ROOT_DIR)/misc
	@echo "- Copying kernel and patches"
	@cp kernel/linux-$(KERNEL_VERSION).tar.xz  $(SRCISO_ROOT_DIR)/kernel
	@for PATCH in $(KERNEL_PATCHES); do cp kernel/$$PATCH $(SRCISO_ROOT_DIR)/kernel; done
	@echo "- Creating README"
	@echo "This ISO image contains sources for the packages, kernel and utilities" > $(SRCISO_ROOT_DIR)/README
	@echo "supplied with/used in CRUX $(CRUXVERSION)." >> $(SRCISO_ROOT_DIR)/README
	@echo "- Starting genisoimage"
	@genisoimage -R -l -J -V CRUX-$(CRUXVERSION) -A CRUX -o $(SRCISO_FILENAME) $(SRCISO_ROOT_DIR)
	@md5sum `basename $(SRCISO_FILENAME)` > `basename $(SRCISO_FILENAME) .iso`.md5

# End of file
