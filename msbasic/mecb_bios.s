.setcpu "65C02"
.debuginfo

;HS_PORT := UPCR ;C03C
;HS_ON   := $E0 ; 1
;HS_OFF  := $CF ; 0

HS_PORT := ACIA_CMD ;C0EA
HS_ON   := $09 ; 1 ; OR MASK
HS_OFF  := $F3 ; 0 ; AND MASK

.zeropage
;                .org ZP_START0
                .org $EC
READ_PTR:       .res 1
WRITE_PTR:      .res 1

		.segment "FILLER"
FILLER_START:

.segment "SERIAL_INPUT_BUFFER"
SER_IP_BUF:   .res $100

.segment "BIOS"
; MAIN ENTRY AT $A000, CALL AT STARTUP, EXITS BY MONITOR WARM START WITH INTERRUPTS ENABLED
GO1:    jsr     BIOS_INIT
        nop
        JMP     COMIN ;WSMON  ;  try COMIN here instead
        nop      

BIOS_INIT:
        jsr     AIM_SETUP
        nop
        JSR     PS2KB_INIT
        nop
        jsr     SER_INIT
        nop
        jsr     LCD_INIT
        nop
        jsr     CRT_INIT
;    nop
;    nop
;    nop
        nop
        jsr     CALL_F2
        nop
        jsr     CALL_F3
        rts
        jsr     PS2KB_Loop
        brk
        
GO3:    JSR     CRT_INIT
        NOP
        JMP     COMIN
        NOP

TABLE  := $035A
TABLOW := $0363
TABHGH := $0364

CRT_TAB: BRK
        LDA     #4
        STA     TABLE
        LDA     #<MYTAB
        STA     TABLOW
        LDA     #>MYTAB
        STA     TABHGH
        JSR     $9906        
        LDA     #2
        STA     $357        
        LDA     #48
        STA     $35E
        RTS
        
MYTAB:  ;     25x80-60Hz  22x72-50Hz 
        .BYTE   108     ; 108 ; 1, Horizontal total (96?)
        .BYTE    72;80     ;  72 ; 2, Horizontal displayed
        .BYTE    85;89     ;  85 ; 3, Horizontal sync position
        .BYTE   $59     ; $59 ; 4, Horizontal and vertical Sync widths
        
        .BYTE    31     ;  26 ; 5, Vertical total rows
        .BYTE     2     ;   2 ; 6, Vertical total adjust  
        .BYTE    25     ;  22 ; 7, Vertical displayed
        .BYTE    28     ;  24 ; 8, Verical sync position 
        
        .BYTE    72;80     ;  72 ; 9, same as 2
        .BYTE    25     ;  22 ;10, same as 7  
        .BYTE   $07     ; $06 ;11, Total characters msb
        .BYTE   $D0     ; $30 ;12, Total characters lsb

                 

CRT_INIT:
        LDA     $9900   ; TEST CRT ROM JSR INSTRUCTION
        CMP     #$20
        BNE     NOGO    ; EXIT IF NOT FOUND
        LDA     #1
        STA     $35A
        LDA     #2
        STA     $357
        LDA     #48
        STA     $35E
        JSR     $9906
NOGO:   RTS

SER_INIT:
        CLD                     ; Clear decimal arithmetic mode.
        JSR     SER_INIT_BUFFER
        lda     #<IRQ_HANDLER
        sta     IRQV4
        lda     #>IRQ_HANDLER
        sta     IRQV4+1
        
        lda     #<OUTTST
        sta     UOUT
        lda     #>OUTTST
        sta     UOUT+1
        
        lda     #$1E            ; 9600/8/1
        sta     ACIA_STATUS     ; acia reset
        STA     ACIA_CTRL
        LDY     #$09            ; No parity, no echo, rx interrupts.
        STY     ACIA_CMD

;        lda     ACIA_STATUS
;        lda     ACIA_DATA
 
        rts



AIM_SETUP:
                LDX #0                  ; SETUP FUNCTION KEYS, copy jump instructions TO SWITCH OUTPUT ON AND OFF
fnlp:           LDA fntab,X
                STA KEYF1,X
                INX
                CPX #9                  ; THREE ENTRIES IN JUMP TABLE
                BCC fnlp                
                rts    
