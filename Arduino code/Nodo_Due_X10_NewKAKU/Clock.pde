#define offset 60
 
boolean CheckDaylight()
  {
  // Tabel Sunset & Sunrise: om de 10 dagen de tijden van zonsopkomst en zonsondergang in minuten na middernacht. 
  // Geldig voor in Nederland (gemiddelde voor midden Nederland op 52.00 graden NB en 5.00 graden OL) 
  // Eerste dag is 01 januari, tweede is 10, januari, derde is 20 januari, etc.
  // tussenliggende dagen worden berekend aan de hand van lineaire interpolatie tussen de tabelwaarden. 
  // Afwijking t.o.v. KNMI-tabel is +/-1 min.
  // met de offset kan worden getoetst op uren +/- de momenten. +60 levert dus een uur na zonsondergang een event.
  
  int DOY,index,now,up,down;
  int u0,u1,d0,d1;
  
  DOY=((Time.Month-1)*304)/10+Time.Date;// schrikkeljaar berekening niet nodig, levert slecht naukeurigheidsafwijking van één minuut
  index=(DOY/10);
  now=Time.Hour*60+Time.Minutes;

  //zomertijd correctie
  if(S.DaylightSaving)
    {
    if(now>=60)now-=60;
    else now=now+1440-60;
    }
    
  u0=pgm_read_word_near(Sunrise+index);
  u1=pgm_read_word_near(Sunrise+index+1);
  d0=pgm_read_word_near(Sunset+index);
  d1=pgm_read_word_near(Sunset+index+1);

  up  =u0+((u1-u0)*(DOY%10))/10;// Zon op in minuten na middernacht
  down=d0+((d1-d0)*(DOY%10))/10;// Zon onder in minuten na middernacht

  Time.Daylight=0;                        // na middernacht 
  if(now>=(up-offset))   Time.Daylight=1; // <offset> minuten voor zonsopkomst 
  if(now>=up)            Time.Daylight=2; // zonsopkomst
  if(now>=(down-offset)) Time.Daylight=3; // <offset> minuten voor zonsondergang
  if(now>=down)          Time.Daylight=4; // zonsondergang
  }

#define DS1307_SEC       0
#define DS1307_MIN       1
#define DS1307_HR        2
#define DS1307_DOW       3
#define DS1307_DATE      4
#define DS1307_MTH       5
#define DS1307_YR        6
#define DS1307_BASE_YR   2000

#define DS1307_CTRL_ID   B1101000  //DS1307
#define DS1307_CLOCKHALT B10000000
#define DS1307_LO_BCD    B00001111
#define DS1307_HI_BCD    B11110000
#define DS1307_HI_SEC    B01110000
#define DS1307_HI_MIN    B01110000
#define DS1307_HI_HR     B00110000
#define DS1307_LO_DOW    B00000111
#define DS1307_HI_DATE   B00110000
#define DS1307_HI_MTH    B00110000
#define DS1307_HI_YR     B11110000

int rtc[7];

/**********************************************************************************************\
 * 
 * Revision 01, 09-01-2010, P.K.Tonkes@gmail.com
 \*********************************************************************************************/
void ClockSet(void) 
  {
  Time.Day=dow(Time.Year,Time.Month,Time.Date)+1;// Day wordt berekend. 1=zondag.
  rtc[DS1307_SEC]=DS1307_CLOCKHALT;  // Stop the clock. Set the ClockHalt bit high to stop the rtc. This bit is part of the seconds byte
  DS1307_save();
  rtc[DS1307_MIN]=((Time.Minutes/10)<<4)+(Time.Minutes%10);
  rtc[DS1307_HR]=((Time.Hour/10)<<4)+(Time.Hour%10);
  rtc[DS1307_DOW]=Time.Day;
  rtc[DS1307_DATE]=((Time.Date/10)<<4)+(Time.Date%10);
  rtc[DS1307_MTH]=((Time.Month/10)<<4)+(Time.Month%10);
  rtc[DS1307_YR]=(((Time.Year-DS1307_BASE_YR)/10)<<4)+(Time.Year%10);
  rtc[DS1307_SEC]=((Time.Seconds/10)<<4)+(Time.Seconds% 10); // and start the clock again...
  DS1307_save();
  }

/**********************************************************************************************\
 * Leest de reltime clock en plaatst actuele waarden in de struct Time. 
 * Eveneens wordt de Event code terug gegevens
 * Revision 01, 09-01-2010, P.K.Tonkes@gmail.com
 \*********************************************************************************************/

