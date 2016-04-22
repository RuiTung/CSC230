#define LCD_LIBONLY
.include "lcd.asm"

.cseg

main:
	call lcd_init
	call lcd_clr
	call init_strings
	call init_ptrs

lp: 
	call lcd_clr
	call cpy_msg
	call display_str1
	call inc_pointers

	ldi r17,0x20
	call delay
	
	rjmp lp

end:
	jmp end

delay:
		ldi r20,0x40
del1:
		nop
		ldi r21,0xFF
del2:
		nop
		ldi r22, 0xFF
del3:	
	nop
	dec r22
	brne del3
	dec r21
	brne del2
	dec r20
	brne del1
	ret

init_ptrs:
			push r26
			push r27
			push r17
			push r20

			ldi r26, low(str1)
			ldi r27, high(str1)


			ldi r17, low(msg1)
			ldi r20, high(msg1)
			st X+, r17
			st X, r20

			ldi r26, low(str2)
			ldi r27, high(str2)

			ldi r17, low(msg2)
			ldi r20, high(msg2)
			st X+, r17
			st X, r20

			pop r20
			pop r17
			pop r27
			pop r26
			ret

; move the pointers forward (wrap around when appropriate)
inc_pointers:
			push r18 ; tempChar
			push YL ; lineN_low
			push YH ; lineN_high
			push ZL ; lNptr_low
			push ZH ; lNptr_high
			push XL ; *lNptr_low
			push XH ; *lNptr_high
			
			; 1st line desplay
			ldi ZL, low(str1)
			ldi ZH, high(str1)
			ld XL, Z+
			ld XH, Z

			ld r18, X+
			ld r18, X

			
			cpi r18, 0x00
			brne firstLine
			
			;update str
			ldi XL, low(msg1)
			ldi XH, high(msg1)
	
firstLine:
			ldi ZL, low(str1)
			ldi ZH, high(str1)
			st Z+, XL
			st Z, XH

			; 2nd line display
			ldi ZL, low(str2)
			ldi ZH, high(str2)
			ld XL, Z+
			ld XH, Z

			ld r18, X+
			ld r18, X
			cpi r18, 0x00
			brne secondLine
			
			; update str
			ldi XL, low(msg2)
			ldi XH, high(msg2)
	
secondLine:
			ldi ZL, low(str2)
			ldi ZH, high(str2)
			st Z+, XL
			st Z, XH

			pop XH
			pop XL
			pop ZH
			pop ZL
			pop YH
			pop YL
			pop r18
			ret

; copy pointers in msg1 and msg2 to 1st line and 2nd line
cpy_msg:
		push r19 ; i
		push r18 ; tempChar
		push YL ; lineN_low
		push YH ; lineN_high
		push ZL ; lNptr_low
		push ZH ; lNptr_high
		push XL ; *lNptr_low
		push XH ; *lNptr_high

		; for 1st line
		ldi YL, low(line1)
		ldi YH, high(line1)
		ldi ZL, low(str1)
		ldi ZH, high(str1)
		ld XL, Z+
		ld XH, Z

		ldi r19, 0

forLoop1Start:
				cpi r19, 16
				brge forLoop1End
				ld r18, X+
					
				cpi r18, 0x00
				breq resetPtr1
				st Y+, r18
				
				rjmp copyCompleted1	

resetPtr1:
			ldi XL, low(msg1)
			ldi XH, high(msg1)
			rjmp forLoop1Start

copyCompleted1:
				inc r19
				rjmp forLoop1Start

forLoop1End:
			ldi r18, 0
			st Y, r18

			; for 2nd line
			ldi YL, low(line2)
			ldi YH, high(line2)
			ldi ZL, low(str2)
			ldi ZH, high(str2)
			ld XL, Z+
			ld XH, Z

			ldi r19, 0

forLoop2Start:
			cpi r19, 16
			brge forLoop2End
			ld r18, X+
			cpi r18, 0x00
			breq resetPtr2
			st Y+, r18
			rjmp copyCompleted2	

resetPtr2:
			ldi XL, low(msg2)
			ldi XH, high(msg2)
			rjmp forLoop2Start

copyCompleted2:
				inc r19
				rjmp forLoop2Start

forLoop2End:
			ldi r18, 0
			st Y, r18 ; add '\0'

			pop XH
			pop XL
			pop ZH
			pop ZL
			pop YH
			pop YL
			pop r18
			pop r19
			ret

init_strings:
			push r22

			; copyStr(prgmMem, dataMem)
			ldi r22, high(msg1) ; dest
			push r22
			ldi r22, low(msg1)
			push r22
			ldi r22, high(msg1_p << 1) ; src
			push r22
			ldi r22, low(msg1_p << 1)
			push r22
			call str_init	; cpy(prgm, data)
			pop r22		; rm(parm)
			pop r22
			pop r22
			pop r22

			ldi r22, high(msg2)
			push r22
			ldi r22, low(msg2)
			push r22
			ldi r22, high(msg2_p << 1)
			push r22
			ldi r22, low(msg2_p << 1)
			push r22
			call str_init
			pop r22
			pop r22
			pop r22
			pop r22

			pop r22
			ret

display_str1:
			push r22
			call lcd_clr

			ldi r22, 0x00
			push r22
			ldi r22, 0x00
			push r22
			call lcd_gotoxy
			pop r22
			pop r22

			; disp(msg1)
			ldi r22, high(line1)
			push r22
			ldi r22, low(line1)
			push r22
			call lcd_puts
			pop r22
			pop r22

			; mvCurs(secondLine)
			ldi r22, 0x01
			push r22
			ldi r22, 0x00
			push r22
			call lcd_gotoxy
			pop r22
			pop r22

			; disp(msg2)
			ldi r22, high(line2)
			push r22
			ldi r22, low(line2)
			push r22
			call lcd_puts
			pop r22
			pop r22
			
			pop	r22
			ret

display_str2:
			push r22
			call lcd_clr

			ldi r22, 0x01
			push r22
			ldi r22, 0x00
			push r22
			call lcd_gotoxy
			pop r22
			pop r22

			; disp(msg1)
			ldi r22, high(line1)
			push r22
			ldi r22, low(line1)
			push r22
			call lcd_puts
			pop r22
			pop r22

			; mvCurs(secondLine)
			ldi r22, 0x00
			push r22
			ldi r22, 0x00
			push r22
			call lcd_gotoxy
			pop r22
			pop r22

			; disp(msg2)
			ldi r22, high(line2)
			push r22
			ldi r22, low(line2)
			push r22
			call lcd_puts
			pop r22
			pop r22
			
			pop	r22
			ret

stop:
	pop r16
	ret

msg1_p:.db"Assignment 3 is the hardest one.",0
msg2_p:.db"It costs me one more week to do it.",0

.dseg

msg1:.byte 200
msg2:.byte 200

line1: .byte 17
line2: .byte 17

str1: .byte 2
str2: .byte 2
