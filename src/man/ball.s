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


.module ball_manager

.include "man/ball.h.s"
.include "man/entities.h.s"
.include "sys/physics.h.s"
.include "sys/util.h.s"
.include "common.h.s"
.include "cpctelera.h.s"

;;-----------------------------------------------------------------
;;
;; man_ball_reverse_hor_speed
;;
;;  Reverses the vertical speed of the ball
;;  Input:  ix : pointer to the entity
;;          iy: pointer to the colisionable
;;  Output: 
;;  Modified: AF, BC, HL
;;
man_ball_reverse_hor_speed::
    push iy
    call man_entity_getBallPositionIY   
    ld h, e_vx(iy)
    ld l, e_vx+1(iy)
    call sys_util_negHL
    ld e_vx(iy), h
    ld e_vx+1(iy), l
    pop iy
    ret

;;-----------------------------------------------------------------
;;
;; man_ball_reverse_ver_speed
;;
;;  Reverses the vertical speed of the ball
;;  Input:  ix : pointer to the entity
;;          iy: pointer to the colisionable
;;  Output: 
;;  Modified: AF, BC, HL
;;
man_ball_reverse_ver_speed::
    push iy
    call man_entity_getBallPositionIY
    ld h, e_vy(iy)
    ld l, e_vy+1(iy)
    call sys_util_negHL
    ld e_vy(iy), h
    ld e_vy+1(iy), l
    pop iy
    ret

;;-----------------------------------------------------------------
;;
;; man_ball_increase_hor_speed
;;
;;  increase the horizonal speed of the ball
;;  Input:  a : angle
;;  Output: 
;;  Modified: AF, BC, HL
;;
man_ball_increase_hor_speed::
    ld h, e_vx(iy)
    ld l, e_vx+1(iy)
    call sys_util_absHL
    ld bc, #STEP_HORIZONTAL_BALL_SPEED
    add hl, bc
    ld bc, #MAX_HORIZONTAL_BALL_SPEED           ;; Check if the maxi of the hor speed has been reached
    push hl
    or a
    sbc hl, bc
    pop hl
    jr c, _mbihs_restore_speed
    ld hl, #MAX_HORIZONTAL_BALL_SPEED
_mbihs_restore_speed:
    ld b, e_vx(iy)
    bit 7, b
    jr z, _mbihs_exit
    call sys_util_negHL
_mbihs_exit:
    ld e_vx(iy), h
    ld e_vx+1(iy), l
    ret

;;-----------------------------------------------------------------
;;
;; man_ball_set_ver_speed
;;
;;  sets the vertical speed of the ball
;;  Input:  a : angle
;;  Output: 
;;  Modified: AF, BC, HL
;;
man_ball_set_ver_speed::
    push iy
    call man_entity_getBallPositionIY

    or a                                ;; a=0??
    jr nz, mbsvs_1
    ld e_vy(iy), #0xff
    ld e_vy+1(iy), #0xe0
    jr mbsvs_exit
mbsvs_1:
    cp #1
    jr nz, mbsvs_2
    ld e_vy(iy), #0xff
    ld e_vy+1(iy), #0xf0
    jr mbsvs_exit
mbsvs_2:
    cp #2
    jr nz, mbsvs_3
    ld e_vy(iy), #0x00
    ld e_vy+1(iy), #0x00
    jr mbsvs_exit
mbsvs_3:
    cp #3
    jr nz, mbsvs_4
    ld e_vy(iy), #0x00
    ld e_vy+1(iy), #0x16
    jr mbsvs_exit
mbsvs_4:
    ld e_vy(iy), #0x00
    ld e_vy+1(iy), #0x32
mbsvs_exit:
    pop iy
    ret

