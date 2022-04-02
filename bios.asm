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


bios_start:
stp



gpu_print_ASCII: 
; Parameters:
;   carriage location       <= top of the stack
;   first character address
;   color
pop r1
pop r2
pop r5
and r5 $00FF
ldw r3 [r0,'$20000004']
gpu_print_ASCII_loop:
ldbu r4 [r2+,0]

cmp r4 10
bne [r0,'gpu_print_ASCII_noCR']  ; r4 != 10 (LF - Enter)

gpu_print_ASCII_CR:
sub r1 r3
div r1 160
inc r1
mltl r1 160
add r1 r3
jmp [r0,'gpu_print_ASCII_loop']

gpu_print_ASCII_noCR:
cmp r4 3
beq [r0,'return_after_function'] ; r4 == 3 (ETX - end)
lsl r4 8
or r4 r5
sth r4 [r1+,0]
jmp [r0,'gpu_print_ASCII_loop']
; end of gpu_print_ASCII

gpu_fill_page:
; Parameters:
;   data to fill the page with       <= top of the stack
ldw r1 [r0,'$20000004']
ldbu r2 [r0,'$20000000']
mltl r2 4
ldw r2 [r2,'gpu_page_sizes']
pop r3
gpu_fill_page_loop:
stw r3 [r1+,0]
cmp r1 r2
blsu [r0,'gpu_fill_page']
jmp [r0,'return_after_function']




















gpu_page_sizes:
.words 4000 2000 8000 16000 8000 32000 64000 32000 128000 0 128000

