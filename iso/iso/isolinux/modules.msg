
Module options:

  (Note: separate with spaces when specifying multiple options)

  noscsi, noata,  These options disable loading of the the corresponding
  nofirewire,     kernel modules. For example, "CRUX noata" will skip the
  nousb, nofs,    ATA modules when loading modules to find the cdrom. Any
  nocdrom         combination of these options can be specified but keep
                  in mind that specifying them all or just the ones that
                  exclude your hardware won't yield useful results!

