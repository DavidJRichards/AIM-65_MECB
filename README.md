# AIM-65_MECB
Recreation of AIM-65 using MECB boards with 6502 processor

![Overview](images/overview.jpg)

This project is a rework of sources to recreate an AIM-65 with some additional features though optionally retaining use of some original AIM-65 parts.

The memory map of the RAM is unchanged but the periheral devices have been re-worked to fit into the MECB 256 byte I/O space. This may change as I try to recreate a closer approximation to the actual AIM-65 memory map which will remove the need to patch codes to suit.

## The new I/O memory map

These macro definitions are used in the Basic and Monitor sources:
<br>

| Name           | Location      | Device        |Original Loc.      |
|----------------|---------------|---------------|-------------------|
|MECBIO          |= $A400        |               |                   |
|MECB_USER       |= MECBIO + $B0 | 6522          | $A000             |
|MECB_RAM        |= MECBIO + $00 | 6532          | $A400             |
|MECB_KEYBOARD   |= MECBIO + $E0 | 6532          | $A480             |
|MECB_VIA        |= MECBIO + $C0 | 6522          | $A800             |
|MECB_DISPLAY    |= MECBIO + $D0 | 6520          | $AC00             |
|MECB_ACIA       |= MECBIO + $D8 | 6551          | used in mecb_bios |
|MECB_SPARE      |= MECBIO + $A0 |               | not used          |

## RAM

<br>

| Name   | Begin| End |
|--------|------|-----|
| System | 0000 | 7FFF|
| Monitor| A400 | A47F|
| Video  | 9000 | 97FF|


## ROM software

<br>

| Name   | Begin| End |
|--------|------|-----|
| Monitor| E000 | FFFF|
| Basic  | B000 | CFFF|
| Bios   | A800 | AFFF|
| Display| 9900 | 9FFF|
| AH5050 | D000 | DFFF|

## Video display

