target remote localhost:3333

file build/LED_Blink.elf

monitor reset init

monitor halt

set remote hardware-breakpoint-limit 6
set remote hardware-watchpoint-limit 4
