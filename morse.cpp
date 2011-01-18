// Morse Code sending library

#include <morse.h>


// MorseSender
unsigned int MorseSender::fillTimings(char c)
{
	int t = 0;
	unsigned int start = 0;
	if (c >= 'a' && c <= 'z')
	{
		const morseTiming_t *letterTimings = MORSE[c-'a'];
		while(letterTimings[t] != END)
		{
			timingBuffer[2*t] = letterTimings[t];
			timingBuffer[2*t + 1] = DIT;
			t++;
		}
	}
	else if (c >= '0' && c <= '9')
	{
		int n = c - '0';
		boolean ditsFirst = (n <= 5);
		if (!ditsFirst)
		{
			n -= 5;
		}
		while(t < 5)
		{
			timingBuffer[2*t] = ((t < n) == ditsFirst) ? DIT : DAH;
			timingBuffer[2*t + 1] = DIT;
			t++;
		}
	}
	else
	{
		start = t = 1; // start on a space
	}

	timingBuffer[2*t - 1] = DAH;
	timingBuffer[2*t] = END;

	//Serial.print("Refilled timing buffer for '");
	//Serial.print(c);
	//Serial.print("': ");
	int i = start;
	while(timingBuffer[i] != END)
	{
		//Serial.print((int)timingBuffer[i]);
		//Serial.print(", ");
		i++;
	}
	//Serial.println("END");

	return start;
}

// see note in header about pure-virtual-ness
void MorseSender::setOn() {};
void MorseSender::setOff() {};
    
MorseSender::MorseSender(unsigned int outputPin): pin(outputPin) {}
    
void MorseSender::setup() { pinMode(pin, OUTPUT); }
    
void MorseSender::setMessage(const String newMessage)
{
	message = newMessage;

	// Force startSending() before continueSending().
	messageIndex = message.length();
}

void MorseSender::sendBlocking()
{
	//Serial.println("Sending blocking: ");
	//Serial.println(message);
	startSending();
	while(continueSending());
}

void MorseSender::startSending()
{
	messageIndex = 0;
	if (message.length() == 0) { return; }
	timingIndex = fillTimings(message[0]);
	setOn();
	lastChangedMillis = millis();
	//Serial.print("Starting with (on) ");
	//Serial.println((int)timingBuffer[timingIndex]);
}
    
boolean MorseSender::continueSending()
{
	if(messageIndex >= message.length()) { return false; }

	unsigned long elapsedMillis = millis() - lastChangedMillis;
	if (elapsedMillis < timingBuffer[timingIndex]) { return true; }

	timingIndex++;
	if (timingBuffer[timingIndex] == END)
	{
		messageIndex++;
		if(messageIndex >= message.length()) {
			setOff();
			return false;
		}
	timingIndex = fillTimings(message[messageIndex]);
	}

	lastChangedMillis += elapsedMillis;
	//Serial.print("Next is       ");
	if (timingIndex % 2 == 0) {
		//Serial.print("(on) ");
		setOn();
	} else {
		//Serial.print("(off) ");
		setOff();
	}
	//Serial.println((int)timingBuffer[timingIndex]);

	return true;
}

void *MorseSender::operator new(size_t size) { return malloc(size); }
void MorseSender::operator delete(void* ptr) { if (ptr) free(ptr); }


// SpeakerMorseSender

void SpeakerMorseSender::setOn() { tone(pin, frequency); }
void SpeakerMorseSender::setOff() { noTone(pin); }
SpeakerMorseSender::SpeakerMorseSender(
	int outputPin, unsigned int toneFrequency)
: MorseSender(outputPin), frequency(toneFrequency) {};


// LEDMorseSender

void LEDMorseSender::setOn() { digitalWrite(pin, HIGH); }
void LEDMorseSender::setOff() { digitalWrite(pin, LOW); }
LEDMorseSender::LEDMorseSender(int outputPin) : MorseSender(outputPin) {};

