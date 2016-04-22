;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.
;
;
; These definitions allow you to communicate with
; PORTB and PORTL using the LDS and STS instructions
;
.equ DDRB=0x24
.equ PORTB=0x25
.equ DDRL=0x10A
.equ PORTL=0x10B


; Your code here
; Be sure that your code is an infite loop


;counter = 0
;start:
	;display counter in binary on the LEDs
	;counter = counter + 1
	;delay between 100 and 300 milliseconds
	;goto start

		clr r0
		clr r16
		ldi r16, 0xFF
		sts DDRB, r16			
		sts DDRL, r16
		ldi r16, 0b00000000
				
start:	
		
		;mov r0, r22
		call display
		inc r0
		ldi r20, 0x10
		call delay
		;mov r0, r16
		rjmp start

done:		jmp done	;if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
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
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;
delay:	
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
