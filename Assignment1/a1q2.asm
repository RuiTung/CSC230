;
; CSc 230 Assignment 1 
; Question 2
; Author: Jason Corless
 ; Modified: Sudhakar Ganti
 
; This program should calculate:
; R0 = R16 + R17
; if the sum of R16 and R17 is > 255 (ie. there was a carry)
; then R1 = 1, otherwise R1 = 0
;

;--*1 Do not change anything between here and the line starting with *--
.cseg
	ldi	r16, 0xF0
	ldi r17, 0x31
;*--1 Do not change anything above this line to the --*

;***
;---------------------------
;Question: What are we trying to do in this program? What is the
;meaning of if sum > 255 then set R1=1?
;Why did we say that if sum > 255 then there was a carry?
;Answer: Because for hex, the maximum value is 0xFF which is 255
;---------------------------
; Your code goes here:
;
	clr r0
	add r0, r16
	add r0, r17
	adc r2, r16
	adc r2, r17
	cp r0, r2
	breq equal
	clr r1
	lds r1, 0
	rjmp done

equal: clr r1
	   lds r1, 1
		
;****
;--*2 Do not change anything between here and the line starting with *--
done:	jmp done
;*--2 Do not change anything above this line to the --*


