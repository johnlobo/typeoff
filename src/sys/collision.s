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

.module collisions_system

.include "sys/collision.h.s"
.include "man/components.h.s"
.include "man/entities.h.s"
.include "man/ball.h.s"
.include "sys/physics.h.s"
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
sys_collision_init::
    ;; set pointer array address 
    ld a, #e_cmpID_Collision
    call man_components_getArrayHL
    ld  (_ent_array_ptr), hl
    ret


;;-----------------------------------------------------------------
;;
;; sys_collision_check_collider_colisionable_Y
;;
;;  Initilizes render system
;;  Input: ix : pointer to the colider entity
;;  Input: iy : pointer to the collisionable entity
;;  Output: carry activated if no collision
;;  Modified: AF, BC, HL
;;
;;  Code copied from lronaldo (https://www.youtube.com/watch?v=f-4F7SoaHFQ)
sys_collision_check_collider_colisionable_Y::
    ;; y axis collision
    ;; case 3
    ld a, e_y(iy)                   ;; a = iy.y
    ld b, a                         ;; b = a = iy.y
    add e_h(iy)                     ;; a = iy.y + iy.y
    dec a                           ;; a = iy.y + iy.y - 1
    ld c, e_y(ix)                   ;; c = ix.y
    sub c                           ;; a = iy.y + iy.y - 1 - ix.y
    ret c                           ;; return if no collision
    ;; case 4
    ld a, c                         ;; a = ix.y
    add e_h(ix)                     ;; a = ix.y + ix.y
    dec a                           ;; a = ix.y + ix.y - 1
    sub b                           ;; a = iy.y + ix.y - 1 - iy.y
    ;;ret c                           ;; return if no collision - unncessary
    ret

;;-----------------------------------------------------------------
;;
;; sys_collision_check_collider_colisionable_X
;;
;;  Initilizes render system
;;  Input: ix : pointer to the colider entity
;;  Input: iy : pointer to the collisionable entity
;;  Output: carry activated if no collision
;;  Modified: AF, BC, HL
;;
;;  Code copied from lronaldo (https://www.youtube.com/watch?v=f-4F7SoaHFQ)
sys_collision_check_collider_colisionable_X::
    ;; x axis collision
    ;; case 1
    ld a, e_x(iy)                   ;; a = iy.x
    ld b, a                         ;; b = a = iy.x
    add e_w(iy)                     ;; a = iy.x + iy.w
    dec a                           ;; a = iy.x + iy.w - 1
    ld c, e_x(ix)                   ;; c = ix.x
    sub c                           ;; a = iy.x + iy.w - 1 - ix.x
    ret c                           ;; return if no collision
    ;; case 2
    ld a, c                         ;; a = ix.x
    add e_w(ix)                     ;; a = ix.x + ix.w
    dec a                           ;; a = ix.x + ix.w - 1
    sub b                           ;; a = iy.x + ix.w - 1 - iy.x
    ret



;;-----------------------------------------------------------------
;;
;; sys_collision_wall_up
;;
;;  Handles the collision with the paddle
;;  Input:  ix : pointer to the entity
;;          iy: pointer to the colisionable
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_collision_wall_up::
    ;; reposition colisionable after the collision
    ld a, e_collision_status(ix)
    and #e_col_down
    jr nz, _scwu_down_collision
    inc e_y(iy)                     ;;reposition ball to the right to avoid overlap
    jr _reverse_vertical_speed
_scwu_down_collision:
    dec e_y(iy)                     ;; reposition ball to the left to avoid overlap
_reverse_vertical_speed:
    ;; change speed because of the collision
    call man_ball_reverse_ver_speed
    ret

;;-----------------------------------------------------------------
;;
;; sys_collision_paddle
;;
;;  Handles the collision with the paddle
;;  Input:  ix : pointer to the entity
;;          iy: pointer to the colisionable
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_collision_paddle::
    ;; reposition colisionable after the collision
    ld a, e_collision_status(ix)
    and #e_col_left
    jr nz, _left_collision
    inc e_x(iy)                         ;;reposition ball to the right to avoid overlap
    jr _reverse_horizontal_speed
_left_collision:
    dec e_x(iy)                         ;; reposition ball to the left to avoid overlap
    ;; change speed because of the collision
_reverse_horizontal_speed:
    call man_ball_reverse_hor_speed     ;; Reverse horizontal ball speed
    ;; change vertical speed
    ld b, e_y(ix)
    ld a, e_y(iy)
    sub b
    cp #6
    jr nc, _greater_than_6
    xor a
    call man_ball_set_ver_speed
    jr _scp_exit
_greater_than_6:
    cp #14
    jr nc, _greater_than_14
    ld a, #1
    call man_ball_set_ver_speed
    jr _scp_exit
_greater_than_14:
    cp #16
    jr nc, _greater_than_16
    ld a, #2
    call man_ball_set_ver_speed
    call man_ball_increase_hor_speed
    jr _scp_exit
_greater_than_16:
    cp #24
    jr nc, _greater_than_24
    ld e_vy(iy), #0x00
    ld e_vy+1(iy), #0x32
    jr _scp_exit
_greater_than_24:
    ld e_vy(iy), #0x00
    ld e_vy+1(iy), #0x33
_scp_exit:
    ld e_moved(iy), #1
    ret

;;-----------------------------------------------------------------
;;
;; sys_collision_update_one_entity
;;
;;  Initilizes render system
;;  Input: ix : pointer to the entity
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_collision_collider_colisionable::

    call sys_collision_check_collider_colisionable_X  ;; check if there is a horizontal collision
    ret c
    ;; calculate horizontal collision status

    ld a, e_vx(iy)
    bit 7, a
    jr nz, _sccc_right
    ld e_collision_status(ix), #e_col_left
    jr _sccc_vertical_check
_sccc_right:
    ld e_collision_status(ix), #e_col_right
_sccc_vertical_check:
    call sys_collision_check_collider_colisionable_Y  ;; check if there is a collision
    ret c
    ;; calculate vertical collision status
    ld a, e_vy(iy)
    bit 7, a
    jr z, _sccc_down
    ld a, e_collision_status(ix)
    or #e_col_up
    ld e_collision_status(ix), a
    jr _sccc_exit
_sccc_down:
    ld a, e_collision_status(ix)
    or #e_col_down
    ld e_collision_status(ix), a
_sccc_exit:
    ld l, e_collision_callback(ix)
    ld h, e_collision_callback+1(ix)
    jp (hl)
    ;;ret               ;; tail recursion



;;-----------------------------------------------------------------
;;
;; sys_collision_update_one_entity
;;
;;  Initilizes render system
;;  Input: ix : pointer to the entity
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_collision_update_one_collider::
    ld hl, #sys_collision_collider_colisionable
    ld b, #e_cmp_collisionable
    call man_entity_forall_matching_iy
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

sys_collision_update::

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

    call sys_collision_update_one_collider

	pop hl

    jr _loop

    ret
