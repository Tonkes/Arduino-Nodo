#define INPUT_BUFFER_SIZE          128
#define SERIAL_STAY_SHARP_TIME      50

unsigned long StaySharpTimer;
byte SerialInByte;
int SerialInByteCounter=0;
char InputBuffer_Serial[INPUT_BUFFER_SIZE+2];
char Command[40];

void serial()
{
  StaySharpTimer=millis()+SERIAL_STAY_SHARP_TIME;

  while(StaySharpTimer>millis()) // stay focussed
  {          
    while(Serial.available())
    {                        
      SerialInByte=Serial.read();                
      Serial.write(SerialInByte);// echo received char

      StaySharpTimer=millis()+SERIAL_STAY_SHARP_TIME;      

      if(isprint(SerialInByte))
      {
        if(SerialInByteCounter<INPUT_BUFFER_SIZE) // add char to string if it still fits
          InputBuffer_Serial[SerialInByteCounter++]=SerialInByte;
      }

      if(SerialInByte=='\n')
      {
        InputBuffer_Serial[SerialInByteCounter]=0; // serial data completed
        ExecuteLine(InputBuffer_Serial);
        Serial.write('>'); // Prompt
        SerialInByteCounter=0;  
        InputBuffer_Serial[0]=0; // serial data processed, clear buffer
        StaySharpTimer=millis()+SERIAL_STAY_SHARP_TIME;      
      }
    }
  }
}

int ExecuteLine(char *Line)
{
  char *TmpStr1=(char*)malloc(40);
  Command[0]=0;
  byte Par1=0;
  byte Par2=0;
  
  GetArgv(Line,Command,1);
  if(GetArgv(Line,TmpStr1,2)) Par1=str2int(TmpStr1);
  if(GetArgv(Line,TmpStr1,3)) Par2=str2int(TmpStr1);

  ExecuteCommand(Command,Par1,Par2);
}

boolean GetArgv(char *string, char *argv, int argc)
{
  int string_pos=0,argv_pos=0,argc_pos=0; 
  char c,d;

  while(string_pos<strlen(string))
  {
    c=string[string_pos];
    d=string[string_pos+1];

    if       (c==' ' && d==' '){}
    else if  (c==' ' && d==','){}
    else if  (c==',' && d==' '){}
    else if  (c==' ' && d>=33 && d<=126){}
    else if  (c==',' && d>=33 && d<=126){}
    else 
      {
      argv[argv_pos++]=c;
      argv[argv_pos]=0;          

      if(d==' ' || d==',' || d==0)
        {
        argv[argv_pos]=0;
        argc_pos++;

        if(argc_pos==argc)
          {
          return true;
          }
          
        argv[0]=0;
        argv_pos=0;
        string_pos++;
      }
    }
    string_pos++;
  }
  return false;
}

unsigned long str2int(char *string)
{
  return(strtol(string,NULL,0));  
}

