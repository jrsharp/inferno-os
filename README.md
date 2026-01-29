Inferno® is a distributed operating system, originally developed at Bell Labs, but now developed and maintained by Vita Nuova® as Free Software.  Applications written in Inferno's concurrent programming language, Limbo, are compiled to its portable virtual machine code (Dis), to run anywhere on a network in the portable environment that Inferno provides.  Unusually, that environment looks and acts like a complete operating system.

Inferno represents services and resources in a file-like name hierarchy.  Programs access them using only the file operations open, read/write, and close.  `Files' are not just stored data, but represent devices, network and protocol interfaces, dynamic data sources, and services.  The approach unifies and provides basic naming, structuring, and access control mechanisms for all system resources.  A single file-service protocol (the same as Plan 9's 9P) makes all those resources available for import or export throughout the network in a uniform way, independent of location. An application simply attaches the resources it needs to its own per-process name hierarchy ('name space').

Inferno can run 'native' on various ARM, PowerPC, SPARC and x86 platforms but also 'hosted', under an existing operating system (including AIX, FreeBSD, IRIX, Linux, MacOS X, Plan 9, and Solaris), again on various processor types.

This repository includes source code for the basic applications, Inferno itself (hosted and native), all supporting software, including the native compiler suite, essential executables and supporting files.

## Building on Modern macOS

Inferno builds on macOS 10.15+ on both Intel (amd64) and Apple Silicon (arm64) Macs.

### Quick Start

1. Edit `mkconfig` to set your environment:
   ```
   ROOT=/path/to/inferno-os
   SYSHOST=MacOSX
   OBJTYPE=amd64    # or arm64 for Apple Silicon native
   ```

2. Build the host tools and libraries:
   ```
   ./makemk.sh
   mk nuke
   mk install
   ```

### Cross-Compiling Native Kernels

To build native Inferno kernels (e.g., for x86 embedded systems) on macOS, you need the Plan 9 cross-compiler toolchain. On Apple Silicon Macs, use Rosetta 2 to run the x86_64 host tools:

1. Set `OBJTYPE=amd64` in mkconfig (Rosetta 2 will run x86_64 binaries)
2. Build the host tools as above
3. The cross-compilers (8c, 8l for i386, 5c, 5l for ARM, etc.) will be available in `$ROOT/MacOSX/amd64/bin/`

Example building an i386 kernel:
```
cd os/pc
mk 'CONF=pc'
```

### Notes

- The `amd64` build works via Rosetta 2 on Apple Silicon Macs
- Native `arm64` builds are for the hosted emulator only (no arm64 native Inferno kernel exists yet)
- See `INSTALL` for detailed build instructions
