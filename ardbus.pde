// License=MIT    Vitaly "_Vi" Shukela    2012

#define DIGITAL_PIN_COUNT 14
#define MASKED_PINS 2

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
    for(i=MASKED_PINS; i<DIGITAL_PIN_COUNT; ++i) {
        unsigned char c = digitalRead(i);
        Serial.write(c+'0');
    }
    Serial.write('\n');
    serialEvent_();
    if(stringComplete){
        if(is[0]=='A' && is[1]=='r') {
            if(is[2]=='D' && is[3]=='i') {
                for(i=MASKED_PINS,j=4; i<DIGITAL_PIN_COUNT; ++i,++j) {
                    digitalWrite(i, is[j]-'0');
                }
            }else
            if(is[2]=='M' && is[3]=='o') {
                for(i=MASKED_PINS,j=4; i<DIGITAL_PIN_COUNT; ++i,++j) {
                    pinMode(i, is[j]-'0');
                }
            }
            if(is[2]=='A' && is[3]=='n') {
                unsigned char pin = (is[4]-'0')*10+(is[5]-'0');
                int val = analogRead(pin);
                Serial.print("ArAn");
                Serial.print(val);
                Serial.write('\n');
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
