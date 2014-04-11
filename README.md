<h1>Morse Code Library for Arduino with Non-Blocking Sending</h1>

<p>This is a library for generating and sending <a href="http://en.wikipedia.org/wiki/Morse_code">Morse code</a>; particularly, via <acronym>LED</acronym> or speaker. Among myriad such libraries, its key feature is allowing Morse to be sent without blocking other processes, such as monitoring sensors.</p>

<h2>Authorship and License</h2>

<a rel="license" href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" id="license" src="http://i.creativecommons.org/l/by/3.0/80x15.png" /></a>

<p>This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>; it is written by <a href="http://www.markfickett.com/">Mark Fickett</a>. (Do <a href="mailto:mark.fickett@gmail.com">let me know</a> if you find it interesting or useful! Or, should you find bugs, a report or a <a href="http://help.github.com/pull-requests/">pull request</a> would be welcome.)</p>

<h2>Example</h2>

<p>The library includes several examples; or see below. Briefly:</p>

	#define PIN_STATUS	13
	LEDMorseSender sender(PIN_STATUS);
	void setup() {
		sender.setup();
		sender.setMessage(String("73 de kb3jcy "));
		sender.startSending();
	}
	void loop() {
		sender.continueSending();
	}

<p>Or, in more detail:</p>

	// Morse will be sent on the built-in status LED on pin 13.
	#define PIN_STATUS	13
	// For example, a switch might be connected to pin 12.
	#define PIN_SENSOR	12
	
	#include <morse.h>
	
	LEDMorseSender sender(PIN_STATUS);
	
	void setup()
	{
		// Set the pin as OUTPUT.
		sender.setup();
		// Set the message to be sent. (This may be set again at any point, as
		// may be speed (wpm) or, for SpeakerMorseSender, the tone frequency.)
		sender.setMessage(String("73 de kb3jcy "));
	
		// Other setup:
		pinMode(PIN_SENSOR, INPUT);
		digitalWrite(PIN_SENSOR, HIGH);
	}
	
	void loop()
	{
		// Calling continueSending checks elapsed time and toggles the output
		// accordingly. It returns false if the entire message has been sent,
		// or if the sender is uninitialized.
		if (!sender.continueSending())
		{
			// Set the internal counters to the message's beginning.
			// Here, this results in repeating the message indefinitely.
			sender.startSending();
		}
	
		// Do arbitrary other work, so long as it takes significantly less time
		// than sending a Morse element.
		if (digitalRead(PIN_SENSOR) == LOW)
		{
			// ...
		}
	}

<h2>Installation</h2>

<p>See "Contributed Libraries" on <a href="http://www.arduino.cc/en/Reference/Libraries">arduino.cc Libraries reference</a>. Briefly, place these files in a <code>morse</code> subdirectory in your sketchbook directory.</p>

<h2>Character Support</h2>

<p>The alphabet is supported (all input must be lowercase), as are numbers.</p>

<p>There is partial support for punctuation and (using symbolic constants which take uppercase alphabetic values) <a href="http://en.wikipedia.org/wiki/Prosigns_for_Morse_code">prosigns</a>; all that is required for expanding support is entering definitions.</p>

<h2>Motivation</h2>

<p>This was written to be used for status output for a <a href="http://github.com/markfickett/bicycle">bicycle cyclocomputer</a> project using the LilyPad Arduino, which produces multi-second Morse output while at the same time counting bicycle wheel revolutions.</p>

