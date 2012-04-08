#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

#define MAXDIGPORTS 14
#define MASKED_PORTS 2

char inputString[40];
unsigned char cursor;
boolean stringComplete = false;

#define is (inputString)

void setup() {
    Serial.begin(115200);
}

void serialEvent_(); /* My arduino development kit seems not to have it */

void loop() {
    unsigned char i,j;
    Serial.print("ArDi");
    for(i=MASKED_PORTS; i<MAXDIGPORTS; ++i) {
        unsigned char c = digitalRead(i);
        Serial.write(c+'0');
    }
    Serial.write('\n');
    serialEvent_();
    if(stringComplete){
        if(is[0]=='A' && is[1]=='r') {
            if(is[2]=='D' && is[3]=='i') {
                for(i=MASKED_PORTS,j=4; i<MAXDIGPORTS; ++i,++j) {
                    digitalWrite(i, is[j]-'0');
                }
            }else
            if(is[2]=='M' && is[3]=='o') {
                for(i=MASKED_PORTS,j=4; i<MAXDIGPORTS; ++i,++j) {
                    pinMode(i, is[j]-'0');
                }
            }
        }
    }

}                         

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent_() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    inputString[cursor] = inChar;
    ++cursor;
    if (inChar == '\n') {
      inputString[cursor] = 0;
      stringComplete = true;
      cursor=0;
    }
  }
}
