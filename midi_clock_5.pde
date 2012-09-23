 /*
To do: 
Fix pin 13 DONE
Enable switch: clock A, Clock B, Clock C DONE
Fix div ratios - really strange numbers coming out DONE.
Enable swing on pulse in DONE
Tidy up code 
Enable Random
Consider using switch for swing 
Enable CV when clock is running from MIDI 
Enable CC from Midi to influence divisor and swing 




HARDWARE IN MODULE 
Digital outs: 9-13 = breakout board 
Analog ins: 
0-knob 1
1-knob 2
2-switch - high med low 
4-3.5mm jack 


*/

byte midi_start = 0xfa;
byte midi_stop = 0xfc;
byte midi_clock = 0xf8;
byte midi_continue = 0xfb;
int play_flag = 0;
int firstpin = 9;
int lastpin = 13;
int length = 5; //trigger length
int pincount = lastpin-firstpin;

int divsize = 10; // = how many elements in clockdiv?
int clockdiv[3][10] = {
{3,6,8,12,16,24,36,48,96,192}, // pretty good set 
{2,4,6,8,10,12,14,16,18,20}, // quick set 
{3,6,12,24,48,96,192,384,768,1536}}; // standard notes from midi clock 
int divchoice;
int divswitch = 2;



int pulseinput=2;
int oldpulse;
int newpulse;



int clockoffset=0;
int offsetknob=0; // offset knob 

int swing; 
int swingswitch=1; //swing switch
int swingswitchval;


int clockoffsetmax = divsize-pincount; //how far can the div offset go?
byte data;
int count; 

void setup() {
Serial.begin(31250); //regular 
//Serial.begin(15625); //8mhz baud fix 

for(int set = firstpin; set<=lastpin; set++){
pinMode(set, OUTPUT);}
}

void loop() {
  
if(Serial.available() > 0) { //Start reading MIDI data
data = Serial.read();

if(data == midi_start) {
play_flag = 1;
count = 0;
}
else if(data == midi_continue) {
play_flag = 1;
}
else if(data == midi_stop) {
play_flag = 0;
}
else if((data == midi_clock) && (play_flag == 1)) {
Sync();
}

}
// ANALOG PULSE TRIGGER 
newpulse=map(analogRead(pulseinput),0,1024,0,3); // Pulse input 
if (newpulse>oldpulse){
Sync();}
oldpulse = newpulse;


}

// MAIN SYNC LOOP 

void Sync() {

  
clockoffset= map(analogRead(offsetknob),0,1024,0,clockoffsetmax); //check  for offset   
swing=map(analogRead(swingswitch),10,1000,-2,0); // check for swing 
divchoice=map(analogRead(divswitch),300,900,0,2); //check for mode 
  
  int flashes[pincount+1];

for (int x=0; x<=pincount;x++){ //runs through the flashes matrix, adding 0 or 1 depending on count vs clockdiv

// DIVIDE/SWING ROUTINE
int div = clockdiv[divchoice][x+clockoffset];

if (count % (div*2) == 0 || (count+div+swing) % (div*2) == 0){flashes[x] = 1;}
else {flashes[x] = 0;}


// Old, working routine 
//if (count%div*2 != 0){flashes[x] = 0;}
//if (count%div*2 == 0){flashes[x] = 1;}



}
  
  for (int y=0; y<=pincount;y++){
    if (flashes[y] == 1){  digitalWrite(firstpin+y, HIGH);};}
   delay(length);
  for (int y=0; y<=pincount;y++){
  digitalWrite(firstpin+y, LOW);
}
   
count = count+1; 


}


