//#define DEBUG

// EV100 VIdeo sense signal is HIGH if in AVIN mode
#define PIN_SWITCH_VIDEO 	0	//PB0
#define PIN_LED_DEBUG		2 	//PB2
#define PIN_EV100_SIG		3 	//PB3
#define PIN_DVR_K3 			4	//PB4

// Pressing button for 2 seconds toggles DVR mode (Record/Playback)
#define DVR_K3_OFF bitClear(DDRB, PIN_DVR_K3) // Button released
#define DVR_K3_ON bitSet(DDRB, PIN_DVR_K3) // Button pressed
#define LED_DEBUG_ON bitClear(PORTB, PIN_LED_DEBUG) // LED ON
#define LED_DEBUG_OFF bitSet(PORTB, PIN_LED_DEBUG) // LED OFF

uint8_t DVR_state = 0;	// 0 - recording; other - playback
uint8_t EV100_state = 0;

void setup()
{
	bitClear(PORTB,PIN_DVR_K3);	// control DVR
	DVR_K3_OFF;
	bitClear(DDRB,PIN_EV100_SIG);	// listen for signal level pin
	bitSet(DDRB, PIN_SWITCH_VIDEO); //Video Switch
	// when not connected to EV100. Later we remove pullup.
	bitSet(PORTB, PIN_SWITCH_VIDEO); //PullUp
	LED_DEBUG_OFF;
	bitSet(DDRB, PIN_LED_DEBUG);
	
	ReadEV100state();	// update EV100state variable
}


void loop() {
	// listen for signal level
	ReadEV100state();
	if(EV100_state!=DVR_state){
		// switch DVR state
		DVR_K3_ON;
		LED_DEBUG_ON;
		delay(2000);
		DVR_K3_OFF;
		LED_DEBUG_OFF;
		
		DVR_state = EV100_state;
	}
       
	
}



void ReadEV100state(){
	uint8_t new_state = (PINB & (1<<PIN_EV100_SIG));
	delay(50);
	if(new_state == (PINB & (1<<PIN_EV100_SIG))){EV100_state=new_state;}
}