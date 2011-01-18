/**
 * Generate and send Morse Code on an LED or a speaker. Allow sending
 * in a non-blocking manner (by calling a 'continue sending' method every so often
 * to turn an LED on/off, or to call tone/noTone appropriately).
 */

#include <stdlib.h>

// define lengths
typedef int             morseTiming_t;
#define UNIT            100
#define DIT             UNIT
#define DAH             3*UNIT
// sentinel
#define END             0
// the most timing numbers any unit will need; ex: k = on,off,on,off,on,end = 5
#define MAX_TIMINGS     10

// Morse Code (explicit declaration of letter timings)
const morseTiming_t MORSE[26][5] = {
  /* a */ {DIT, DAH, END},
  /* b */ {DAH, DIT, DIT, DIT, END},
  /* c */ {DAH, DIT, DAH, DIT, END},
  /* d */ {DAH, DIT, DIT, END},
  /* e */ {DIT, END},
  /* f */ {DIT, DIT, DAH, DIT, END},
  /* g */ {DAH, DAH, DIT, END},
  /* h */ {DIT, DIT, DIT, DIT, END},
  /* i */ {DIT, DIT, END},
  /* j */ {DIT, DAH, DAH, DAH, END},
  /* k */ {DAH, DIT, DAH, END},
  /* l */ {DIT, DAH, DIT, DIT, END},
  /* m */ {DAH, DAH, END},
  /* n */ {DAH, DIT, END},
  /* o */ {DAH, DAH, DAH, END},
  /* p */ {DIT, DAH, DAH, DIT, END},
  /* q */ {DAH, DAH, DIT, DAH, END},
  /* r */ {DIT, DAH, DIT, END},
  /* s */ {DIT, DIT, DIT, END},
  /* t */ {DAH, END},
  /* u */ {DIT, DIT, DAH, END},
  /* v */ {DIT, DIT, DIT, DAH},
  /* w */ {DIT, DAH, DAH, END},
  /* x */ {DAH, DIT, DIT, DAH, END},
  /* y */ {DAH, DIT, DAH, DAH, END},
  /* z */ {DAH, DAH, DIT, DIT, END},
};

/**
 * Define the logic of converting characters to on/off timing,
 * and encapsulate the state of one sending-in-progress Morse message.
 *
 * Subclasses define setOn and setOff for (for example) LED and speaker output.
 */
class MorseSender {
  private:
    String message;
    morseTiming_t timingBuffer[MAX_TIMINGS+1]; // on,off,...,wait,0 list, millis
    unsigned int messageIndex; // index of the character currently being sent
    unsigned int timingIndex; // timing unit currently being sent
    unsigned long lastChangedMillis; // when this timing unit was started
    
    /**
     * Fill a buffer with on,off,..,END timings (millis)
     * @return the index at which to start within the new timing sequence
     */
    unsigned int fillTimings(char c)
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
    
  protected:
    const unsigned int pin;
    // These would be pure virtual, but that has compiler issues.
    // See: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1167672075 .
    virtual void setOn() {};
    virtual void setOff() {};
    
  public:
    /**
     * Create a sender which will output to the given pin.
     */
    MorseSender(unsigned int outputPin): pin(outputPin) {}
    
    /**
     * To be called during the Arduino setup(); set the pin as OUTPUT.
     */
    void setup() { pinMode(pin, OUTPUT); }
    
    /**
     * Set the message to be sent.
     * This halts any sending in progress.
     */
    void setMessage(const String newMessage)
    {
      message = newMessage;
      
      // Force startSending() before continueSending().
      messageIndex = message.length();
    }
    
    /**
     * Send the entirety of the current message before returning.
     */
    void sendBlocking()
    {
      //Serial.println("Sending blocking: ");
      //Serial.println(message);
      startSending();
      while(continueSending());
    }
    
    /**
     * Prepare to send and begin sending the current message.
     */
    void startSending()
    {
      messageIndex = 0;
      if (message.length() == 0) { return; }
      timingIndex = fillTimings(message[0]);
      setOn();
      lastChangedMillis = millis();
      //Serial.print("Starting with (on) ");
      //Serial.println((int)timingBuffer[timingIndex]);
    }
    
    /**
     * Switch outputs on and off (and refill the internal timing buffer)
     * as necessary to continue with the sending of the current message.
     * This should be called every few milliseconds (at a significantly smaller
     * interval than UNIT) to produce a legible fist.
     *
     * @see startSending, which must be called first
     * @return false if sending is complete, otherwise true (keep sending)
     */
    boolean continueSending()
    {
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
    
    void *operator new(size_t size) { return malloc(size); }
    void operator delete(void* ptr) { if (ptr) free(ptr); }
};

class SpeakerMorseSender: public MorseSender {
  private:
    unsigned int frequency;
  protected:
    virtual void setOn() { tone(pin, frequency); }
    virtual void setOff() { noTone(pin); }
  public:
    // concert A = 440
    // middle C = 261.626; higher octaves = 523.251, 1046.502
    SpeakerMorseSender(int outputPin, unsigned int toneFrequency=440)
      : MorseSender(outputPin), frequency(toneFrequency) {};
};

class LEDMorseSender: public MorseSender {
  protected:
    virtual void setOn() { digitalWrite(pin, HIGH); }
    virtual void setOff() { digitalWrite(pin, LOW); }
  public:
    LEDMorseSender(int outputPin) : MorseSender(outputPin) {};
};


/* Example: send blocking and non-blocking messages in Morse Code.
 */


#define PIN_STATUS      13
#define PIN_SPEAKER     2

LEDMorseSender readySender(PIN_STATUS);
MorseSender *callsignSenderPtr, *cqSenderPtr;

void setup()
{
  callsignSenderPtr = new SpeakerMorseSender(PIN_SPEAKER);
  callsignSenderPtr->setup();
  callsignSenderPtr->setMessage(String("73 de kb3jcy  "));
  
  cqSenderPtr = new LEDMorseSender(PIN_STATUS);
  cqSenderPtr->setup();
  cqSenderPtr->setMessage("cq  ");
  
  //Serial.begin(28800);
  
  // Send KN blocking, on the status LED.
  readySender.setup();
  readySender.setMessage(String("kn "));
  readySender.sendBlocking();
  
  callsignSenderPtr->startSending();
  cqSenderPtr->startSending();
}

void loop()
{
  // Send a CQ (LED) and a 73 (speaker) simultaneously, to demonstrate
  // the ability to send Morse Code while doing other computation.
  
  if (!callsignSenderPtr->continueSending())
  {
    callsignSenderPtr->startSending();
  }

  if (!cqSenderPtr->continueSending())
  {
    cqSenderPtr->startSending();
  }
}
