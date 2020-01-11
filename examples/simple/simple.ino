/**
 * Send CQ (-.-. --.-) on the status LED.
 *
 * Demonstrate the most simple usage: send one Morse Code message, once,
 * while blocking (not doing anything else).
 */

#include <morse.h>

#define PIN_STATUS	13

void setup()
{
	LEDMorseSender cqSender(PIN_STATUS);
	cqSender.setup();
	cqSender.setMessage(String("cq "));
	cqSender.sendBlocking();
}

void loop()
{
}

