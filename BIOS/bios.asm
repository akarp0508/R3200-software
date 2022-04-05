.const f_gpu_print_ASCII 0

#org $F0000000
jmp [r0,'bios_start']

#addr $F000000F
bios_function_manager:

; write all registers to BIOS RAM (Addresses $40-$60)
psh r0
mov r0 $44
stw r1 [r0+,$0]
stw r2 [r0+,$0]
stw r3 [r0+,$0]
stw r4 [r0+,$0]
stw r5 [r0+,$0]
stw r6 [r0+,$0]
stw r7 [r0+,$0]
pop r0
mov r1 0
stw r0 [r1,$40]

; write return address to BIOS RAM (Address $60)
mov r0 0
pop r1
stw r1 [r0,$60]

; call function
pop r1
mltl r1 6
jmp [r1,'built_in_functions']

return_after_function:
mov r0 0
ldw r1 [r0,$60]
psh r1
mov r0 $5c
ldw r7 [r0-,0]
ldw r6 [r0-,0]
ldw r5 [r0-,0]
ldw r4 [r0-,0]
ldw r3 [r0-,0]
ldw r2 [r0-,0]
ldw r1 [r0-,0]
ldw r0 [r0-,0]
ret

built_in_functions:
jmp [r0,'gpu_print_ASCII']
; Parameters:
;   carriage location       <= top of the stack
;   first character address
;   colors
jmp [r0,'gpu_fill_page']
; Parameters:
;   data to fill the page with       <= top of the stack
jmp [r0,'gpu_text_mode_draw_window']
; Parameters:
;   x1                              <= top of the stack
;   y1
;   x2
;   y2
;   colors

#include "built-in_functions.asm"

bios_start:
;set up palette
mov r1 $20000020
mov r2 'cga_text_palette'
palette_loop:
cpw r1+ r2+
cmp r1 $20000040
bne [r0,'palette_loop'] ; load color palette
;call draw window function
mov r1 1
mov r2 1
mov r3 10
mov r4 10
mov r5 $10


bios_start_gpu_init:
mov r1 $0FFF0000
stw r1 [r0,$20000020] ; set color palette
mov r3 $10000
stw r3 [r0,$20000004] ; set page address & page pointer (r3)
mov r1 1
stb r1 [r0,$20000001] ; enable rendering

#align 4
cga_text_palette:
.hwords $0000 $000A $00A0 $00AA $0A00 $0A0A $0A50 $0AAA
.hwords $0555 $055F $05F5 $05FF $0F55 $0F5F $0FF5 $0FFF