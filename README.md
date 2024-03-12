# How to reproduce the potential bug

- modify source code, and replace "path-to/file.lzfse" with real path on your disk. The file is part of the repository.
- run the project in Xcode - it is command line tool, so no bundled resources are possible
- check the load of your system - system is stuck
- pause the program run - most threads will be waiting in mach_msg2_trap
