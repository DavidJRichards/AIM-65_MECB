.segment "CODE"
.ifdef EATER
;MECB_VIA_BASE defined in bios.s
PORTB = MECB_VIA_BASE + 0
DDRB  = MECB_VIA_BASE + 2
E  = %01000000
RW = %00100000
RS = %00010000
;RES = %000010000

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

LCDINIT:
  lda #$ff ; Set all pins on port B to output
  sta DDRB

  lda #%00000011 ; Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  lda #%00000011 ; Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  lda #%00000011 ; Set 8-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  ; Okay, now we're really in 8-bit mode.
  ; Command to get to 4-bit mode ought to work now
  lda #%00000010 ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  rts

hello:
  ldx #0
print:
  lda message,x
  beq loop
  jsr lcd_print_char
  inx
  jmp print
loop:
  rts

message: .asciiz "Hello, world!"
;message: defm "Hello, world!"
;    BRK

;-------------------------------------------------------------------------------


  rts


LCDCMD:
  jsr GETBYT
  txa
lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

LCDPRINT:
  jsr FRMEVL
  bit VALTYP
  bmi lcd_print
  jsr FOUT
  jsr STRLIT
lcd_print:
  jsr FREFAC
  tax
  ldy #0
lcd_print_loop:
  lda (INDEX),y
  jsr lcd_print_char
  iny
  dex
  bne lcd_print_loop
  rts

lcd_print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts

.endif
