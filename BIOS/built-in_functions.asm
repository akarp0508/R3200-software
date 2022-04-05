

.const TEXT_MODE_WIDTH 80
.const TEXT_MODE_HEIGHT 25
.const FIRST_ADDRESS_OF_PAGE_REGISTER $20000004

gpu_print_ASCII: 
; Parameters:
;   carriage location       <= top of the stack
;   first character address
;   colors
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
cmp r4 0
beq [r0,'gpu_print_ASCII_loop']
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
pop r1 ;x1
pop r2 ;y1
pop r3 ;x2
pop r4 ;y2
pop r5 ;color
; setting carriage in r2
mltl r2 TEXT_MODE_WIDTH
add r2 r1 ; r2 - carriage
ldw r7 [r0,FIRST_ADDRESS_OF_PAGE_REGISTER]
add r2,r7
; setting up characters in r5, r6, r7 for first row
and r5 $00FF

mov r7 $bb
lsl r7 8
or r7 r5

mov r6 $cd
lsl r6 8
or r6 r5

psh r6

mov r6 $c9
lsl r6 8
or r5 r6

pop r6

gpu_text_mode_draw_window_draw_line_loop:

; checking if it is the first character of the line
mov r0 r2 ; r0 - x coordinate of carriage
modu r0 TEXT_MODE_WIDTH
cmp r0 r1
mov r0 0
beq [r0,'gpu_text_mode_draw_window_draw_line_loop_first_character']

; checking if it is the last character of the line
mov r0 r2 ; r0 - x coordinate of carriage
modu r0 TEXT_MODE_WIDTH
cmp r0 r3
mov r0 0
beq [r0,'gpu_text_mode_draw_window_draw_line_loop_first_character']

; drawing the middle character
gpu_text_mode_draw_window_draw_line_loop_middle_character:
sth r6 [r2+,0]
jmp [r0,'gpu_text_mode_draw_window_draw_line_loop']

gpu_text_mode_draw_window_draw_line_loop_first_character:
sth r5 [r2+,0]
jmp [r0,'gpu_text_mode_draw_window_draw_line_loop']

gpu_text_mode_draw_window_draw_line_loop_last_character:

sth r7 [r2,0]
; line ended
; setting carriage
ldw r7 [r0,FIRST_ADDRESS_OF_PAGE_REGISTER]
sub r2 r7
div r2 TEXT_MODE_WIDTH
inc r2
; changing characters for the line
cmp r2 r4
bls [r0,'gpu_text_mode_draw_window_setup_characters_for_middle_lines']
beq [r0,'gpu_text_mode_draw_window_setup_characters_for_last_line']
jmp [r0,'return_after_function']
gpu_text_mode_draw_window_draw_line_end:
mltl r2 TEXT_MODE_WIDTH
add r2 r1
psh r7
ldw r7 [r0,FIRST_ADDRESS_OF_PAGE_REGISTER]
add r2 r7
pop r7
jmp [r0,'gpu_text_mode_draw_window_draw_line_loop']

gpu_text_mode_draw_window_setup_characters_for_middle_lines:
and r5 $00FF

mov r7 $ba
lsl r7 8
or r7 r5

mov r6 $20
lsl r6 8
or r6 r5

psh r6

mov r6 $ba
lsl r6 8
or r5 r6

pop r6
jmp [r0,'gpu_text_mode_draw_window_draw_line_end']

gpu_text_mode_draw_window_setup_characters_for_last_line:
and r5 $00FF

mov r7 $ba
lsl r7 8
or r7 r5

mov r6 $20
lsl r6 8
or r6 r5

psh r6

mov r6 $ba
lsl r6 8
or r5 r6

pop r6
jmp [r0,'gpu_text_mode_draw_window_draw_line_end']
; end of gpu_text_mode_draw_window

#align 4
gpu_page_sizes:
.words 4000 2000 8000 16000 8000 32000 64000 32000 128000 0 128000