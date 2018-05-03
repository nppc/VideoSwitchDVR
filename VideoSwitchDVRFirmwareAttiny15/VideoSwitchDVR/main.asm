;
; VideoSwitchDVR.asm
;
; Author : Pavel Palonen
;

; Attiny15 runs with default fuses (at 1.6mhz)

;#define DEBUG
#define MODECHANGE_PLAYRECORD ; Change DVR mode according to Goggles mode (normal/AV)
;#define START_RECORDING ; Start recording on power on.
;#define POWERLOSS_STOPRECORDING ; Stop recording on power loss.

#define POWERON_DELAY 2000	;ms


.include "tn15def.inc"

.equ	PIN_DVR_POWER		= PB1
.equ	PIN_DVR_K1			= PB0
.equ	PIN_DVR_K3			= PB2
.equ	PIN_EV100_SIG		= PB4	; In Attiny25 it is PB3
.equ	PIN_SWITCH_VIDEO	= PB3	; In Attiny25 it is PB4

.def	z0			= r0
.def	z1			= r1
.def	r_sreg		= r2	; Store SREG register in interrupts
.def	DVR_state	= r3	; 0 - recording; anything else - playback
.def	EV100_state = r4
.def	tmp			= r16
.def	tmp1		= r17
.def	tmp2		= r18

#ifdef DEBUG
.def	dbg			= r5
#endif

; Some macros
;DVR_K1_OFF
.MACRO DVR_K1_OFF
	cbi DDRB, PIN_DVR_K1 ; Button released
.ENDMACRO
;DVR_K1_ON
.MACRO DVR_K1_ON
	sbi DDRB, PIN_DVR_K1 ; Button presed
.ENDMACRO
; Start/stop recording
;DVR_K3_OFF
.MACRO DVR_K3_OFF
	cbi DDRB, PIN_DVR_K3 ; Button released
.ENDMACRO
;DVR_K3_ON
.MACRO DVR_K3_ON
	sbi DDRB, PIN_DVR_K3 ; Button pressed
.ENDMACRO
;DVR_POWER_ON
.MACRO DVR_POWER_ON
	cbi PORTB, PIN_DVR_POWER ; DVR POWER ON
.ENDMACRO
;DVR_POWER_OFF
.MACRO DVR_POWER_OFF
	sbi PORTB, PIN_DVR_POWER ; DVR POWER OFF
.ENDMACRO

.EQU EV100AV = (1<<PIN_EV100_SIG)	; AV Mode when pin PIN_EV100_SIG is HIGH

; ***!!!!!*** Hardware Stack in Attiny15 is limited to 3 subsequent subroutine calls or interrupts
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
	DVR_POWER_OFF
	sbi	DDRB, PIN_DVR_POWER	; direction is output
	cbi PORTB, PIN_DVR_K1 ;	control DVR
	DVR_K1_OFF
	cbi PORTB, PIN_DVR_K3 ; control DVR
	DVR_K3_OFF
	cbi DDRB, PIN_EV100_SIG ; listen for signal level pin
	cbi PORTB, PIN_EV100_SIG ; no pullup

	#ifdef DEBUG
		sbi DDRB, PIN_EV100_SIG ; configure as output
		clr dbg
	#endif
	; PIN_SWITCH_VIDEO has a double function.
	; We are listening for power loss and switching video in/out.
	; We need to listen only while recording. So, AVin should be connected when PIN_SWITCH_VIDEO is high (default).
	; PIN_SWITCH_VIDEO is pulled up by Goggle power.
	cbi PORTB, PIN_SWITCH_VIDEO	; Video Switch default video from EV100 to DVR (recording)
	cbi DDRB, PIN_SWITCH_VIDEO ; Listening for power loss...

	; DVR power ON delay
	ldi tmp, POWERON_DELAY/100
	rcall delayNs
	
	DVR_POWER_ON

	#ifdef START_RECORDING
		rcall startRecording ; delay and start recording
	#endif
	
	clr DVR_state ; After power on we are in recording mode
	;rcall ReadEV100state ; update EV100state variable