fntab:          jmp     CALL_F1         ; SIX BYTES DATA FOR COPY ABOVE
                jmp     CALL_F2
                jmp     CALL_F3


PS2KB_INIT:     
               lda      #0              ; Set all pins on port A to INPUT
               sta      DDRA
               lda      #$C8            ; CA1/2 KEYBOARD HANDSHAKE & CB1 LED OFF
               sta      UPCR            ; Via1PCR
               lda	UDRAH           ; Via1PRA 
               rts                      ; done
               
PS2KB_Scan:
                lda     UIFR            ; LOAD STATUS REGISTER
                lsr     A
                lsr     A
                BCC     kcirtn          ; RETURN IF NOTHING
                LDA     UDRAH           ; LOAD DATA BYTE
kcirtn:         RTS                     ; RETURN TO CALLER

PS2KB_Input:
                JSR     PS2KB_Scan
                BCC     PS2KB_Input
                RTS

PS2KB_Loop:
;                jsr     ACIA_Input
                jsr     PS2KB_Scan
                bcc     PS2KB_Loop                                
;                JSR     ACIA_Output
lp0:            cmp     #$0a
                bne     lp1
                jsr     linefeed_sent
                bra     PS2KB_Loop
lp1:
                cmp     #$0D           ; enter - go to second line
                bne     lp2
                jsr     enter_pressed
                bra     PS2KB_Loop
lp2:
                cmp     #$c           ; ^L - clear display
                bne     lp3
                jsr     esc_pressed
                bra     PS2KB_Loop
lp3:  
                cmp     #$3           ; ^C - exit
                bne     lp4
                rts
lp4:            pha
                jsr     lcd_print_char
                pla
plnxt:          bra     PS2KB_Loop

enter_pressed:
    lda #%11000000 ; 2ND LINE
    jsr lcd_instruction
    clc
    rts

linefeed_sent:
    lda #%10000000 ; 1ST LINE
    jsr lcd_instruction
    clc
    rts

esc_pressed:
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  clc
  rts



;********************************************************************************
;This is the SEND_CHAR subroutine to serialize a character on Accu.
;so ROUTES the character to serialize function before display it.
;********************************************************************************

;SEND_CHAR:      PHA                     ; Character to serialize come on Accu.
;                LDA #$10
;TRY_AGAIN:      BIT $6001               ; check bit 4 ACIA1 Status Reg (ACIA1_SR)
;                BEQ TRY_AGAIN           ; wait until ACIA1 Data Reg Empty (BEQ TRY_AGAIN)
;                PLA                     ; restore the character from stack
;                STA $6000               ; put the char. on ACIA1 Data Reg to serialize it (ACIA1_DR)
;END_SEND:       RTS                     ; end of SEND_CHAR function subroutine.

;*********************************************************************************
;Setting <M> = 010C 4C 00 04,  the F1 AIM-65 Function key call  subr
;to change the DILINK address pointed for DILINK from $EF05 to $040B
;**********************************************************************************

CALL_F1:        JSR $9964
                RTS

CALL_F2:        LDA #<DISP_ECHO
                STA DILINK               ; DILINK LOW BYTE
                LDA #>DISP_ECHO
                STA DILINK+1             ; DILINK HIGH BYTE
                lda     #HS_ON                    ; set 1
                ora     HS_PORT
                sta     HS_PORT
                RTS

CALL_F3:                                ; SETUP USER DFINED INPUT DEVICE 'U'
                LDA #<ACIA2_Input
                STA UIN
                LDA #>ACIA2_Input
                STA UIN+1
                
                lda #$55
                sta INFLG
                
                LDA #<WSMON ;$ED                ; CHANGE NIM VECTOR TO WARM START, ALSO FORCES RESET TO COLD START
                STA NMIV2
                LDA #>WSMON ;$E0               
                STA NMIV2+1
                
                lda     #HS_ON                    ; set 1
                ora     HS_PORT
                sta     HS_PORT

;                lda     ACIA_DATA       ; CLEAR INTERRUPT FLAG
                cli                     ; ENABLE INTERRUPTS
                rts
                

;******************************************************************************
;Setting <M> = 010C 4C 00 04,  the F2 AIM-65 Function key call  subr
;to return the address pointed for DILINK to $EF05 
;*******************************************************************************

