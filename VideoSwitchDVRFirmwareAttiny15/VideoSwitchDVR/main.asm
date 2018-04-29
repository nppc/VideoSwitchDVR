;
; VideoSwitchDVR.asm
;
; Created: 4/29/2018 7:52:49 PM
; Author : Pavel
;
.include "tn15def.inc"

.equ	PIN_DVR_POWER		= PB1
.equ	PIN_DVR_K1			= PB0
.equ	PIN_DVR_K3			= PB2
.equ	PIN_EV100_SIG		= PB4
.equ	PIN_SWITCH_VIDEO	= PB3

.def	z0			= r0
.def	z1			= r1
.def	r_sreg		= r2	; Store SREG register in interrupts

.def	tmp			= r16

.CSEG
.ORG 0
rjmp RESET ; Reset handler
reti	;rjmp EXT_INT0 ; IRQ0 handler
reti	;rjmp PIN_CHANGE ; Pin change handler
reti	;rjmp TIM1_CMP ; Timer1 compare match
reti	;rjmp TIM1_OVF ; Timer1 overflow handler
reti	;rjmp TIM0_OVF ; Timer0 overflow handler
reti	;rjmp EE_RDY ; EEPROM Ready handler
reti	;rjmp ANA_COMP ; Analog Comparator handler
reti	;rjmp ADC ; ADC Conversion Handler

RESET:
	cli
	ldi tmp, 133	; specific for every chip. Chip comes with this value pre-programmed in last eeprom address and last flash address.
	out OSCCAL, tmp
	clr z0
	clr z1
	inc z1

	; ***** SETUP *****
	; initialize io pins
	sbi PORTB, PIN_DVR_POWER ; DVR POWER OFF
	sbi	DDRB, PIN_DVR_POWER
	; PIN_SWITCH_VIDEO has a double function.
	; We are listening for power loss and switching video in/out.
	; We need to listen only while recording. So, AVin should be connected when PIN_SWITCH_VIDEO is high (default).
	; PIN_SWITCH_VIDEO is pulled up by Goggle power.
	cbi PORTB, PIN_SWITCH_VIDEO	; Video Switch default video from EV100 to DVR (recording)
	;cbi DDRB, PIN_SWITCH_VIDEO ; Listening for power loss...
	sbi DDRB, PIN_SWITCH_VIDEO ; Listening for power loss...

	; ***** LOOP *****
loop:
	;sbi DDRB, PIN_SWITCH_VIDEO
	sbi PORTB, PIN_SWITCH_VIDEO
	rcall delay5s
	;  Floating (Pulled up by external resistor)
	;cbi DDRB, PIN_SWITCH_VIDEO
	cbi PORTB, PIN_SWITCH_VIDEO
	rcall delay5s

    rjmp loop


delay5s:	; 5s at 1.6 MHz
    ldi  r18, 41
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	ret
