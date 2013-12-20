#pragma once
/**
 * Generate and send Morse Code on an LED or a speaker. Allow sending
 * in a non-blocking manner (by calling a 'continue sending' method
 * every so often to turn an LED on/off, or to call tone/noTone appropriately).
 *
 * All input should be lowercase. Prosigns (SK, KN, etc) have special
 * character values #defined.
 *
 * See also:
 * Morse decoder (using binary tree):
 * http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1289074596/15
 * Generator (on playground):
 * http://www.arduino.cc/playground/Code/Morse
 */

// for malloc and free, for the new/delete operators
#include <stdlib.h>

// Arduino language types
#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

#define WPM_DEFAULT	12.0
// PARIS WPM measurement: 50; CODEX WPM measurement: 60 (Wikipedia:Morse_code)
#define DITS_PER_WORD	50

// Bitmasks are 1 for dah and 0 for dit, in left-to-right order;
//	the sequence proper begins after the first 1 (a sentinel).
//	Credit for this scheme to Mark VandeWettering K6HX ( brainwagon.org ).
typedef int             morseTiming_t;
typedef unsigned char	morseBitmask_t; // see also MAX_TIMINGS
#define MORSE_BITMASK_HIGH_BIT	B10000000

// sentinel
#define END             0

// the most timing numbers any unit will need; ex: k = on,off,on,off,on,end = 5
#define MAX_TIMINGS     15

// Punctuation and Prosigns
#define PROSIGN_SK	'S'
#define PROSIGN_KN	'K'
typedef struct {
	char c;
	morseBitmask_t timing;
} specialTiming;
const specialTiming MORSE_PUNCT_ETC[] = {
	{'.',		B1010101},
	{'?',		B1001100},
	{PROSIGN_SK,	B1000101},
	{PROSIGN_KN,	B110110},
	{END,		B1},
};

// Morse Code (explicit declaration of letter timings)
const morseBitmask_t MORSE_LETTERS[26] = {
	/* a */ B101,
	/* b */ B11000,
	/* c */ B11010,
	/* d */ B1100,
	/* e */ B10,
	/* f */ B10010,
	/* g */ B1110,
	/* h */ B10000,
	/* i */ B100,
	/* j */ B10111,
	/* k */ B1101,
	/* l */ B10100,
	/* m */ B111,
	/* n */ B110,
	/* o */ B1111,
	/* p */ B10110,
	/* q */ B11101,
	/* r */ B1010,
	/* s */ B1000,
	/* t */ B11,
	/* u */ B1001,
	/* v */ B10001,
	/* w */ B1011,
	/* x */ B11001,
	/* y */ B11011,
	/* z */ B11100,
};


/**
 * Define the logic of converting characters to on/off timing,
 * and encapsulate the state of one sending-in-progress Morse message.
 *
 * Subclasses define setOn and setOff for (for example) LED and speaker output.
 */
class MorseSender {
protected:
	const unsigned int pin;
	// These would be pure virtual, but that has compiler issues.
	// See: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1167672075 .
	virtual void setOn();
	virtual void setOff();

private:
	morseTiming_t DIT, DAH;
	String message;

	// on,off,...,wait,0 list, millis
	morseTiming_t timingBuffer[MAX_TIMINGS+1];

	// index of the character currently being sent
	unsigned int messageIndex;
	// timing unit currently being sent
	unsigned int timingIndex;

	// when this timing unit was started
	unsigned long lastChangedMillis;

	/**
	 * Copy definition timings (on only) to raw timings (on/off).
	 * @return the number of 'on' timings copied
	 */
	int copyTimings(morseTiming_t *rawOut,
		morseBitmask_t definition);

	/**
	 * Fill a buffer with on,off,..,END timings (millis)
	 * @return the index at which to start within the new timing sequence
	 */
	unsigned int fillTimings(char c);

public:
	/**
	 * Create a sender which will output to the given pin.
	 */
	MorseSender(unsigned int outputPin, float wpm=WPM_DEFAULT);

	/**
	 * To be called during the Arduino setup(); set the pin as OUTPUT.
	 */
	void setup();

	/**
	 * Set the words per minute (based on PARIS timing).
	 */
	void setWPM(float wpm);
	/**
	 * Set the duration, in milliseconds, of a DIT.
	 */
	void setSpeed(morseTiming_t duration);

	/**
	 * Set the message to be sent.
	 * This halts any sending in progress.
	 */
	void setMessage(const String newMessage);

	/**
	 * Send the entirety of the current message before returning.
	 */
	void sendBlocking();

	/**
	 * Prepare to send and begin sending the current message.
	 */
	void startSending();

	/**
	 * Switch outputs on and off (and refill the internal timing buffer)
	 * as necessary to continue with the sending of the current message.
	 * This should be called every few milliseconds (at a significantly
	 * smaller interval than a DIT) to produce a legible fist.
	 *
	 * @see startSending, which must be called first
	 * @return false if sending is complete, otherwise true (keep sending)
	 */
	boolean continueSending();

	void *operator new(size_t size);
	void operator delete(void* ptr);
};


class SpeakerMorseSender: public MorseSender {
  private:
    unsigned int frequency;
  protected:
    virtual void setOn();
    virtual void setOff();
  public:
    // concert A = 440
    // middle C = 261.626; higher octaves = 523.251, 1046.502
    SpeakerMorseSender(int outputPin, unsigned int toneFrequency=1046,
	float wpm=WPM_DEFAULT);
};


class LEDMorseSender: public MorseSender {
  protected:
    virtual void setOn();
    virtual void setOff();
  public:
    LEDMorseSender(int outputPin, float wpm=WPM_DEFAULT);
};

