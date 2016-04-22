#define F_CPU 16000000UL

#include <util/delay.h>

#include <stdbool.h>
#include <avr/interrupt.h>

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "main.h"
#include "lcd_drv.h"

int hour = 0;
int minute = 0;
int second = 0;
char msg[8];
int boolean = 1;

int main( void ){

	lcd_init();
	
	ADCSRA = 0x87;
	ADMUX = 0x40;

	sprintf(msg,"%02d:%02d:%02d",hour,minute,second);

	lcd_xy( 0, 0 );

	lcd_puts(msg);


	lcd_xy( 0, 1 );
	
 	lcd_puts(msg);



	TIMSK0 |=(1<<TOIE0);
	TIMSK1 |=(1<<TOIE1);
	
	// set timer0 counter initial value to 0
	TCNT0=0xC2F6;
  
  // set timer1 counter initial value to 0
	TCNT1=0xC2F6;

	// start timer0 with /1024 prescaler. Timer clock = system clock/1024
	TCCR0B = (1<<CS02) | (1<<CS00);

	// lets turn on 16 bit timer1 also with /1024
	TCCR1B = (1 << CS10) | (1 << CS12);
	
	// enable interrupts
	sei(); 

	while(true) {
	}
}

ISR(TIMER1_OVF_vect){
	TCNT1=0xC2F6;

	second += 1;
	if(second > 59){
		minute += 1;
		second = 0;
	}
	if(minute > 59){
		hour += 1;
		minute = 0;
	}
	sprintf(msg,"%02d:%02d:%02d",hour,minute,second);
	
	

	lcd_xy( 0, 0 );

	lcd_puts(msg);

}

// timer0 overflow
ISR(TIMER0_OVF_vect){
	TCNT0=0xE38D; 
 	
	ADCSRA |= 0x40;

	// bit 6 in ADCSRA is 1 while conversion is in progress
	// 0b0100 0000
	// 0x40
	while (ADCSRA & 0x40)
	;
		unsigned int valLow = ADCL;
		unsigned int valHigh = ADCH;

		valLow += (valHigh << 8);
	
		if (valLow < 0x3E8 ){
			boolean = -boolean;
		}
	
	if( boolean > 0){
		lcd_xy( 0, 1 );

		lcd_puts(msg);
	}
	
}