unsigned long SimulateDay(byte days) 
  {
  unsigned long SimulatedClockEvent, Event, Action;
  byte x;
  
  Time.Seconds=0;
  Time.Minutes=0;
  Time.Hour=0;
  
  Serial.print(Text(Text_21));PrintTerm();
  for(int d=1;d<=days;d++)
    {
    for(int m=0;m<=1439;m++)  // loop alle minuten van één etmaal door
      {
      if(Time.Minutes==60){Time.Minutes=0;Time.Hour++;}
      if(Time.Hour==24)
        {
        Time.Hour=0;
        Time.Day++;
        Serial.print(Text(Text_21));PrintTerm();
        }
      if(Time.Day==8)Time.Day=1;
  
      SimulatedClockEvent=command2event(CMD_CLOCK_EVENT_ALL+Time.Day,Time.Hour,Time.Minutes); 
      if(x=CheckEventlist(SimulatedClockEvent));

      CheckDaylight();
      if(Time.Daylight!=DaylightPrevious)// er heeft een zonsondergang of zonsopkomst wisseling voorgedaan
        {
        SimulatedClockEvent=command2event(CMD_CLOCK_EVENT_DAYLIGHT,Time.Daylight,0L);
        x=true;
        DaylightPrevious=Time.Daylight;
        }

      if(x)
        {
        PrintEvent(DIRECTION_INTERNAL,CMD_SOURCE_CLOCK,EventType(SimulatedClockEvent),SimulatedClockEvent);

        Serial.print(Text(Text_07));
        Serial.print("Day ");
        PrintCode(Time.Day);
        Serial.print(", ");      
        if(Time.Hour<10)Serial.print("0");
        PrintCode(Time.Hour);
        Serial.print(":");
        if(Time.Minutes<10)Serial.print("0");
        PrintCode(Time.Minutes);

        PrintTerm();
        ExecuteEventlist(SimulatedClockEvent,CMD_SOURCE_CLOCK,EventType(SimulatedClockEvent),0,0,0);
        }
      Time.Minutes++;
      x=false;
      }
    }
  Serial.print(Text(Text_21));PrintTerm();
  ClockRead();// klok weer op de juiste tijd zetten.
  CheckDaylight();// dagligt status weer terug op de juiste stand zetten
  DaylightPrevious=Time.Daylight;
  }

/**********************************************************************************************\
 * Leest de reltime clock en plaatst actuele waarden in de struct Time. 
 * Eveneens wordt de Event code terug gegeven
 * Revision 01, 09-01-2010, P.K.Tonkes@gmail.com
 \*********************************************************************************************/

unsigned long ClockRead(void)   // Aquire data from buffer and convert to int, refresh buffer if required
  {
  byte i=0;
  DS1307_read();
  Time.Seconds=(10*((rtc[DS1307_SEC] & DS1307_HI_SEC)>>4))+(rtc[DS1307_SEC] & DS1307_LO_BCD);
  Time.Minutes=(10*((rtc[DS1307_MIN] & DS1307_HI_MIN)>>4))+(rtc[DS1307_MIN] & DS1307_LO_BCD);
  Time.Hour=(10*((rtc[DS1307_HR] & DS1307_HI_HR)>>4))+(rtc[DS1307_HR] & DS1307_LO_BCD);
  Time.Day=rtc[DS1307_DOW] & DS1307_LO_DOW;
  Time.Date=(10*((rtc[DS1307_DATE] & DS1307_HI_DATE)>>4))+(rtc[DS1307_DATE] & DS1307_LO_BCD);
  Time.Month=(10*((rtc[DS1307_MTH] & DS1307_HI_MTH)>>4))+(rtc[DS1307_MTH] & DS1307_LO_BCD);
  Time.Year=(10*((rtc[DS1307_YR] & DS1307_HI_YR)>>4))+(rtc[DS1307_YR] & DS1307_LO_BCD)+DS1307_BASE_YR;
  
  return ((unsigned long)(S.Home))<<28 |
         ((unsigned long)(S.Unit))<<24 | 
         ((unsigned long)(CMD_CLOCK_EVENT_ALL+Time.Day))<<16 | 
         ((unsigned long)(Time.Hour))<<8 | 
         ((unsigned long)(Time.Minutes));
  }

// update the data on the IC from the bcd formatted data in the buffer
void DS1307_save(void)
  {
  Wire.beginTransmission(DS1307_CTRL_ID);
  Wire.send(0x00); // reset register pointer
  for(byte i=0; i<7; i++)Wire.send(rtc[i]);
  Wire.endTransmission();
  }

// Aquire data from the RTC chip in BCD format, refresh the buffer
void DS1307_read(void)
  {
  Wire.beginTransmission(DS1307_CTRL_ID);  // reset the register pointer to zero
  Wire.send(0x00);
  Wire.endTransmission();
  Wire.requestFrom(DS1307_CTRL_ID, 7);  // request the 7 bytes of data    (secs, min, hr, dow, date. mth, yr)
  for(byte i=0; i<7; i++)rtc[i]=Wire.receive();// store data in raw bcd format
  }
  
/**********************************************************************************************\
 * Berekent de dag van de week. Zondag=1 (Doomsday methode)
 * Revision 01, 13-02-2010, P.K.Tonkes@gmail.com
 \*********************************************************************************************/
 byte dow(int yyyy, byte mm, byte dd)
    {
    int days;
  
    days=((yyyy-1)*365+(yyyy-1)/4-(yyyy-1)/100+(yyyy-1)/400)%7;/* Calculate the day for Dec 31 of the previous year */
    switch(mm)
      {
      case 12:dd += 30;
      case 11:dd += 31;
      case 10:dd += 30;
      case 9:dd += 31;
      case 8:dd += 31;
      case 7:dd += 30;
      case 6:dd += 31;
      case 5:dd += 30;
      case 4:dd += 31;
      case 3:dd += 28;
      case 2:dd += 31;
      }
    if ((!(yyyy%4)&&(yyyy%100)||!(yyyy%400))&&mm>2)days++; // dag erbij als schrikkeljaar en datum na feb.
    days = (dd+days)%7;
    return days;
    }
