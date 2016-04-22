;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;
;
;
; These definitions allow you to communicate with
; PORTB and PORTL using the LDS and STS instructions
;
.equ DDRB=0x24
.equ PORTB=0x25
.equ DDRL=0x10A
.equ PORTL=0x10B


		;wei shen me yao ldi 0xFF gei r16
		ldi r16, 0xFF
		sts DDRB, r16		; PORTB all output	
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value, a0x33 is hex, equal to 00110011(binary), index 0,1,4,5 will be lighted on	
		mov r0, r16			; in r0 on the LEDs	

; Your code here
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
		
		



;
; Don't change anything below here
;
done:	jmp done
