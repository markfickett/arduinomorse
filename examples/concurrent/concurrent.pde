/**
 * Send Morse while allowing other work to progress also; to demonstrate,
 * send two Morse messages at the same time, one over the builtin status LED
 * and the other over a speaker connected to digital pin 2.
 *
 * Also demonstrate using a MorseSender declared on the stack, as well as
 * dynamically instantiating two (of different dynamic types but both statically
 * typed as MorseSender *).
 */

#include <morse.h>

#define PIN_STATUS	13
#define PIN_SPEAKER	3

LEDMorseSender readySender(PIN_STATUS);
MorseSender *cqSender, *callsignSender;

void setup()
{
	readySender.setup();
	readySender.setMessage(String(PROSIGN_KN) + String(" "));

	cqSender = new LEDMorseSender(PIN_STATUS);
	cqSender->setup();
	cqSender->setMessage(String("cq "));

	callsignSender = new SpeakerMorseSender(PIN_SPEAKER);
	callsignSender->setup();
	callsignSender->setMessage(String("73 de kb3jcy "));

	readySender.sendBlocking();
}

void loop()
{
	if(!cqSender->continueSending())
	{
		cqSender->startSending();
	}

	if(!callsignSender->continueSending())
	{
		callsignSender->startSending();
	}
}
