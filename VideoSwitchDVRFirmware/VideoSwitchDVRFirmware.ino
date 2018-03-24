#define DEBUG // Debug board (pins routed different)
//#define MODECHANGE_PLAYRECORD // Change DVR mode according to Goggles mode (normal/AV)
//#define START_RECORDING // Start recording on power on.
#define POWERLOSS_STOPRECORDING // Stop recording on power loss.

#define POWERON_DELAY 2000	//ms

// EV100 VIdeo sense signal is HIGH if in AVIN mode
#ifdef DEBUG
	#define PIN_SWITCH_VIDEO 	0	//PB0
	#define PIN_EV100_SIG		3 	//PB3
	#define PIN_DVR_K1			1 	//PB1 (DEBUG LED)
	#define PIN_DVR_K3 			4	//PB4
	#define PIN_DVR_POWER		2	//PB2 (LED)
#else
	#define PIN_SWITCH_VIDEO 	4	//PB4
	#define PIN_EV100_SIG		3 	//PB3
	#define PIN_DVR_K1 			0	//PB0
	#define PIN_DVR_K3 			2	//PB2
	#define PIN_DVR_POWER		1	//PB1
#endif

#define EV100AV (1<<PIN_EV100_SIG)	// AV Mode when pin PIN_EV100_SIG is HIGH
	
// Pressing button for 2 seconds toggles DVR mode (Record/Playback)
#ifdef DEBUG
	#define LED_DEBUG_ON bitClear(PORTB, PIN_DVR_K1) // LED ON
	#define LED_DEBUG_OFF bitSet(PORTB, PIN_DVR_K1) // LED OFF
#else
	#define DVR_K1_OFF bitClear(DDRB, PIN_DVR_K1) // Button released
	#define DVR_K1_ON bitSet(DDRB, PIN_DVR_K1) // Button pressed
#endif
// Start/stop recording
#define DVR_K3_OFF bitClear(DDRB, PIN_DVR_K3) // Button released
#define DVR_K3_ON bitSet(DDRB, PIN_DVR_K3) // Button pressed
#define DVR_POWER_ON bitClear(PORTB, PIN_DVR_POWER) // DVR POWER ON
#define DVR_POWER_OFF bitSet(PORTB, PIN_DVR_POWER) // DVR POWER OFF

uint8_t DVR_state;	// 0 - recording; anything else - playback
uint8_t EV100_state = 0;

void setup()
{
	DVR_POWER_OFF; // DVR Power is OFF
	bitSet(DDRB,PIN_DVR_POWER);	//  port as output
#ifndef DEBUG
	bitClear(PORTB,PIN_DVR_K1);	// control DVR
	DVR_K1_OFF;
#endif
	bitClear(PORTB,PIN_DVR_K3);	// control DVR
	DVR_K3_OFF;
	bitClear(DDRB,PIN_EV100_SIG);	// listen for signal level pin
	// PIN_SWITCH_VIDEO has a double function.
	// We are listening for power loss and switching video in/out.
	// We need to listen only while recording. So, AVin should be connected when PIN_SWITCH_VIDEO is high (default).
	// PIN_SWITCH_VIDEO is pulled up by Goggle power.
	bitClear(PORTB, PIN_SWITCH_VIDEO); // Video Switch default video from EV100 to DVR (recording)
	bitClear(DDRB, PIN_SWITCH_VIDEO); // Listening for power loss...
	
	#ifdef DEBUG
		// when not connected to EV100. Later we remove pullup.
		bitSet(PORTB, PIN_EV100_SIG); //PullUp
		bitSet(DDRB, PIN_DVR_K1);
		LED_DEBUG_OFF;
	#endif
	
	DVR_state = 0; // After power on we are in recording mode

	#ifdef DEBUG
		LED_DEBUG_ON;
	#endif		
	delay(POWERON_DELAY);
	#ifdef DEBUG
		LED_DEBUG_OFF;
	#endif		
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
		//Active Low
		//bitClear(PORTB, PIN_SWITCH_VIDEO);
		bitSet(DDRB, PIN_SWITCH_VIDEO);
	}else{
		//Floating (Pulled up by external resistor)
		bitClear(DDRB, PIN_SWITCH_VIDEO);
		//bitClear(PORTB, PIN_SWITCH_VIDEO);
	}
	
#ifdef MODECHANGE_PLAYRECORD
	if(EV100_state==EV100AV){
		// switch DVR to PLAY mode. Pressing K3 button for 2 seconds will stop recording and go to PLAY mode.
		DVR_K1_ON;
		#ifdef DEBUG
		LED_DEBUG_ON;
		#endif
		delay(2000);
		DVR_K1_OFF;
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
	// sense PIN_SWITCH_VIDEO pin only while EV100 in normal mode. If low, then stop recording as soon as possible
	if(EV100_state==0){ // check for power loss only while recording
		if((PINB & (1<<PIN_SWITCH_VIDEO))==0){
			// stop recording
			#ifdef DEBUG
				LED_DEBUG_ON;
			#endif		
			DVR_K3_ON;
			delay(200);
			#ifdef DEBUG
				LED_DEBUG_OFF;
			#endif		
			DVR_K3_OFF;
			while(1){}; //wait until supercapacitor will be empty
		}
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
	delay(9000);	// wait while DVR is booting and will be ready for recording
	DVR_K3_ON;
	delay(200);
	DVR_K3_OFF;
}
#endif