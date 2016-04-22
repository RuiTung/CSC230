;
; a2q4.asm
;
; Fix the button subroutine program so that it returns
; a different value for each button
;

;
; Definitions for PORTA and PORTL when using
; STS and LDS instructions (ie. memory mapped I/O)
;
.equ DDRB=0x24
.equ PORTB=0x25
.equ DDRL=0x10A
.equ PORTL=0x10B

;
; Definitions for using the Analog to Digital Conversion
.equ ADCSRA=0x7A
.equ ADMUX=0x7C
.equ ADCL=0x78
.equ ADCH=0x79


		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		sts DDRB,r16
		sts DDRL,r16


		clr r0
		call display
lp:
		call check_button
		tst r24
		breq lp
		mov	r0, r24

		call display
		ldi r20, 99
		call delay
		ldi r20, 0
		mov r0, r20
		call display
		rjmp lp

;
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
; 
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:		lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		; put your new logic here:
		clr r24
		cpi r17,0
		brne press1
		cpi r16, 0x32
		brlo right 
		cpi r16, 0xC3
		brlo up
		cpi r16, 0xC3
		brsh down
		rjmp skip 

press1: cpi r17, 1
		brne press2
		cpi r16, 0x7C
		brlo down
		cpi r16, 0x7C
		brsh left
		rjmp skip

press2: cpi r17,2
		brne press3
		cpi r16, 0x2B
		brlo left
		cpi r16, 0x2B
		brsh select
		rjmp skip
press3: cpi r17, 3
		brne skip
		cpi r16, 0x16
		brlo select
		cpi r16, 0xE8
		brhs off
		rjmp skip

right:	ldi r24, 0x01
		rjmp skip

up:		ldi r24, 0x02
		rjmp skip

down: 	ldi r24, 0x04
		rjmp skip

left:	ldi r24, 0x08
		rjmp skip

select:	ldi r24, 0x10
		rjmp skip

off:	ldi r24, 0x00
		rjmp skip

skip:  	ret

;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; this function uses registers:
;
;	r20
;	r21
;	r22
;
delay:	
del1:		nop
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		; copy your code from a2q2.asm here
		light0: clr r17
		clr r18
		mov r16, r0			;save value in r0 to r16, because r16's value will be used at the following steps			
		andi r16, 0b00100000;according to assignment's requirement, the 5th light is on. So put 0b00100000 and r16. It can use 'and', because the original
		breq light1			;check if it is equal 0, true-jump to light2, false-continue to the next line of ori r17, b00000010
		ori r18, 0b00000010	;according to assignment's requirement, and 00110011, find relative index, then change it to 1 to make it light on

light1: mov r16, r0
		andi r16, 0b00010000
		breq light2 		
		ori r18, 0b00001000

light2: mov r16, r0
		andi r16, 0b00001000
		breq light3
		ori r17, 0b00000010
		
light3: mov r16, r0
		andi r16, 0b00000100
		breq light4
		ori r17, 0b00001000

light4: mov r16, r0
		andi r16, 0b00000010
		breq light5
		ori r17, 0b00100000

light5: mov r16, r0
		andi r16, 0b00000001
		breq light_on
		ori r17, 0b10000000

light_on:
		sts PORTL, r17			
		sts PORTB, r18

		ret

