#define DEBUG // Debug board (pins routed different)
#define MODECHANGE_PLAYRECORD // Change DVR mode according to Goggles mode (normal/AV)
#define START_RECORDING // Start recording on power on.
#define POWERLOSS_STOPRECORDING // Stop recording on power loss.

#define POWERON_DELAY 2000	//ms

// EV100 VIdeo sense signal is HIGH if in AVIN mode
#ifdef DEBUG
	#define PIN_SWITCH_VIDEO 	0	//PB0
	#define PIN_EV100_SIG		3 	//PB3
	#define PIN_DVR_B0			2 	//PB2 (DEBUG LED)
	#define PIN_DVR_B2 			4	//PB4
	#define PIN_DVR_POWER		1	//PB1 (LED)
#else
	#define PIN_SWITCH_VIDEO 	4	//PB4
	#define PIN_EV100_SIG		3 	//PB3
	#define PIN_DVR_B0 			0	//PB0
	#define PIN_DVR_B2 			2	//PB2
	#define PIN_DVR_POWER		1	//PB1
#endif

#define EV100AV (1<<PIN_EV100_SIG)	// AV Mode when pin PIN_EV100_SIG is HIGH
	
// Pressing button for 2 seconds toggles DVR mode (Record/Playback)
#define DVR_B2_OFF bitClear(DDRB, PIN_DVR_B2) // Button released
#define DVR_B2_ON bitSet(DDRB, PIN_DVR_B2) // Button pressed
#define DVR_POWER_ON bitClear(PORTB, PIN_DVR_POWER) // DVR POWER ON
#define DVR_POWER_OFF bitSet(PORTB, PIN_DVR_POWER) // DVR POWER OFF
#ifdef DEBUG
	#define LED_DEBUG_ON bitClear(PORTB, PIN_DVR_B0) // LED ON
	#define LED_DEBUG_OFF bitSet(PORTB, PIN_DVR_B0) // LED OFF
#endif

uint8_t DVR_state;	// 0 - recording; anything else - playback
uint8_t EV100_state = 0;

void setup()
{
	DVR_POWER_OFF; // DVR Power is OFF
	bitSet(DDRB,PIN_DVR_POWER);	//  port as output
	bitClear(PORTB,PIN_DVR_B2);	// control DVR
	DVR_B2_OFF;
	bitClear(DDRB,PIN_EV100_SIG);	// listen for signal level pin
	bitSet(PORTB, PIN_SWITCH_VIDEO); // Video Switch default video from EV100 to DVR (recording)
	bitSet(DDRB, PIN_SWITCH_VIDEO); //Video Switch port direction
	#ifdef POWERLOSS_STOPRECORDING
		bitClear(DDRB,PIN_DVR_B0);
		bitClear(PORTB,PIN_DVR_B0);
	#endif
	
	#ifdef DEBUG
		bitSet(DDRB, PIN_DVR_B0);
		// when not connected to EV100. Later we remove pullup.
		bitSet(PORTB, PIN_EV100_SIG); //PullUp
		LED_DEBUG_OFF;
	#endif
	
	DVR_state = 0; // After power on we are in recording mode
	
	delay(POWERON_DELAY);
	DVR_POWER_ON;

	#ifdef START_RECORDING
		startRecording();	// delay and start recording
	#endif
	
	ReadEV100state();	// update EV100state variable
}


void loop() {
	// listen for signal level
	ReadEV100state();
	
	// turn video switch according to EV100 state
	if(EV100_state==EV100AV){
		bitClear(PORTB, PIN_SWITCH_VIDEO);
	}else{
		bitSet(PORTB, PIN_SWITCH_VIDEO);
	}
	
#ifdef MODECHANGE_PLAYRECORD
	if(EV100_state==EV100AV){
		// switch DVR to PLAY mode. Pressing K3 button for 2 seconds will stop recording and go to PLAY mode.
		DVR_B2_ON;
		#ifdef DEBUG
		LED_DEBUG_ON;
		#endif
		delay(2000);
		DVR_B2_OFF;
		#ifdef DEBUG
		LED_DEBUG_OFF;
		#endif		
		DVR_state=1;	//play
	}else{
		// EV100 mode is normal. Need to  determine, are we just switched from AV?
		if(DVR_state!=0){
			// we need to reboot DVR to make 100% switch to recording mode
			DVR_POWER_OFF;
			delay(2000);
			DVR_POWER_ON;
			DVR_state=0; //record
			#ifdef START_RECORDING
				// If needed let's start recording.
				startRecording();
			#endif
		}
	}
#endif

#ifdef POWERLOSS_STOPRECORDING
	// sense B0 pin. If low, then stop recording as soon as possible
	if(!(PINB & (1<<PIN_DVR_B0))){
		// stop recording
		DVR_B2_ON;
		delay(200);
		DVR_B2_OFF;
		while(1){}; //wait until supercapacitor will be empty
	}
#endif
      
	
}


void ReadEV100state(){
	uint8_t new_state = (PINB & (1<<PIN_EV100_SIG));
	delay(50);
	if(new_state == (PINB & (1<<PIN_EV100_SIG))){EV100_state=new_state;}
}

#ifdef START_RECORDING
void startRecording(){
	delay(3000);	// wait while DVR is booting and will be ready for recording
	DVR_B2_ON;
	delay(200);
	DVR_B2_OFF;
}
#endif