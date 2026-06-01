# ASM C++ Template Project

A small Linux template for mixing C++ and NASM assembly in one project.

The example starts in `app/src/App.cpp`, calls the assembly function
`asm_hello`, and the NASM file `asm/src/Hello.asm` prints:

```text
Hello from NASM
```

## Project Layout

```text
app/src/      C++ source files
asm/src/      NASM assembly source files
app/build/    Final executable output
app/bin/      C++ object files
asm/bin/      Assembly object files
interface/    Shared headers for larger projects
class/        Optional shared-library source folder
lib/          Built shared libraries
```

## Requirements

- `make`
- `g++`
- `nasm`
- `gdb`
- VS Code with the C/C++ extension for debugging

## Build

```bash
make
```

The executable is created at:

```text
app/build/app
```

## Run

```bash
./app/build/app
```

## Debug In VS Code

This template includes VS Code launch configs:

- `Debug asm`: builds with NASM DWARF debug info and starts GDB
- `Debug app`: builds the C++ app with debug symbols

Open `asm/src/Hello.asm`, set a breakpoint, then press `F5` and choose
`Debug asm`.

The workspace setting `debug.allowBreakpointsEverywhere` is enabled so VS Code
can place breakpoints inside `.asm` files.

## Clean

```bash
make clean
```

## License

MIT License, copyright (c) 2026 Orion.
# AI