; ***** LOOP *****
loop:
	#ifdef DEBUG
		rcall delay100ms
		inc dbg
		cpse dbg, z0
		rjmp contdbg
		; toggle sigG
		ldi tmp1, (1<<PIN_EV100_SIG)
		in tmp, PORTB
		and tmp, tmp1
		cpse tmp, z0
		cbi PORTB, PIN_EV100_SIG
		cpse tmp, tmp1
		sbi PORTB, PIN_EV100_SIG
		contdbg:
	#endif

	rcall ReadEV100state ; update EV100state variable

	; turn video switch according to EV100 state
	ldi tmp, EV100AV
	cpse EV100_state, tmp
	cbi DDRB, PIN_SWITCH_VIDEO ; Floating (Pulled up by external resistor)
	cpse EV100_state, z0
	sbi DDRB, PIN_SWITCH_VIDEO ; Active Low

	; Define logic for MODECHANGE_PLAYRECORD
	#ifdef MODECHANGE_PLAYRECORD
		ldi tmp, EV100AV
		cpse EV100_state, tmp
		rjmp EV100RecordMode
		; switch DVR to PLAY mode. Pressing K3 button for 3 seconds will stop recording and go to PLAY mode.
		cpse DVR_state,z0
		rjmp loopCont1	; skip if we already in PLAY mode
		DVR_K3_ON
		ldi tmp, 3000/100
		rcall delayNs
		DVR_K3_OFF
		mov DVR_state,z1 ; play
		rjmp loopCont1
	EV100RecordMode:
		; EV100 mode is normal. Need to  determine, are we just switched from AV?
		cpse DVR_state,z1	; if(DVR_state!=0)
		rjmp loopCont1
		; we need to reboot DVR to make 100% switch to recording mode
		DVR_POWER_OFF
		ldi tmp, 2000/100
		rcall delayNs
		DVR_POWER_ON
		mov DVR_state,z0 ; record
		#ifdef START_RECORDING
			; If needed let's start recording.
			rcall startRecording
		#endif
	loopCont1:
	#endif


	#ifdef POWERLOSS_STOPRECORDING
		; sense PIN_SWITCH_VIDEO pin only while EV100 in normal (record) mode. If low, then stop recording as soon as possible
		ldi tmp, EV100AV
		cpse EV100_state, z0 ; check for power loss only while recording
		rjmp loopCont2
		in tmp, PINB ;new_state
		andi tmp, (1<<PIN_SWITCH_VIDEO)
		cpse tmp, z0
		rjmp loopCont2
		; stop recording
		DVR_K1_ON
		rcall delay100ms
		rcall delay100ms
		DVR_K1_OFF
		halt: rjmp halt ; wait until supercapacitor will be empty
	loopCont2:
	#endif
rjmp loop


#ifdef START_RECORDING
	startRecording:
		; we can't use here delayNs, because our stack is only 3 levels deep (one we need to leave for possible interrupts)
		ldi tmp, 15000/100 ;	wait while DVR is booting and will be ready for recording
	strtRecWait:
		rcall delay100ms
		dec  tmp
		brne strtRecWait
		DVR_K1_ON;
		rcall delay100ms
		rcall delay100ms
		DVR_K1_OFF;
		ret
#endif

; We read control pin from EV100 goggles and make sure, this is not a spike
ReadEV100state:
	; read new_state
	in tmp1, PINB ;new_state
	andi tmp1, EV100AV
	clr tmp
	; small delay
RdEV100StateL1:	
	dec tmp
	brne RdEV100StateL1
	; check pin again and update EV100_state accordingly
	in tmp2, PINB ;new_state
	andi tmp2, EV100AV
	cpse tmp1, tmp2
	mov tmp1, EV100_state	; no change to EV100_state
	mov EV100_state, tmp1
	ret

delay100ms:
; 99ms 995us 625 ns at 1.6 MHz (rcall and ret are not included, about 5us)
    ldi  tmp1, 208
    ldi  tmp2, 200
d100ms: 
	dec  tmp2
    brne d100ms
    dec  tmp1
    brne d100ms
	ret
	
; Delay subroutine
; Input variable: tmp = ms/100	
delayNs:
dNs:rcall delay100ms
    dec  tmp
    brne dNs
	ret
