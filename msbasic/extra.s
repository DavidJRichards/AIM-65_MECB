.segment "EXTRA"

.ifdef KIM
.include "kim_extra.s"
.endif

.ifdef CONFIG_CBM1_PATCHES
.include "cbm1_patches.s"
.endif

.ifdef KBD
.include "kbd_extra.s"
.endif

.ifdef APPLE
.include "apple_extra.s"
.endif

.ifdef MICROTAN
.include "microtan_extra.s"
.endif

.ifdef AIM65
.include "aim65_extra.s"
.endif

.ifdef SYM1
        .byte   0,0,0
.endif

.ifdef EATER
.include "bios.s"
.endif

.ifdef MECB
.include "mecb_bios.s"
.include "mecb_lcd.s"
.endif

.ifdef DJRM
.include "djrm_bios.s"
.include "djrm_lcd.s"
.endif
