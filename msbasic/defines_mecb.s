; configuration
CONFIG_2A := 1

CONFIG_NULL := 1
CONFIG_PRINT_CR := 1 ; print CR when line end reached
CONFIG_SAFE_NAMENOTFOUND := 1
CONFIG_SCRTCH_ORDER := 1
CONFIG_PEEK_SAVE_LINNUM := 1
CONFIG_SMALL_ERROR := 1

; zero page
ZP_START1 = $00
ZP_START2 = $10
ZP_START3 = $06
ZP_START4 = $5E

;extra ZP variables
USR             := $03
TXPSV		:= LASTOP

NULL            := IQERR

; inputbuffer
INPUTBUFFER     := $0016

;extra stack
STACK2          := $0200

; constants
STACK_TOP		:= $FD
SPACE_FOR_GOSUB         := $44
NULL_MAX		:= $F2
CRLF_1                  := CR
CRLF_2                  := LF
WIDTH			:= 20
WIDTH2			:= 10

; memory layout, start of BASIC program storage
;RAMSTART2	:= $0211
RAMSTART2 := $0400

MECBIO          = $A400

MECB_ACIA_BASE  = MECBIO+$D8
;  
ACIA_DATA       = MECB_ACIA_BASE+0
ACIA_STATUS     = MECB_ACIA_BASE+1
ACIA_CMD        = MECB_ACIA_BASE+2
ACIA_CTRL       = MECB_ACIA_BASE+3

MECB_VIA_BASE   = MECBIO+$B0 
;
PORTA           = MECB_VIA_BASE+0
UDRAH           = MECB_VIA_BASE+1
DDRA            = MECB_VIA_BASE+2
UPCR            = MECB_VIA_BASE+12
UIFR            = MECB_VIA_BASE+13


;monitor memory
UIN     := $108
UOUT    := $10A
KEYF1   := $10C
KEYF2   := $10F
;KEYF3

; monitor functions
AIM65_RAM_BASE := MECBIO
IRQV4  := AIM65_RAM_BASE+$0
NMIV2  := AIM65_RAM_BASE+$2
DILINK := AIM65_RAM_BASE+$06
PRIFLG := AIM65_RAM_BASE+$11
INFLG  := AIM65_RAM_BASE+$12
OUTFLG := AIM65_RAM_BASE+$13

AIM65_VIA_BASE := MECBIO+$E0
; used for keyboard break test
DRA2   := AIM65_VIA_BASE+$0
DRB2   := AIM65_VIA_BASE+$2

WSMON  := $E0ED ; PUT INTO NMI VECTOR
COMIN  := $E1A1 ; back to monitor
DU13   := $E520
PSLS   := $E7DC
LOAD   := $E848
WHEREO := $E871
OUTPUT := $E97A
INALL  := $E993
OUTALL := $E9BC
CRCK   := $EA24
GETKEY := $EC40
GETKY  := $EC43
ROONEK := $ECEF
OUTDIS := $EF05

CUREAD := $FE83
