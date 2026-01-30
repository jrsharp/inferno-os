# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Inferno OS is a distributed operating system from Bell Labs. Applications are written in Limbo (a concurrent programming language) and compile to Dis bytecode for portability. All resources are accessed through a file-like hierarchy using the 9P protocol.

Inferno can run **native** (ARM, PowerPC, SPARC, x86) or **hosted** under existing OSes (Linux, macOS, FreeBSD, Plan 9, Solaris, Windows, etc.).

## Build System

Inferno uses `mk` (Plan 9's make replacement) instead of Make. The build system is configured via `mkconfig` and template mkfiles in `mkfiles/`.

### Initial Setup (One-time)

```bash
# 1. Edit mkconfig - set ROOT (absolute path), SYSHOST, OBJTYPE
vi mkconfig

# 2. Bootstrap the mk command
./makemk.sh

# 3. Add bin directory to PATH
export PATH=$ROOT/$SYSHOST/$OBJTYPE/bin:$PATH
```

### Common Build Commands

```bash
mk nuke          # Clean everything (do this before first build)
mk install       # Full build and install (libraries, limbo compiler, emu)
mk emu           # Build just the emulator
mk emuinstall    # Install emulator only
mk kernel        # Build native kernel
mk kernelinstall # Install native kernel
mk clean         # Remove build artifacts
```

### Build Configuration (`mkconfig`)

Key variables:
- `ROOT` - Absolute path to repo root (required)
- `SYSHOST` - Build platform: MacOSX, Linux, FreeBSD, Plan9, Nt, Solaris, Irix, AIX
- `SYSTARG` - Target platform (usually same as SYSHOST, differs for cross-compile)
- `OBJTYPE` - Target architecture: 386, arm, mips, power, sparc, amd64, thumb
- `TKSTYLE` - Tk variant (use `std`)

### Convenience Targets

```bash
mk Linux-install      # Build for Linux/386
mk Solaris-install    # Build for Solaris/SPARC
mk Nt-install         # Build for Windows
mk Plan9-install      # Build for Plan 9
```

## Architecture

### Build Order (Dependencies)

Libraries and tools build in this order (defined in root mkfile):
1. `lib9` - Base Plan 9 compatibility library
2. `libbio` - Buffered I/O
3. `libmp`, `libsec` - Multiprecision math, cryptography
4. `libmath`, `utils/iyacc` - Math functions, yacc parser generator
5. `limbo` - Limbo compiler (needed to compile Limbo sources)
6. `libinterp`, `libkeyring`, `libdraw` - Interpreter, auth, graphics
7. `libprefab`, `libtk`, `libfreetype` - UI widgets, Tk toolkit, fonts
8. `libmemdraw`, `libmemlayer`, `libdynld` - Memory graphics, dynamic loading
9. `utils/data2c`, `utils/ndate` - Build utilities
10. `emu` - Hosted emulator (virtual machine)

### Key Directories

- `limbo/` - Limbo compiler (C, uses yacc)
- `emu/` - Hosted emulator with platform-specific subdirs (MacOSX/, Linux/, etc.)
- `emu/port/` - Platform-independent emulator code
- `os/` - Native kernel source
- `os/port/` - Platform-independent kernel code
- `appl/` - Limbo applications source (`.b` files)
- `dis/` - Compiled Dis bytecode (`.dis` files)
- `module/` - Limbo module interfaces (`.m` files)
- `include/` - C headers
- `utils/` - Build tools and compiler suite (5c/5l for ARM, 8c/8l for x86, etc.)
- `mkfiles/` - Build system templates

### Platform Abstraction

- Core code lives in `port/` directories
- Platform-specific implementations in `$PLATFORM/` directories
- Threading varies by OS - see `emu/*/os.c` for kproc implementations

### Compiler Suite

Architecture-specific compilers follow Plan 9 naming:
- ARM: `5c` (compiler), `5l` (linker), `5a` (assembler)
- x86/386: `8c`, `8l`, `8a`
- MIPS: `7c`, `7l`, `7a`
- PowerPC: `4c`, `4l`, `4a`
- SPARC: `3c`, `3l`, `3a`
- amd64: `6c`, `6l`, `6a`

## Working with Limbo

Limbo source files (`.b`) compile to Dis bytecode (`.dis`):

```bash
limbo -o program.dis program.b
```

Module interfaces are defined in `.m` files in `module/`.

## mkfile Patterns

Library mkfiles include template rules:
```
<../mkconfig
LIB=libname.a
# ... source files ...
<$ROOT/mkfiles/mksyslib-$SHELLTYPE
```

Executable mkfiles:
```
<../mkconfig
TARG=toolname
# ... sources and libs ...
<$ROOT/mkfiles/mkone-$SHELLTYPE
```
