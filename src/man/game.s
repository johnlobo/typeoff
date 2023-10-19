;;-----------------------------LICENSE NOTICE------------------------------------
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

.module game_manager

.include "man/game.h.s"
.include "man/entities.h.s"
.include "sys/render.h.s"
.include "sys/physics.h.s"
.include "sys/input.h.s"
.include "sys/ai.h.s"
.include "sys/collision.h.s"
.include "sys/util.h.s"
.include "sys/text.h.s"
.include "common.h.s"
.include "cpctelera.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

blockTpl::
;;DefineEntity _cpms, _ptr, _type,           _color, _x, _y, _w, _h, _vxh, _vxl _vyh, _vyl, _sprite, _address, _p_address, _collsion_callback, ai_callback
DefineEntity e_cmp_block, #0000, e_type_block, 15, 15, 0, 10, 20, 0x00, 0x00, 0x00, 0x08, 0x0000, 0x0000, 0x0000, sys_collision_paddle, 0x0000

game_state:: .db MAIN_MENU   ;; Game state ----- 0: Game loop, 1: Main menu, 2: Map loading, 3: Pause menu, 4: Game over, 5: Victory
;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_game_init
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_init::

    ;; Initialize entities
    call man_entity_init

    ;; Initialize Systems
    call sys_collision_init                 ;; initialize collision system
    call sys_ai_init                        ;; initialize collision system
    call sys_physics_init                   ;; initialize physics system
   
    ;; Create test entity

    BREAKPOINT
    ;; Create a player entity in 100, 100
    ld hl, #blockTpl                      ;; Template of the entity to create
    call man_entity_create                  ;; Create new entity

    ret

;;-----------------------------------------------------------------
;;
;; man_game_update
;;
;;   
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_update::
    call sys_input_player_update
    call sys_physics_update
    call sys_render_update
    ;;;;delay 
    ;;ld b, #6
    ;;call cpct_waitHalts_asm
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Gets the current state of the game loop
;;  MODIFIES:
;;      - A: Returns state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_get_state::
    ld a, (game_state)
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Sets the current state of the game loop
;;  MODIFIES:
;;      - A: Returns state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_game_set_state::
    ld (game_state), a
    ret
