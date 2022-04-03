gpu_print_ASCII: 
; Parameters:
;   carriage location       <= top of the stack
;   first character address
;   color
pop r1
pop r2
pop r5
and r5 $00FF
ldw r3 [r0,$20000004]
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
ldw r1 [r0,$20000004]
ldbu r2 [r0,$20000000]
mltl r2 4
ldw r2 [r2,'gpu_page_sizes']
pop r3
gpu_fill_page_loop:
stw r3 [r1+,0]
cmp r1 r2
blsu [r0,'gpu_fill_page']
jmp [r0,'return_after_function']
; gpu_fill_page end

gpu_text_mode_draw_window:
; Parameters
;   x1                              <= top of the stack
;   y1
;   x2
;   y2
;   colors
pop r1
pop r2
pop r3
pop r4
pop r5
gpu_text_mode_draw_window_draw_border:
mov r6 r1
and r5 $00FF
mov r7 $c9
lsl r7 8
or r7 r5
sth r7 [r6+,0]



#align 4
gpu_page_sizes:
.words 4000 2000 8000 16000 8000 32000 64000 32000 128000 0 128000