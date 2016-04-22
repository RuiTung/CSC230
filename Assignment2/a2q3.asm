;
; a2q3.asm
;
; Write a main program that increments a counter when the buttons are pressed
;
; Use the subroutine you wrote in a2q2.asm to solve this problem.
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

.def counter = r26
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		sts DDRB,r16
		sts DDRL,r16

; Your code here
; make sure your code is an infinite loop

;counter = 0
;start:
		;if button pressed
			;counter = counter + 1
			;delay between 100 and 300 milliseconds
		;display counter in binary on the LEDs
		;goto start
		clr r0
start:	call check_button
		cpi r24, 1
		brne start

		inc counter
		mov r0, counter
		call display
		ldi r20, 0x1A
		call delay
		rjmp start





done:		jmp done		; if you get here, you're doing it wrong

;
; the function tests to see if the button
; UP or SELECT has been pressed
;
; on return, r24 is set to be: 0 if not pressed, 1 if pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; This function could be made much better.  Notice that the a2d
; returns a 2 byte value (actually 12 bits).
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
; This function 'cheats' because I observed
; that ADCH is 0 when the right or up button is
; pressed, and non-zero otherwise.
; 
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		clr r24
		cpi r17, 0
		brne select1
		cpi r16, 0xC3
		brne skip		
		ldi r24,1
		rjmp skip

select1:	cpi r17, 2
			brne select2
			cpi r16, 0x28
			brsh on

select2:	cpi r17, 3
			brne skip
			cpi r16, 0x16
			brlo on
			rjmp skip
on:			ldi r24, 1
skip:	ret

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
; copy your display subroutine from a2q2.asm here
 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;	r17 - value to write to PORTL
;	r18 - value to write to PORTB
;
;   r16 - scratch
display:

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


