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

.module input_system

.include "man/entities.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA



sys_input_main_menu_actions::
    ;;.dw Key_O,      sys_input_selected_left
    ;;.dw Key_P,      sys_input_selected_right
    ;;.dw Key_D,      sys_input_show_deck
    ;;.dw Key_Space,  sys_input_action
    ;;.dw Key_Q,      sys_input_add_card
    ;;.dw Key_A,      sys_input_remove_card
    ;;.dw Key_Esc,    _score_cancel_entry
    ;;.dw Joy0_Left,  _score_move_left
    ;;.dw Joy0_Right, _score_move_right
    ;;.dw Joy0_Up,    _score_move_up
    ;;.dw Joy0_Down,  _score_move_down
    ;;.dw Joy0_Fire1, _score_fire
    .dw 0

sys_input_player_actions::
    .dw Key_O,      sys_input_player_left
    .dw Key_P,      sys_input_player_right
    .dw Key_Q,      sys_input_player_up
    .dw Key_A,      sys_input_player_down
    ;;.dw Key_Esc,    _score_cancel_entry
    ;;.dw Joy0_Left,  _score_move_left
    ;;.dw Joy0_Right, _score_move_right
    ;;.dw Joy0_Up,    _score_move_up
    ;;.dw Joy0_Down,  _score_move_down
    ;;.dw Joy0_Fire1, _score_fire
    .dw 0

;;
;; Start of _CODE area
;; 
.area _CODE


;;-----------------------------------------------------------------
;;
;; sys_input_clean_buffer
;;
;;  Waits until de key buffer is clean
;;  Input: 
;;  Output:
;;  Modified: 
;;
sys_input_clean_buffer::
    call cpct_isAnyKeyPressed_asm
    jr nz, sys_input_clean_buffer
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_wait4anykey
;;
;;  Reads input and wait for any key press
;;  Input: 
;;  Output: hl: number of loops
;;  Modified: 
;;
sys_input_wait4anykey::
    ld hl, #0
_siw_loop:
    push hl
    call cpct_isAnyKeyPressed_asm
    or a
    pop hl
    inc hl
    jr z, _siw_loop
    push hl
    call sys_input_clean_buffer
    pop hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DESCRIPTION
;; Gets the ID of the FIRST key pressed found on the key
;; buffer
;; ----------------------------------------------------
;; PARAMS
;; ----------------------------------------------------
;; RETURNS
;; HL: Key pressed if anyone pressed. If not returns 0
;; ----------------------------------------------------
;; DESTROYS
;; AF, HL
;; ----------------------------------------------------
;;
;; Routine taken from Promotion from Bite Studios
;;
sys_input_getKeyPressed::
    ld hl, #_cpct_keyboardStatusBuffer
    xor a                           ;; A = 0

_kp_loop:
    cp #BUFFER_SIZE
    jr z, _kp_endLoop               ;; Check counter value. End if its 0
    ld (_size_counter), a

    ld a, (hl)                      ;; Load byte from the buffer
    xor #ZERO_KEYS_ACTIVATED        ;; Inverts bytes
    jr z, _no_key_detected
        ld h, a                     ;; H is the mask
        ld a, (_size_counter)
        ld l, a                     ;; L is the offset
        ; ld (_current_key_pressed), hl
        ret
_no_key_detected:
    inc hl
_size_counter = .+1
    ld a, #0x00                     ;; AUTOMODIFIABLE, A = counter
    inc a
    jr _kp_loop
_kp_endLoop:
    ld hl, #0x00                    ;; Return 0 if no key is pressed
    ld a, #0
    ld (_key_released), a
    ret

_key_released:
    .db #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DESCRIPTION
;; Does not return the key pressed until one is pressed.
;; WARNING: This blocks the execution until done
;; ----------------------------------------------------
;; PARAMS
;; ----------------------------------------------------
;; RETURNS
;; HL: Key pressed
;; ----------------------------------------------------
;; DESTROYS
;; AF, HL
;; ----------------------------------------------------
;;
;; Routine taken from Promotion from Bite Studios
;;
sys_input_waitKeyPressed::
    call sys_input_getKeyPressed
    ld a, (_key_released)
    or a
    jr nz, sys_input_waitKeyPressed
    xor a
    or h
    or l
    jr z, sys_input_waitKeyPressed
    ld a, #1
    ld (_key_released), a
    ret


;;-----------------------------------------------------------------
;;
;; sys_input_init
;;
;;   Initializes input
;;  Input: 
;;  Output:
;;  Modified: 
;;
sys_input_init::
    ret 

;;-----------------------------------------------------------------
;;
;;  sys_input_generic_update
;;
;;  Initializes input
;;  Input:  iy: array of key, actions to check
;;          ix: pointer to the strcut to be used in the actions
;;  Output:
;;  Modified: iy, bc
;;
sys_input_generic_update::
    jr first_key
keys_loop:
    ld bc, #4
    add iy, bc
