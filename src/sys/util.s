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

.module sys_util

.include "../common.h.s"
;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


string_buffer:: .asciz "          "


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------;; 
;;  sys_util_h_times_e
;;
;; Inputs:
;;   H and E
;; Outputs:
;;   HL is the product
;;   D is 0
;;   A,E,B,C are preserved
;; 36 bytes
;; min: 190cc
;; max: 242cc
;; avg: 216cc
;; Credits:
;;  Z80Heaven (http://z80-heaven.wikidot.com/advanced-math#toc9)

sys_util_h_times_e::
  ld d,#0
  ld l,d
  sla h 
  jr nc,.+3 
  ld l,e
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  ret nc 
  add hl,de
  ret

;;-----------------------------------------------------------------;; 
;;  sys_util_hl_div_c
;;
;;Inputs:
;;     HL is the numerator
;;     C is the denominator
;;Outputs:
;;     A is the remainder
;;     B is 0
;;     C is not changed
;;     DE is not changed
;;     HL is the quotient
;;
sys_util_hl_div_c::
       ld b,#16
       xor a
         add hl,hl
         rla
         cp c
         jr c,.+4
           inc l
           sub c
         djnz .-7
       ret

;;-----------------------------------------------------------------
;;
;; sys_util_absHL
;;
;;  
;;  Input:  hl: number
;;  Output: hl: absolut value of number
;;  Destroyed: af
;;
;;  Cemetech code (https://learn.cemetech.net/index.php?title=Z80:Math_Routines#absHL)
;;
sys_util_absHL::
  bit #7,h
  ret z
  xor a
  sub l
  ld l,a
  sbc a,a
  sub h
  ld h,a
  ret

;;-----------------------------------------------------------------
;;
;; sys_util_BCD_GetEnd
;;
;;  
;;  Input:  b: number of bytes of the bcd number
;;          de: source for the first bcd bnumber
;;          hl: source for the second bcd number
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_GetEnd::
;Some of our commands need to start from the most significant byte
;This will shift HL and DE along b bytes
	push bc
	ld c,b	;We want to add BC, but we need to add one less than the number of bytes
	dec c
	ld b,#0
	add hl,bc
	ex de, hl	;We've done HL, but we also want to do DE
	add hl,bc
	ex de, hl
	pop bc
	ret

;;-----------------------------------------------------------------
;;
;; BCD_Add
;;
;;   Add two BCD numbers
;;  Input:  hl: Number to add to de
;;          de: Number to store the sum 
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_Add::
    or a
BCD_Add_Again:
    ld a, (de)
    adc (hl)
    daa
    ld (de), a
    inc de
    inc hl
    djnz BCD_Add_Again
    ret
  
;;-----------------------------------------------------------------
;;
;; sys_util_BCD_Compare
;;
;;  Compare two BCD numbers
;;  Input:  hl: BCD Number 1
;;          de: BCD Number 2
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_Compare::
  ld b, #SCORE_NUM_BYTES
  call sys_util_BCD_GetEnd
BCD_cp_direct:
  ld a, (de)
  cp (hl)
  ret c
  ret nz
  dec de
  dec hl
  djnz BCD_cp_direct
  or a                    ;; Clear carry
  ret

;;-----------------------------------------------------------------
;;
;; sys_util_get_random_number
;;
;;  Returns a random number between 0 and <end>
;;  Input:  a: <end>
;;  Output: a: random number
;;  Destroyed: af, bc,de, hl

sys_util_get_random_number::
  ld (#random_max_number), a
  call cpct_getRandom_mxor_u8_asm
  ld a, l                             ;; Calculates a pseudo modulus of max number
  ld h,#0                             ;; Load hl with the random number
random_max_number = .+1
  ld c, #0                            ;; Load c with the max number
  ld b, #0
_random_mod_loop:
  or a                                ;; ??
  sbc hl,bc                           ;; hl = hl - bc
  jp p, _random_mod_loop              ;; Jump back if hl > 0
  add hl,bc                           ;; Adds MAX_MODEL_CARD to hl back to get back to positive values
  ld a,l                              ;; loads the normalized random number in a
ret

;;-----------------------------------------------------------------
;;
;; sys_util_delay
;;
;;  Waits a determined number of frames 
;;  Input:  b: number of frames
;;  Output: 
;;  Destroyed: af, bc
;;
sys_util_delay::
  push bc
  call cpct_waitVSYNCStart_asm
  pop bc
  djnz sys_util_delay
  ret


;;-----------------------------------------------------------------
;;
;; sys_util_negHL
;;
;;  Negates hl
;;  input: hl
;;  ouput: hl negated
;;  destroys: a
;;
;; WikiTI code (https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Signed_Math)
sys_util_negHL::
	xor a
	sub l
	ld l,a
	sbc a,a
	sub h
	ld h,a
	ret

;;-----------------------------------------------------------------
;;
;; sys_util_hl_divided_d
;;
;;  Divides hl by d, and leaves the result in hl
;;  input:  hl: dividend
;;          d: divisor
;;  ouput:  hl: result
;;  destroys: af, de, bc, hl 
;;
;; code by Jonathan Cauldwell (https://chuntey.wordpress.com/category/z80-assembly/)
sys_util_hl_divided_d::
  ld b,#8              ; bits to check.
  ld a,d              ; number by which to divide.
idiv3:  
  rla                 ; check leftmost bit.
  jr c,idiv2          ; no more shifts required.
  inc b               ; extra shift needed.
  cp h
  jr nc,idiv2
  jp idiv3            ; repeat.

idiv2:  
  xor a
  ld e,a
  ld c,a              ; result.
idiv1:  
  sbc hl,de           ; do subtraction.
  jr nc,idiv0         ; no carry, keep the result.
  add hl,de           ; restore original value of hl.
idiv0: 
  ccf                 ; reverse carry bit.
  rl c                ; rotate in to ac.
  rla
  rr d                ; divide de by 2.
  rr e
  djnz idiv1          ; repeat.
  ld h,a              ; copy result to hl.
  ld l,c
  ret

;;-----------------------------------------------------------------
;;
;; sys_util_sqr_hl
;;
;;  Calculates de square root of hl in a
;;  fast 16 bit isqrt by John Metcalf
;;  92 bytes, 344-379 cycles (average 362)
;;  v2 - saved 3 cycles with a tweak suggested by Russ McNulty
;;  input: hl
;;  ouput: a
;;  destroys: de, hl 
;;
;; code by John Metcalf (https://github.com/impomatic/z80snippets/blob/master/fastisqr.asm)
sys_util_sqr_hl::

  ld a,h        ; 4
  ld de,#0x0B0C0  ; 10
  add a,e       ; 4
  jr c,sq7      ; 12 / 7
  ld a,h        ; 4
  ld d,#0x0F0     ; 7
sq7:

; ----------

  add a,d       ; 4
  jr nc,sq6     ; 12 / 7
  res 5,d       ; 8
  .db #254        ; 7
sq6:
  sub d         ; 4
  sra d         ; 8

; ----------

  set 2,d       ; 8
  add a,d       ; 4
  jr nc,sq5     ; 12 / 7
  res 3,d       ; 8
  .db #254        ; 7
sq5:
  sub d         ; 4
  sra d         ; 8

; ----------

  inc d         ; 4
  add a,d       ; 4
  jr nc,sq4     ; 12 / 7
  res 1,d       ; 8
  .db #254        ; 7
sq4:
  sub d         ; 4
  sra d         ; 8
  ld h,a        ; 4

; ----------

  add hl,de     ; 11
  jr nc,sq3     ; 12 / 7
  ld e,#0x040     ; 7
  .db #210        ; 10
sq3:
  sbc hl,de     ; 15
  sra d         ; 8
  ld a,e        ; 4
  rra           ; 4

; ----------

  or #0x010       ; 7
  ld e,a        ; 4
  add hl,de     ; 11
  jr nc,sq2     ; 12 / 7
  and #0x0DF      ; 7
  .db #218        ; 10
sq2:
  sbc hl,de     ; 15
  sra d         ; 8
  rra           ; 4

; ----------

  or #0x04        ; 7
  ld e,a        ; 4
  add hl,de     ; 11
  jr nc,sq1     ; 12 / 7
  and #0x0F7      ; 7
  .db #218        ; 10
sq1:
  sbc hl,de     ; 15
  sra d         ; 8
  rra           ; 4

; ----------

  inc a         ; 4
  ld e,a        ; 4
  add hl,de     ; 11
  jr nc,sq0     ; 12 / 7
  and #0x0FD      ; 7
sq0:
  sra d         ; 8
  rra           ; 4
  cpl           ; 4

ret



;;-----------------------------------------------------------------
;;
;; sys_util_return_from_sine_table
;;
;;  Returns the number of sine table corresponding to the angle
;;  Input:  hl: angle
;;  Output: hl : sine table result
;;  Destroyed: af, bc
;;
sys_util_return_from_sine_table::
  ld bc, #90
  or a 
  sbc hl, bc
  jr c, _sus_regular_return
  ld hl, #0x0100
  ret
_sus_regular_return:
  ld hl, (angle)
  ex de, hl
  ld hl, #sine_table
  add hl, de
  ld a, (hl)
  ld h, #0
  ld l, a
  ret 

;;-----------------------------------------------------------------
;;
;; sys_util_sine::
;;
;;  Waits a determined number of frames 
;;  Input:  a: angle
;;  Output: a : cosine(angle)
;;  Destroyed: af, bc
;;
;;     if (angle < 90) {
;;          return sine_table[angle];
;;     } else if (angle < 180) {
;;          return sine_table[180 - angle];
;;     } else if (angle < 270) {
;;          return -sine_table[angle - 180];
;;     } else {
;;          return -sine_table[360 - angle];
;;     }
;;
sys_util_sine::
  ld (angle), hl
  ld bc, #91
  or a
  sbc hl, bc
  jr c, _sus_return_minus90
  ld hl, (angle)
  ld bc, #180
  or a
  sbc hl, bc
  jr c, _sus_return_minus180
  ld hl, (angle)
  ld bc, #270
  or a
  sbc hl, bc
  jr c, _sus_return_minus270
_sus_return_minus360:
  ;; calculate 360 - angle
  ld hl, (angle)
  ld de, #360
  ex de, hl
  or a                                  ;; reset carry
  sbc hl, de
  ld (angle), hl
  call sys_util_return_from_sine_table
  jp sys_util_negHL
_sus_return_minus90:
  ld hl, (angle)
  jp sys_util_return_from_sine_table
_sus_return_minus180:
  ;; calculate 180 - angle
  ld hl, (angle)
  ld de, #180
  ex de, hl
  or a                                  ;; reset carry
  sbc hl, de
  ld (angle), hl
  jp sys_util_return_from_sine_table
_sus_return_minus270:
  ;; calculate angle - 180
  ld hl, (angle)
  ld de, #180
  or a                                  ;; reset carry
  sbc hl, de
  ld (angle), hl
  call sys_util_return_from_sine_table
  jp sys_util_negHL


;;-----------------------------------------------------------------
;;
;; sys_util_cosine
;;
;;  Waits a determined number of frames 
;;  Input:  hl: angle
;;  Output: hl : cosine(angle)
;;  Destroyed: af, bc
;;
;;     if (angle <= 90)
;;          return (sine(90 - angle));
;;     else
;;          return (-sine(angle - 90));
;;
sys_util_cosine::
  ld (angle), hl
  ld de, #90
  or a
  sbc hl, de
  jr nc, suc_more_than_90
    ;;calculate 90-angle in hl
    ld de, #90
    ld hl, (angle)
    ex de, hl
    or a
    sbc hl, de
    call sys_util_sine
    ret
  suc_more_than_90:
    ;; calculate angle-90 in hl
    ld hl, (angle)
    ld de, #90
    or a
    sbc hl, de
    call sys_util_sine
    jp sys_util_negHL

  angle:: .dw #0000



;;-------------------------------------------------------------------
;;
;;  Sine Table
;;
;; The sine table can be stored in bytes, becuase in the first quarter
;; all the sinus are positive an lower than 255.
;; in order to be able to return negative numbers, is necesary to
;; transform the byte into word when returning the information and 
;; have in mind that form 87 to 90 degres should return the word 0100
;;
sine_table::
  .db #0x00	
  .db #0x04, #0x08, #0x0D, #0x11, #0x16, #0x1A, #0x1F, #0x23, #0x28, #0x2C	
  .db #0x30, #0x35, #0x39, #0x3D, #0x42, #0x46, #0x4A, #0x4F, #0x53, #0x57	
  .db #0x5B, #0x5F, #0x64, #0x68, #0x6C, #0x70, #0x74, #0x78, #0x7C, #0x7F	
  .db #0x83, #0x87, #0x8B, #0x8F, #0x92, #0x96, #0x9A, #0x9D, #0xA1, #0xA4	
  .db #0xA7, #0xAB, #0xAE, #0xB1, #0xB5, #0xB8, #0xBB, #0xBE, #0xC1, #0xC4	
  .db #0xC6, #0xC9, #0xCC, #0xCF, #0xD1, #0xD4, #0xD6, #0xD9, #0xDB, #0xDD	
  .db #0xDF, #0xE2, #0xE4, #0xE6, #0xE8, #0xE9, #0xEB, #0xED, #0xEE, #0xF0	
  .db #0xF2, #0xF3, #0xF4, #0xF6, #0xF7, #0xF8, #0xF9, #0xFA, #0xFB, #0xFC	
  .db #0xFC, #0xFD, #0xFE, #0xFE, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF