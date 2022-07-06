*************************
*	BUILDING	*
*************************
LED_Blink and its makefile use the arm-none-eabi-gcc 
toolchain.

In the root directory run "make target_build".

The makefile will create a directory entitled "build" 
which holds the .elf/.hex/.bin binaries,object files, 
map file, and dependency information.

Configuration scripts are provided to use OpenOCD and GDB to program/debug the board over ST-Link/V2