CALL_F4:        LDA #<OUTDIS    ; RESTORE NORMAL DISPLAY
                STA DILINK
                LDA #>OUTDIS
                STA DILINK+1
;                lda     #HS_OFF                    ; set 0
;                and     HS_PORT
;                sta     HS_PORT
                LDA #$20        ; RESTORE KEYBOARD INPUT
                STA INFLG
                RTS

;************************************************************************
;The Display routine on AIM-65,  JUMP to the new DILINK addr.
;so ROUTES the character to serial procedure before display it.
;************************************************************************
DISP_ECHO:      PHA                     ; Save Character to Stack

PREP_SEND:      PLA                     ; Restore Character from Stack
                PHA                     ; and save it 
                and     #$7f
                JSR ACIA_Output         ; Send the character to serial ACIA1 (Subroutine SEND_CHAR)
                PLA                     ; Restore Character from stack
                PHA                     ; and save it again
                CMP #$0D                ; Was a <CR> ?
                BEQ ADD_LF              ; Then add Line Feed
                CMP #$8D                ; Was a <CR> with MSB = 1?
                BEQ ADD_LF              ; Then add Line Feed
                JMP NOW_DISP            ; The character not needed to add  <LF>, so jump to NOW_DISP
ADD_LF:         LDA #$0A                ; Take a >LF> char 
                JSR ACIA_Output         ; and send it to serial ACIA1
NOW_DISP:       PLA                     ; Restore the character received with the function, on  Accu.
                JMP OUTDIS              ; Now Go to display the character on Accu. (JMP OUTDIS) , ending the serialize and display the character


                
                
;-------------------------------------------------------------------------------
; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register

ACIA1_Input:
               lda   ACIA_STATUS                ; Serial port status             
               and   #$08                       ; is recvr full
               beq   ACIA1_Input                ; no char to get
               Lda   ACIA_DATA                  ; get chr
                jsr     CHROUT                  ; echo
                SEC
               RTS                              ;

; INPUT CHARACTER FROM SERIAL BUFFER

ACIA2_Input:
                jsr     ACIA_Input
                bcc     ACIA2_Input
;                JSR     ACIA_Output
                rts


                
;
; Modifies: flags, A
;SERRDKEY:
ACIA_Input:
                phx
                jsr     BUFFER_SIZE
                beq     @no_keypressed
                jsr     READ_BUFFER
                jsr     CHROUT                  ; echo
                pha
                jsr     BUFFER_SIZE
                cmp     #$B0
                bcs     @mostly_full
                lda     #HS_ON                    ; set 1
                ora     HS_PORT
                sta     HS_PORT
@mostly_full:
                pla
                plx
                sec
                rts
@no_keypressed:
                plx
                clc
                rts


; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
;MONCOUT:
;SERCOUT:
OUTTST:         bcc     OTINIT
                pla     
                and     #$7f
CHROUT:
ACIA_Output:
                pha
                sta     ACIA_DATA
                lda     #$FF
@txdelay:       dec
                bne     @txdelay
                pla
OTINIT:         rts

; Initialize the circular input buffer
; Modifies: flags, A
SER_INIT_BUFFER:
                lda #0
                sta READ_PTR
                lda READ_PTR
                sta WRITE_PTR
;                lda #$01
;                sta DDRA
                lda     #HS_ON                    ; set 1
                ora     HS_PORT
                sta     HS_PORT
                rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
                ldx WRITE_PTR
                sta SER_IP_BUF,x
                inc WRITE_PTR
                rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
                ldx READ_PTR
                lda SER_IP_BUF,x
                inc READ_PTR
                rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
                lda WRITE_PTR
                sec
                sbc READ_PTR
                rts


; Interrupt request handler
IRQ_HANDLER:
                pha
                phx
                lda     ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda     ACIA_DATA
                jsr     WRITE_BUFFER
                jsr     BUFFER_SIZE
                cmp     #$F0
                bcc     @not_full
                lda #HS_OFF                        ; set 0
                and HS_PORT
                sta HS_PORT
@not_full:
                plx
                pla
                rti

;.include "wozmon.s"

;.segment "RESETVEC"
;                .word   $0F00           ; NMI vector
;                .word   COLD_START           ; NMI vector
;                .word   RESET           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector

