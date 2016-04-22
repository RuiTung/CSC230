#define LCD_LIBONLY
.cseg

	call lcd_init			; call lcd_init to Initialize the LCD
	call init_strings

	ldi r17, 0
for:
	cpi r17, 3
	brge end_for
	call display_strings
	inc r17
		
	rjmp for

end_for:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg3_p << 1) ; this is the source
	push r16
	ldi r16, low(msg3_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg3_p << 1)
	push r16
	ldi r16, low(msg3_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16

	push r16

	call lcd_clr
	
	;first 
	;pointer for the 1 line
	ldi r16, 0x00
	push r16
	ldi r16, 0x07
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; display msg1 on the 1 line
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; pointer for the 2 line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x07
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg2 on the second line
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	call delay
	call lcd_clr
	call delay

	jmp end_for

init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be output on the lcd
	; The first parameter pushed on the stack is the Y position
	; The second parameter pushed on the stack is the X position
	; This call moves the cursor to the top left (ie. 0,0)

	push r16

	call lcd_clr
	
	;first 
	;pointer for the 1 line
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; display msg1 on the 1 line
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; pointer for the 2 line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg2 on the second line
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	call delay
	call lcd_clr
	
	;second
	;pointer for the 1 line
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	
	; display msg1 on line 1
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	call delay
	call lcd_clr
	
	;second
	;pointer for the 1 ine
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	
	;display msg2 on line 1
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	call delay
	call lcd_clr
	
	;third
	;display msg1 on line2
	ldi r16, 0x01
	push r16
	ldi r16, 0x01
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	call delay
	call lcd_clr

	ldi r16, 0x01
	push r16
	ldi r16, 0x01
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	call delay
	call lcd_clr

	pop r16
	ret

;[(3*255+4) * 255 + 4] * 64 then divide 16,000,000
;{[(nop + dec + brne) * 255(0XFF) + 4(if not satisfy bone del3, there will be 4 more step)]
; * 255(0XFF) + 4(same reason) ]} * 64(0X40), then divide 16,000,000
delay:
		ldi r20, 0x40
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1
		ret

msg1_p: .db "RUI MA", 0
msg2_p: .db "CSC 230: Spring 2016", 0

msg3_p:	.db "**", 0


.include "lcd.asm"
.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200
