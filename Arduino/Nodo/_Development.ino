
/**************************************************************************************************************************\

Aanpassingen t.o.v. laatste build:
- Issue 543: Small: Tellen van pulsen werkt niet correct
- Issue 549: Output commando's bundelen ==>> LET OP: Hiervoor aanpassing van de WebApp nodig.
- Issue 548: Onbekend UserEvent laat Small stoppen met scannen.
- Issue 541: WaitFreeRF nodig? Default "on"?
- Issue 542: Versie van een Small niet via RF te achterhalen
- Issue 534: Meer defensieve verwerking van de RTC data via de I2C bus
- Aanpassing formules voor pulsen.
- PullUp voor IR_RX_DATA lijn 
 
Aanpassingen t.o.v. Final Beta Build 436:
- Issue 549: Output commando's bundelen ==>> LET OP: Hiervoor aanpassing van de WebApp nodig.
- Issue 548: Onbekend UserEvent laat Small stoppen met scannen.
- Issue 541: WaitFreeRF nodig? Default "on"?
- Issue 542: Versie van een Small niet via RF te achterhalen
- Issue 534: Meer defensieve verwerking van de RTC data via de I2C bus
- Aanpassing formules voor pulsen.
- PullUp voor IR_RX_DATA lijn 
- Issue 543: Small: Tellen van pulsen werkt niet correct
- Issue 538: Logging naar LOG.DAT is voor veel genruikers onnodig omdat de WebApp hier ook in voorziet
- Issue 539: EventGhost APOP protocol verwijderen uit de Nodo
- Issue 537: in arduino-nodo: Headers niet consequent bij verzenden/ontvangen
- Issue 535: Status via een HTTP-request leidt niet tot een event.
- Issue 505: Overvloedige error message.
- Issue 443: Break on tijd.
- Issue 486: Extra entry point voor UserPlugin

Known Errors / ToDo:
- SendBusy op de Master zet de slaves tijdelijk op onbereikbaar. Hierdoor werkt SendTo niet
- In geval van onbereikbare Nodo-Small: Hoe resetten?
- Status All uitvraag bij een Small levert: [Input=File, Unit=15, Event=Debug] Geen geldig event
- Vreemde weergave events: Internal=System


\**************************************************************************************************************************/