* This is the Scott Baker AIM-65 version of the Rockwell design
[Video Dsiplay](https://github.com/sbelectronics/aim65/tree/master/display)

## Display

* 20x1 LED on AIM 6520
* 20x2 VFD on USER 6522

### Memory

|       |      |      |
|-------|------|------|
|VRAM   | 9000 | 97FF |
|IO     | 9800 | 98FF |
|ROM    | 9900 | 9FFF |
|CRTC   | 9800 | 987F |
|DISPEN | 9880 | 98FF |


## Keyboard

* AIM Keyboard on AIM  6532
* PS2 Keyboard on USER 6522 using ATtiny 261 BIOS
[ATtiny firmware](https://sbc.rictor.org/pckbavr.html)

## Serial port

* AIM Serial on AIM 6522
* ACIA Serial on 6551 UART

## Cassette interface

* Tapuino 

## Disk Interface

* AH5050 with SD2IEC

## SYSTEM 6522 Connector

<BR>

|  No. | Name | J1 |                  |
|------|------|----|------------------|
|  1   | +5v  | A  |                  |
|  2   | +5v  | A  |                  |
|  3   | PA0  |    | printer          |
|  4   | PA1  |    | printer          |
|  5   | PA2  |    | printer          |
|  6   | PA3  |    | printer          |
|  7   | PA4  |    | printer          |
|  8   | PA5  |    | printer          |
|  9   | PA6  |    | printer          |
|  10  | PA7  |    | printer          |
|  11  | CA1  |    | printer          |
|  12  | CA2  |    | Audio I/O Control|
|  13  | PB0  |    | printer          |
|  14  | PB1  |    | printer          |
|  15  | PB2  |    | TTY Serial Out   |
|  16  | PB3  |    | KB/TTY switch    |
|  17  | PB4  |    | Tape1 Motor      |
|  18  | PB5  |    | Tape2 Motor      |
|  19  | PB6  |    | TTY Serial In    |
|  20  | PB7  |    | Audio I/O Data   |
|  21  | CB1  |    | printer          |
|  22  | CB2  |    | printer          |
|  23  | Gnd  |  I |                  |
|  24  | Gnd  |  I |                  |

<BR>

## SYS-I/O USER 6522 Connector

<BR>

|  No. | Name| J1 |            |             |
|------|-----|----|------------|-------------|
|  1   | +5v |    |            |             |
|  2   | +5v |    |            |             |
|  3   | PA0 | 14 |            | Keyboard D0 |
|  4   | PA1 |  4 |            | Keyboard D1 |
|  5   | PA2 |  3 |            | Keyboard D2 |
|  6   | PA3 |  2 | AH_ATN     | Keyboard D3 |
|  7   | PA4 |  5 | AH_CLK_OUT | Keyboard D4 |
|  8   | PA5 |  6 | AH_DATA_OUT| Keyboard D5 |
|  9   | PA6 |  7 | AH_CLK_IN  | Keyboard D6 |
|  10  | PA7 |  8 | AH_DATA_IN | Keyboard D7 |
|  11  | CA1 | 20 | AH_SRQIN   | Keyboard Rdy|
|  12  | CA2 | 21 | AH_RESET   | Keyboard Ack|
|  13  | PB0 |  9 |            |
|  14  | PB1 | 10 |            |
|  15  | PB2 | 11 |            |
|  16  | PB3 | 12 |            |
|  17  | PB4 | 13 |            |
|  18  | PB5 | 16 |            |
|  19  | PB6 | 17 |            |
|  20  | PB7 | 15 |            |
|  21  | CB1 | 18 |            |
|  22  | CB2 | 19 |            |
|  23  | Gnd |    |            |
|  24  | Gnd |    |            |

<BR>

## 6845 Video Display table

<BR>

|                 |0 Custom|1 25x80-60|2 22x72-50|3 16x40-50|4 25x40-60|
|-----------------|--------|----------|----------|----------|----------|
| R0 H total chrs  | 108    | 108      | 108      |  54      |  54      |
| R1 H displayed   |  72    |  80      |  72      |  40      |  40      |
| R2 H sync pos    |  85    |  89      |  85      |  45      |  44      |
| R3 HV sync width | $59    | $59      | $59      | $55      | $55      |108
| R4 V total rows  |  31    |  31      |  26      |  26      |  31      |
| R5 V adjust      |   2    |   2      |   2      |   2      |   2      |
| R6 V displayed   |  25    |  25      |  22      |  16      |  25      |
| R7 V sync pos    |  28    |  28      |  24      |  21      |  28      |
||||||
| chars/row as R1  |  72    |  80      |  72      |  40      |  40      |
| rows as R6       |  25    |  25      |  22      |  16      |  25      |
|    H x V msb     | $07    | $07      | $06      | $02      | $03      |
|    H x V lsb     | $D0    | $D0      | $30      | $80      | $E8      |


## Ram DISPLAY memory locations

<BR>

| Address | Name | Size| Purpose               |
|----|-------|---|-----------------------------|
|0347|SCRMAX |2  |# CHARS/SCREEN               |
|0349|ROWMAX |1  |# OF ROWS                    |
|034A|COLMAX |1  |# OF COLUMNS                 |
|034B|END    |2  |DISPLAY END ADDRESS          |
|034D|DLE    |1  |PASS THRU NEXT CHAR FLAG     |
|034E|INCH   |1  |INSERT MODE FLAG             |
|034F|EFLG   |1  |ESC SEQUENCE FLAG            |
|0350|GRAPH  |1  |GRAPHICS MODE FLAG           |
|0351|INVERS |1  |INVERSE VIDEO FLAG           |
|0352|DISTARL|1  |DISPLAY START LSB            |
|0353|DISTARH|1  |DISPLAY START ADDRESS        |
|0354|YSAV   |1  |LOC TO SAVE Y-POS FOR (Y,Z)  |
|0355|XSAV   |1  |TEMPORARY X SAVE             |
|0356|ASAV   |1  |LOCATION TO SAVE COMMAND/DATA|
|0357|AIM65  |1  |FLAG TO DISTINGUISH AIM 65/S |
|0358|ROW    |1  |ROW COUNTER                  |
|0359|COL    |1  |COLUMN COUNTER               |
|035A|TABLE  |1  |0-3 TO CHOOSE STORED TABLE   |
|035B|CURP2  |1  |CRT DISPLAY POINTER          |
|035C|ECHO   |2  |ECHO ADDRESS FOR REFORMATTER |
|035E|CMAX   |1  |MAX ALLOWED COLUMN FOR CRT   |
|035F|PRFLG  |1  |COUNTER FOR AIM ON/OFF MSGS  |
|0360|XXX    |1  |SAVE/RESTORE X REG.          |
|0361|YYY    |1  |SAVE/RESTORE Y REG.          |
|0362|XX2    |1  |TEMPORARY SAVE X             |
|0363|XADDR  |2  |OWN TABLE ADDRESS            |
|0365|COL2   |1  |CURSOR POS COUNTER           |
|0366|DBUFF  |80 |BUFFER FOR INSERT/DELETE LINE|
|03B6|       |0  |                             |

<BR>

## Bios utilities

<BR>

### initialization

<BR>

Called manually at address $A000 or from patched monitor code as subroutine at $A808. A series of initailisation staps are performed

|           |    |                      ||
|-----------|----|----------------------||
| AIM_SETUP |A89A| function key bindings|
| PS2KB_INIT|A8B1| SYS/IO 6522 keyboard |
| SER_INIT  |A874| 6851 serial          |
| LCD_INIT  |AA44| SYS/IO VFD Display   |
| CRT_INIT  |A85A| 6845 board init      |
| CALL_F1   |A915| like press F1        |RESET DISPLAY / AH5050 Menu       |
| CALL_F2   |A919| like press F2        |RESET SERIAL - DISP_ECHO TO DILINK|
| CALL_F3   |A92C| like press F3        |setup 6551 for user input UIN     |
| CALL_F4   |A94F| like press F4!       |
| PS2KB_Loop|A8D0| Test KB/VFD          |
| DISP_ECHO |A95F| Output to 6851 RS232 |
| OUTDIS    |EF05| Output to AIM display|

<BR>

### I/O locations

<BR>

|      |    |                             |
|------|----|-----------------------------|
|DILINK|A406|                             |
|UIN   |0108|                             |
|INFLG |A412|SP,'U', etc                  |
|F1    |010C|                             |
|F2    |010F|                             |
|F3    |    |                             |
|TABLE |035A|parameter table, 1=50Hz,72x22|
|AIM65_|0357|2=enable AIM65 functions     |
|CMAX  |035E|72, max characters per line  |