first_key:
    ld l, 0(iy)                     ;; Lower part of the key pointer
    ld h, 1(iy)                     ;; Lower part of the key pointer
    ;; Check if key is null
    ld a, l
    or h
    ret z                           ;; Return if key is null
    ;; Check if key is pressed
    call cpct_isKeyPressed_asm      ;;
    jr z, keys_loop
    ;; Key pressed execute action
    ld hl, #keys_loop               ;;
    push hl                         ;; return addres from executed function
    ld l, 2(iy)                     ;;
    ld h, 3(iy)                     ;; retrieve function address    
    jp (hl)                         ;; jump to function


;;-----------------------------------------------------------------
;;
;; sys_input_add_card_update
;;
;;   Initializes input
;;  Input: 
;;  Output:
;;  Modified: iy, bc
;;
sys_input_main_menu_update::
    ld iy, #sys_input_main_menu_actions
    call sys_input_generic_update
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_player_left
;;
;;   reduces hor the speed of the player 
;;
;;  Input: 
;;  Output:
;;  Modified: iy, bc
sys_input_player_left::
    ld h, e_vx(ix)
    ld l, e_vx+1(ix)
    ld bc, #STEP_HORIZONTAL_SPEED           
    or a
    sbc hl, bc                          ;; add STEP SPEED to current SPEED
    ld bc, #MAX_HORIZONTAL_SPEED_NEG    ;; check if MAX HORIZONTAL SPEED has been reached
    or a                                ;;
    ld (sipl_max_not_reached+1), hl     ;; save new vx value for later use
    sbc hl, bc                          ;;
    jr c, sipl_max_reached              ;;
sipl_max_not_reached:
    ld hl, #00000
    ld e_vx(ix), h
    ld e_vx+1(ix), l
    jr sipl_exit
sipl_max_reached:                       ;; if max speed reached, vx set to max speed
    ld e_vx(ix), b
    ld e_vx+1(ix), c
sipl_exit:
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_player_right
;;
;;   reduces hor the speed of the player 
;;
;;  Input: 
;;  Output:
;;  Modified: iy, bc
sys_input_player_right::    
    ld h, e_vx(ix)
    ld l, e_vx+1(ix)
    ld bc, #STEP_HORIZONTAL_SPEED           
    add hl, bc                          ;; add STEP SPEED to current SPEED
    ld bc, #MAX_HORIZONTAL_SPEED_POS    ;; check if MAX HORIZONTAL SPEED has been reached
    or a                                ;;
    ld (sipr_max_not_reached+1), hl     ;; save new vx value for later use
    sbc hl, bc                          ;;
    jr nc, sipr_max_reached              ;;
sipr_max_not_reached:
    ld hl, #00000
    ld e_vx(ix), h
    ld e_vx+1(ix), l
    jr sipr_exit
sipr_max_reached:                       ;; if max speed reached, vx set to max speed
    ld e_vx(ix), b
    ld e_vx+1(ix), c
sipr_exit:
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_player_up
;;
;;   reduces ver the speed of the player 
;;
;;  Input: 
;;  Output:
;;  Modified: iy, bc
sys_input_player_up::
    ld h, e_vy(ix)
    ld l, e_vy+1(ix)
    ld bc, #STEP_VERTICAL_SPEED           
    or a
    sbc hl, bc                          ;; add STEP SPEED to current SPEED
    ld bc, #MAX_VERTICAL_SPEED_NEG      ;; check if MAX HORIZONTAL SPEED has been reached
    or a                                ;;
    ld (sipu_max_not_reached+1), hl     ;; save new vx value for later use
    sbc hl, bc                          ;;
    jr c, sipu_max_reached              ;;
sipu_max_not_reached:
    ld hl, #00000
    ld e_vy(ix), h
    ld e_vy+1(ix), l
    jr sipu_exit
sipu_max_reached:                       ;; if max speed reached, vx set to max speed
    ld e_vy(ix), b
    ld e_vy+1(ix), c
sipu_exit:
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_player_down
;;
;;   reduces hor the speed of the player 
;;
;;  Input: 
;;  Output:
;;  Modified: iy, bc
sys_input_player_down::    
    ld h, e_vy(ix)
    ld l, e_vy+1(ix)
    ld bc, #STEP_VERTICAL_SPEED           
    add hl, bc                          ;; add STEP SPEED to current SPEED
    ld bc, #MAX_VERTICAL_SPEED_POS      ;; check if MAX HORIZONTAL SPEED has been reached
    or a                                ;;
    ld (sipd_max_not_reached+1), hl     ;; save new vx value for later use
    sbc hl, bc                          ;;
    jr nc, sipd_max_reached              ;;
sipd_max_not_reached:
    ld hl, #nullptr
    ld e_vy(ix), h
    ld e_vy+1(ix), l
    jr sipd_exit
sipd_max_reached:                       ;; if max speed reached, vx set to max speed
    ld e_vy(ix), b
    ld e_vy+1(ix), c
sipd_exit:
    ret


;;-----------------------------------------------------------------
;;
;; sys_input_player_update
;;
;;   Updates player input
;;
;;  Input: 
;;  Output:
;;  Modified: iy, bc
sys_input_player_update::
    push ix                             ;; save ix information
    call man_entity_getPlayerPosition   ;; move ix to the first entity which will be player operated

    ld iy, #sys_input_player_actions
    call sys_input_generic_update
    pop ix                              ;; rerieve saved information in ix
    ret





