/*
 * helloworld.asm
 * Written for use with GNU AS

 * Copyright © 2020 Ben Sampson <github.com/billyrayvalentine>
 * This work is free. You can redistribute it and/or modify it under the
 * terms of the Do What The Fuck You Want To Public License, Version 2,
 * as published by Sam Hocevar. See the COPYING file for more details.
*/

* Everything kicks off here.  Must be at 0x200
.include "rom_header.asm"

cpu_entrypoint:
    * Setup the TMSS stuff
    jsr     tmss

    * Setup the VDP registers
    jsr     init_vdp

    * All the commands to send to the control port can be worked out using the
    * example in the README

    * Load the palette into CRAM
    move.l  #0xC0000000, VDP_CTRL_PORT

    lea     Palette0, a0
    moveq   #16-1, d0

1:  move.w  (a0)+, VDP_DATA_PORT
    dbra    d0, 1b

    * Load (tiles)
    * Skip the first 32 bytes of VRAM so we have a blank tile
    move.l  #0x40200000, VDP_CTRL_PORT

    * Load the bar tiles
    lea     TilesBar, a0
    moveq   #8-1, d0

1:  move.l  (a0)+, VDP_DATA_PORT
    dbra    d0, 1b


/*
 *  Initialise the RAM with the sprite values in a loop
 *  Set the initial X,Y,SUBPIXEL and SPEED
 *  d0 = sprite / loop counter
 *  d1 = X position counter
 *  a0 points to start of sprite table in RAM
 *  a1 points to start of sprite speed values in ROM
*/
    move.w  #SPRITE_TOTAL_NUMBER -1, d0
    lea     RAM_SPRITE_TABLE_START, a0
    lea     SpriteSpeeds, a1
    * X position
    move.w  #128, d1

    * Set Y position
1:  move.w  d1,    (a0)+
    * Set X position
    move.w  #128,  (a0)+
    * Set subpixel
    move.w  #0,    (a0)+
    * Set speed
    move.l  (a1)+, (a0)+

   * Increment X position
    addi.w  #16,   d1
    dbra    d0,     1b

/*
 * Main loop
 * Wait for the VBLANK to start
 * Move the sprite
 * Wait for the VBLANK to end
 *
*/
forever:
    jsr wait_vblank_start

/*
 * For each sprite:
 * Check the Y position is in the screen and reset to 0 if not
 * Add the sprite speed to the subpixel count
 * Calculate the Y position from the subpixel count
 * d0 = sprite / loop counter
 * d1 = temporary store to manipulate subpixel
 * a0 points to start of sprite table in RAM
*/
    move.w  #SPRITE_TOTAL_NUMBER -1, d0
    lea     RAM_SPRITE_TABLE_START, a0

    * Check sprite Y position is still inside screen or reset to 0
1:  cmpi.w  #SCREEN_SIZE_Y + 128 + 8, (a0, ST_Y_OFFSET)
    bls.w   2f
    move.w  #0 + 128, (a0, ST_Y_OFFSET)

    * Update the subpixel count
    * add speed to subpixel using d1
2:  clr.l   d1
    move.w  (a0, ST_SUB_PIXEL_OFFSET), d1
    add.l   (a0, ST_SPEED_OFFSET), d1
    * Move the updated mantissa (subpixel) back to RAM
    move.w  d1, (a0, ST_SUB_PIXEL_OFFSET)
    * Swap the MSB (integer value of pixels to move) to the LSB
    * and update the Y position
    swap    d1
    add.w   d1, (a0, ST_Y_OFFSET)
    * Move sprite table pointer to next row
    lea     (a0, ST_ROW_SIZE), a0
    dbra    d0, 1b

    jsr update_sprite_table
    jsr wait_vblank_end
    jmp forever

update_sprite_table:
/*
 * This should use DMA in the future
 * NOTE: This will go bang if there are less than 2 sprites
 *
 * Iterate the sprite table RAM and update the X, Y and sprite index
 * d0 = sprite / loop counter also will be the sprite index
 * d1 = loop counter
 * a0 points to second entry of sprite table in RAM
 * Add entries with ascending sprite link index stating with 1
 * this seems to be q requirement?
 * Last entry must have index 0
*/
    * Update sprite table
    clr     d0
    move.w  #1, d1
    move.w  #SPRITE_TOTAL_NUMBER, d0
    lea     RAM_SPRITE_TABLE_START, a0
    move.l  #0x68000002, VDP_CTRL_PORT

1:  move.w  (a0, ST_Y_OFFSET), VDP_DATA_PORT
    move.w  d1, VDP_DATA_PORT
    move.w  #1, VDP_DATA_PORT
    move.w  (a0, ST_X_OFFSET), VDP_DATA_PORT

    addq    #1, d1
    lea     (a0, ST_ROW_SIZE), a0
    cmpi.w  #SPRITE_TOTAL_NUMBER, d1
    bne     1b

    * Add the last sprite in the table but set the sprite index to 0
    move.w  (a0, ST_Y_OFFSET), VDP_DATA_PORT
    move.w  #0, VDP_DATA_PORT
    move.w  #1, VDP_DATA_PORT
    move.w  (a0, ST_X_OFFSET), VDP_DATA_PORT

    rts

wait_vblank_start:
    * Bit 4 of the VDP register is set to 1 when the vblanking is in progress
    * Keep looping until this is set
    * The VDP register can be read simply by reading from the control port
    * address
    move.w  VDP_CTRL_PORT, d0
    btst.b  #4-1, d0
    beq     wait_vblank_start
    rts

wait_vblank_end:
    * Similar to wait_vblank_start but the inverse
    move.w  VDP_CTRL_PORT, d0
    btst.b  #4-1, d0
    bne     wait_vblank_end
    rts

.include "globals.asm"
.include "init_vdp.asm"
.include "tmss.asm"
.include "palletes.asm"

/*
 * Interrupt handler
*/
cpu_exception:
    rte
int_null:
    rte
int_hinterrupt:
    rte
int_vinterrupt:
    rte
rom_end:
