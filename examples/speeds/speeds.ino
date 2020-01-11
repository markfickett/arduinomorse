/**
 * Send Morse messages at different speeds; also use a different pitch.
 */

#include <morse.h>

#define PIN_STATUS	13
#define PIN_SPEAKER	3

// C above middle C
#define FREQUENCY	523

#define NUM_SPEEDS	5
const float wpms[] = {5.0, 7.5, 10.0, 13.0, 15.0};
const morseTiming_t durations[] = {34.29, 40.0, 48.0, 60.0, 80.0};

LEDMorseSender slowerSender(PIN_STATUS, wpms[0]);
SpeakerMorseSender fasterSender(PIN_SPEAKER, FREQUENCY, durations[0]);

unsigned int speedIndex = 0;
unsigned int lastChangeTime;

void setup()
{
	slowerSender.setup();
	fasterSender.setup();
	slowerSender.setMessage(String("qst de w1aw "));
	fasterSender.setMessage(String("what hath god wrought? "));
	lastChangeTime = millis();
}

void loop()
{
	if (!slowerSender.continueSending())
	{
		slowerSender.startSending();
	}
	if (!fasterSender.continueSending())
	{
		fasterSender.startSending();
	}

	if((millis() - lastChangeTime) > 5000)
	{
		speedIndex++;
		lastChangeTime = millis();
		slowerSender.setWPM(wpms[speedIndex % NUM_SPEEDS]);
		fasterSender.setSpeed(durations[speedIndex % NUM_SPEEDS]);
	}
}

