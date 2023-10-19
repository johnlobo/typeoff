;;-----------------------------LICENSE NOTICE------------------------------------
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

.module ai_system

.include "sys/ai.h.s"
.include "man/components.h.s"
.include "man/entities.h.s"
.include "sys/util.h.s"
.include "common.h.s"
.include "cpctelera.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


;;
;; Start of _CODE area
;; 
.area _CODE


;;-----------------------------------------------------------------
;;
;; sys_physics_init
;;
;;  Initilizes render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_ai_init::
    ;; set pointer array address 
    ld a, #e_cmpID_AI
    call man_components_getArrayHL
    ld  (_ent_array_ptr), hl
    ret



;;-----------------------------------------------------------------
;;
;; sys_ai_paddle
;;
;;  Handles the collision with the paddle
;;  Input:  ix : pointer to the entity
;;          iy: pointer to the colisionable
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_ai_paddle::
    call man_entity_getBallPositionIY

    ld a, e_vx(iy)                                 ;; check that the ball is comming to the paddle
    bit 7, a                                       ;;
    ret nz                                         ;; otherwise return
    
    ld a, e_y(ix)                                  ;; check if the paddle is at the same y pos than the ball
    add #15                                        ;; compare with the middle of tha paddle
    ld b, e_y(iy)                                  ;;
    cp b                                           ;;
    ret z                                          ;; if so, return

    jr c, _sap_up                                  ;; if we are under, then go up
    ld e_vy(ix), #0xff                             ;; otherwise set y speed up
    ld a, e_vy+1(ix)
    add #(255 - STEP_VERTICAL_SPEED)
    ld e_vy+1(ix), a
    ret    
_sap_up:       
    ld e_vy(ix), #0                                ;; otherwise set y speed down
    ld a, e_vy+1(ix)
    add #STEP_VERTICAL_SPEED
    ld e_vy+1(ix), a

    ret





;;-----------------------------------------------------------------
;;
;; sys_collision_update
;;
;;  Initilizes collision system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;

sys_ai_update::

_ent_array_ptr = . + 1
    ld  hl, #0x0000

    _loop:
    ;;  Select the pointer to the entity with collision and prepare the next position for the next iteration.
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl

    ;;  The entities are finished traversing when find a pointer to null.
    ld a, e
    or d
    ret z

    push hl

    ld__ixl_e
    ld__ixh_d

    ld l, e_ai_callback(ix)
    ld h, e_ai_callback+1(ix)
    ld bc, #_endAIUpdate
    push bc
    
    jp (hl)

_endAIUpdate:


	pop hl

    jr _loop

    ret
