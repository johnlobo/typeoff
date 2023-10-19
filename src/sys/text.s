;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

.module text_manager

;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
.include "common.h.s"
.include "sys/util.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

aux_txt:: .ds 20


;;
;; Start of _CODE area
;; 
.area _CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sys_text_reset_aux_txt
;;  Resets the aux string buffer
;; Input:
;; Returns: 
;; Destroys:
;;  bc, hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_text_reset_aux_txt::
    ld b, #20
    ld hl, #aux_txt
_tr_loop:
    ld (hl), #0
    inc hl
    djnz _tr_loop
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; str_length
;;      Counts the number of characters of a string
;; Input:
;;  hl : address of the string
;; Returns: 
;;  a : number of characters
;; Destroys:
;;  a, b, hl
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_text_str_length::
    ld b, #0
str_length_loop:
    ld a, (hl)
    or a
    jr z, str_length_exit
    inc b
    inc hl
    jr str_length_loop
str_length_exit:
    ld a, b
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; str_copy
;;      Copy one string into another
;; Input:
;;  hl : address of the origin string
;;  de : address of the destination string
;; Returns: 
;;  Nothing
;; Destroys:
;;  a, b, hl
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_text_str_copy::
    ld (str_copy_savehl), hl    ;; [3] | Save HL before modifying them
    call sys_text_str_length
str_copy_savehl = .+1           ;; Constant to retrive HL value
    ld hl, #0000                ;; 0000 is a place holder for the original HL value
    ld b, #0                    ;; Store string length in BC
    ld c, a
    ldir                        ;; Copy from HL to DE
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; str_cmp
;;      Compare two strings
;; Input:
;;  hl : address of the string 1
;;  de : address of the string 2
;; Returns: 
;;  a : 1 if strings are the same
;;      0 in other case
;; Destroys:
;;  a, b, hl, de
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_text_str_cmp::
    ld a, (hl)
    or a
    jr z, str_cmp_check_last_pair
    push af
    ld a, (de)
    or a
    jr z, str_cmp_exit_false
    pop bc
    cp b
    jr nz, str_cmp_exit_false
    inc hl
    inc de
    jr sys_text_str_cmp 
str_cmp_check_last_pair:
    ld a, (de)
    or a
    jr nz, str_cmp_exit_false
str_cmp_exit_true:
    ld a, #1
    ret
str_cmp_exit_false:
    xor a
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; draw_char
;;      Draws a char in a video memory address
;; Input:
;;  hl : address of the char sprite
;;  de : video memory address
;;  a : color
;;  c : width of the sprite
;;  b : height of the sprite
;; Returns: 
;;  Nothing
;; Destroys:
;;  a, b, hl, de, ix
;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_text_draw_char::
    push de
    push bc
    push hl
    ;; color
    ld l, a
    sla a
    sla a       ;; multiply color by 5 to get correct color index
    add a, l
    ld hl, #_swapColors
    add_hl_a    ;; add a to hl (swapcolors)
    push hl 
    pop ix      ;; load hl data in ix
    ;; size
    ld h, c
    ld e, b
    call sys_util_h_times_e      ;; multiply c x b
    ld b, h            ;; load b with c x b
    ld c, l
    pop hl
    ld de, #_char_buffer
_loop:
    ld a, (hl)
    cp #0x55
    jr z, _first_byte
    cp #0xee
    jr z, _second_byte
    cp #0xdd
    jr z, _third_byte
    cp #0xff
    jr z, _forth_byte
    cp #0xaa
    jr z, _fifth_byte
    jr _continue
_first_byte:
    ld a, 0(ix)
    jr _modified_byte
_second_byte:
    ld a, 1(ix)
    jr _modified_byte
_third_byte:
    ld a, 2(ix)
    jr _modified_byte
_forth_byte:
    ld a, 3(ix)
    jr _modified_byte
_fifth_byte:
    ld a, 4(ix)
_modified_byte:

_continue:
    ld (de), a
    inc hl
    inc de
    dec c
    ld a,c
    or a
    jr nz, _loop
    pop bc
    pop de
    ld hl, #_char_buffer
    call cpct_drawSprite_asm
    ret
_color_ptr: .dw nullptr
_swapColors: 
    .db 0x55, 0xee, 0xdd, 0xff, 0xaa   ;; Bright White 
    .db 0x14, 0x6c, 0x9c, 0x3c, 0x28   ;; Bright Yellow
    .db 0x50, 0xe4, 0xd8, 0xf0, 0xa0   ;; Orange
    .db 0x11, 0x66, 0x99, 0x33, 0x22   ;; Blue
    .db 0x10, 0x35, 0x3a, 0x30, 0x20   ;; Bright Red
    .db 0x45, 0xce, 0xcd, 0xcf, 0x84   ;; Mauve
