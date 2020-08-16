SpriteSpeeds:
    .long 0x00010019
    .long 0x0000DEAD
    .long 0x0000AF55
    .long 0x0000BF34
    .long 0x00011019
    .long 0x0000F6FF
    .long 0x0000FFD2
    .long 0x0001AADA
    .long 0x0000CF1B
    .long 0x0000FF59
    .long 0x0000BEAD
    .long 0x0000FFFF
    .long 0x00010000
    .long 0x0000AAC6
    .long 0x0000BABE
    .long 0x0000DAC4
    .long 0x0000FABE
    .long 0x0001BADD
    .long 0x0000BABE
    .long 0x0000FFFF

BarSprite:
    .word 0x0080
    .byte 0b0000 /* 1x1 */
    .byte 0x01
    .byte 0x00
    .byte 0x01
    .word 0x0080

Palette0:
    .word 0x0000
    .word 0x0481
    .word 0x00E0
    .word 0x0E00
    .word 0x0000
    .word 0x0EEE
    .word 0x00EE
    .word 0x008E
    .word 0x0E0E
    .word 0x0808
    .word 0x0444
    .word 0x0888
    .word 0x0EE0
    .word 0x000A
    .word 0x0600
    .word 0x0060

TilesBar:
    .long 0x11111111
    .long 0x11111111
    .long 0x22222222
    .long 0x22222222
    .long 0x22222222
    .long 0x22222222
    .long 0x11111111
    .long 0x11111111
