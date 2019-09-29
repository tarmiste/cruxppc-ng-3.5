
Boot options:

  (Note: separate with spaces when specifying multiple options)

  acpi=off              This option disables ACPI; it's required to use APM
                        (older non-acpi hardware) and also disables
                        hyperthreading. Try this if your hardware is older and
                        has trouble booting the default way.

  console=<options>     This option configures serial port access for the boot
                        CD. The format is "device,connection options", the
                        default is "ttyS0,38400". Connection options are
                        comma-separated. For example: console=9600,8,n,1

  devicetimeout=<n>     This option forces the boot script to wait for <n>
                        seconds after module loading for usb/scsi devices to
                        settle. Use this if you think the default 10 seconds
                        is too short.

  maxcpus=<n>           This option limits the number of CPUs the kernel
                        will use to <n>. Try booting with maxcpus=0 if booting
                        with SMP enabled (the default) causes problems.

