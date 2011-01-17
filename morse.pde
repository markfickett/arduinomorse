/**
 * Utilities for and a simple example of sending Morse Code
 */

#define PIN_STATUS      13

// define lengths
#define UNIT            200
#define DIT             UNIT
#define DAH             3*UNIT
// sentinel
#define END             0

// Morse Code
const int MORSE[26][5] = {
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

void sendString(const char *msg, int pin)
{
  for(int i = 0; msg[i] != '\0'; ++i)
  {
    char c = msg[i];
    if (c >= 'a' && c <= 'z')
    {
      for(int j = 0; MORSE[c-'a'][j] != END; ++j)
      {
        digitalWrite(pin, HIGH);
        delay(MORSE[c-'a'][j]);
        digitalWrite(pin, LOW);
        delay(DIT);
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
      for(int j = 0; j < 5; ++j)
      {
        digitalWrite(pin, HIGH);
        delay(((j < n) == ditsFirst) ? DIT : DAH);
        digitalWrite(pin, LOW);
        delay(DIT);
      }
    }
    delay(DAH);
  }
}

void setup()
{
  pinMode(PIN_STATUS, OUTPUT);
}

void loop()
{
  sendString("73 de kb3jcy", PIN_STATUS);
  delay(2*DAH);
}
