# BootPong

A rudimentary version of Pong made in x86 16-bit Real Mode Assembly that can be booted into. Just about fits in a 512-byte disk MBR with a 446 byte code limit

## About
This was a quick side project to learn x86 assembly. It uses BIOS calls for Graphics with a custom ISR for keyboard input. I still consider myself a newbie so the code isn't super optimal in size or performance. I've added comments to the code so it should be easy to go through.

A few resources I recommend for anyone wanting to do Real Mode x86 Assembly are:

1. [Guide to x86 Assembly](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html), which introduces x86 Assembly
2. [OSDev Wiki](https://wiki.osdev.org/Main_Page), meant for OS development, but has useful information about the boot process. Some pages that were useful for this project were:

    1. [MBR](https://wiki.osdev.org/MBR_(x86)), describing the MBR's structure and how it's loaded
    2. [x86 Memory Map](https://wiki.osdev.org/Memory_Map_(x86)), showing which regions of RAM are usable
    3. [Real Mode](https://wiki.osdev.org/Real_Mode), describing the 16-bit mode of all x86 processors and how to address memory
    4. [Interrupt Vector Table](https://wiki.osdev.org/Interrupt_Vector_Table), showing how interrupts are handled in Real Mode

3. [Felix Cloutier's x86 instructions list](https://www.felixcloutier.com/x86/) which provides a relatively easier to use instruction list derived from [Intel's Software Development manual](https://software.intel.com/sites/default/files/managed/39/c5/325462-sdm-vol-1-2abcd-3abcd.pdf)
4. [Stanislav's BIOS Interrupt Table](https://stanislavs.org/helppc/int_table.html) which contained a helpful list of usable BIOS functions
5. [TetrOS](https://github.com/daniel-e/tetros) and [BootChess](https://gist.github.com/jwieder/7e7e643cc71c81f63958), examples for Tetris and Chess (respectively) that fit on a 512 byte MBR.
6. Search engines, there are many other resources that are available at a search's distance

## Bugs and Missing Functionality
1. The clear-draw loop isn't run at VSync, and the boxes are drawn 1 pixel at a time, which leads to very flickery graphics. In a perfect world I would call this a feature for the added difficulty it provides

2. There is no scoring system available

## Building and running
Make sure you have a copy of the NASM assembler installed. Then run `make`. This will assemble a file called `bootpong`.

## Running on QEMU
If you have `qemu-system-x86_64` available, run `make run`. See the Makefile for the commands used

## Running on real hardware
**DISCLAIMER:** This has not been tested extensively on real hardware. Further, writing an MBR to a disk can overwrite information about the partitions of the disk. Ensure you have a backup of the disk's MBR or use a device that doesn't contain critical data. I am not responsible for any damage caused. Proceed only if you know what you're doing.

You can use `dd` to read/write the MBR. This assumes you have a Linux install available. Find the `/dev/device_file` path for your drive and proceed as follows:

1. Back up the existing MBR to a file:
```bash
sudo dd if=/dev/device_file of=<some place safe>/mbr.bin bs=512 count=1
```
2. Write `bootpong` to your disk. Double check the device being written to:
```bash
sudo dd if=bootpong of=/dev/device_file bs=512 count=1
```
3. Boot into the disk

To restore the previous MBR, use this command:
```bash
sudo dd if=<some place safe>/mbr.bin of=/dev/device_file bs=512 count=1
```

## Playing
W/S controls Paddle 1, Up/Down arrow keys control Paddle 2