_char_buffer: .db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; draw_string
;;      Draws a string in a video memory address
;; Input:
;;  hl : address of the string
;;  de : video memory address
;;  c : color
;; Returns: 
;;  Nothing
;; Destroys:
;;  a, b, hl, de
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_text_draw_string::
    cpctm_push ix, iy
    ld a,c
    ld (_string_color),a            ;; store color in memory
draw_string_2:
    cpctm_push de, hl 
    ld a, (hl)                      ;; load a with the char to draw
    or a
    jr z, _draw_string_exit         ;; if char == 0 return
    cp #32                          ;; if char = " " go to next char
    jr z, _next_char                
    cp #33                          ;; exclamation sign
    jr z, _exclamation         
    cp #58                          ;; numbers
    jr c, _numbers
_rest_of_chars:    
    sub #44                         ;; chars from ? to Z
    jr _draw_char                   
_exclamation:
    ld a, #0
    jr _draw_char
_numbers:
    sub #39
_draw_char:
    push de
    ld h, #FONT_WIDTH               ;; copy FONT WIDTH in l
    ld e, #FONT_HEIGHT              ;; copy FONT HEIGHT in e
    call sys_util_h_times_e         ;; hl = WIDTH * HEIGHT
    ld e, a                         ;; copy char position in e
    ld h, l                         ;; copy WIDTH*HEIGHT in h
    call sys_util_h_times_e                  ;; hl = WIDTH * HEIGHT * char position
    ld de, #_s_font_0           ;; add the begining of the font set to the offset
    add hl, de                      ;; final address of the sprite to draw
    pop de                          ;; video memory address
    ld c, #FONT_WIDTH               ;; width of the char
    ld b, #FONT_HEIGHT              ;; height of the char
    ld a, (_string_color)
    call sys_text_draw_char
_next_char:
    pop hl
    inc hl
    pop de
    inc de
    inc de
    jr draw_string_2
_draw_string_exit:
    cpctm_pop hl, de, iy, ix
    ret
_string_color: .db 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sys_text_num2str8
;;  Converts an 8 bit number to a string
;; Input:
;;  hl : number to convert
;;  de : string address
;;  
;; Returns: 
;;  Nothing
;; Destroys:
;;  af, bc, hl, de
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_text_num2str8::
    ld	bc,#-100
	call _ns8_Num1
	ld	c,#-10
	call _ns8_Num1
	ld	c,b
_ns8_Num1:	
    ld	a,#('0'-1)
_ns8_Num2:
    inc	a
	add	hl,bc
	jr	c,_ns8_Num2
	sbc	hl,bc

	ld	(de),a
	inc	de
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sys_text_draw_small_char_number
;;  draws a two digit number with small characters
;; Input:
;;  a : number to draw
;;  de : screen address
;;  
;; Returns: 
;;  Nothing
;; Destroys:
;;  af, bc, hl, de
;;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_text_draw_small_char_number::
    push de                             ;; save de for later
    ld h, #10                           ;; calculate the offset from the first char
    ld e, a                             ;;
    call sys_util_h_times_e             ;; l = 20 * number
    ld b, #0                            ;;
    ld c, l                             ;;
    ld hl, #_s_small_numbers_00         ;; point hl to the start of the numbers
    add hl, bc                          ;; address of the number to show
    pop de                              ;; retreive de
    ld c, #S_SMALL_NUMBERS_WIDTH
    ld b, #S_SMALL_NUMBERS_HEIGHT
    call cpct_drawSprite_asm            ;; draw the number
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sys_text_draw_small_number
;;  draws a three digit number with small characters
;; Input:
;;  hl : number to convert
;;  de : screen address
;;  
;; Returns: 
;;  Nothing
;; Destroys:
;;  af, bc, hl, de
;;
;;  Routine adapted from WikiTI (https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sys_text_draw_small_number::
    ld a, l
    ld (_original_number), a
    ld	bc, #-100
    cp #100                      ;; check if number is lower than 100
    call nc,	_dsn_Num1
    ld bc, #-10
    ld a, (_original_number)
    cp #10                      ;; check if number is lower than 10
	call nc, _dsn_Num1           ;; if number is upper 9 then call
	ld	c,b
_dsn_Num1:	
    ld a, #-1                           
_dsn_Num2:
    inc	a
	add	hl,bc
	jr	c,_dsn_Num2
	sbc	hl,bc

    cpctm_push de, hl, bc
    call sys_text_draw_small_char_number
    cpctm_pop bc, hl, de

    inc de                      ;; go to the next screen address
    inc de                      ;;
    
    ret

_original_number: .db #0    
