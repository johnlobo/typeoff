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

.module physics_system

.include "sys/physics.h.s"
.include "sys/util.h.s"
.include "man/components.h.s"
.include "man/entities.h.s"
.include "man/ball.h.s"
.include "common.h.s"
.include "cpctelera.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


.area _ABS   (ABS)


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
sys_physics_init::
    ;; set pointer array address 
    ld a, #e_cmpID_Physics
    call man_components_getArrayHL
    ld  (_ent_array_ptr), hl

    ret

;;-----------------------------------------------------------------
;;
;; sys_physics_apply_gravity
;;
;;  Initilizes render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_physics_apply_gravity::
    ld bc, #GRAVITY
    ld h, e_vy(ix)
    ld l, e_vy+1(ix)
    add hl, bc
    ld e_vy(ix), h              ;; restore updated vy
    ld e_vy+1(ix), l            ;; 
    ret 

;;-----------------------------------------------------------------
;;
;; sys_physics_apply_friction_vx
;;
;;  Initilizes render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_physics_apply_friction_vx::
    ld bc, #COF                 ;; Coeficient of friction
    ld h, e_vx(ix)
    ld l, e_vx+1(ix)
    bit 7, h                    ;; test if vx is positive or negative
    jr nz, _vx_negative         ;; if bit 7 is set, z is not set and vx is positive
                                ;; so the COF should be substracted
    or a                        ;; reset c
    sbc hl,bc                   ;; substract bc from hl
    jp p, _vx_restore           ;;
    ld h, #0                    ;; if vx has gone negative vx = 0
    ld l, h                     ;;
    jr _vx_restore
_vx_negative:
    add hl, bc                  ;; add COF to vx
    jp m, _vx_restore           ;;
    ld h, #0                    ;; if vx has gone positive vx = 0
    ld l, h                     ;;
_vx_restore:
    ld e_vx(ix), h              ;; restore updated vx
    ld e_vx+1(ix), l            ;; restore updated vx
    ret

;;-----------------------------------------------------------------
;;
;; sys_physics_apply_friction_vy
;;
;;  Initilizes render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_physics_apply_friction_vy::
    ld bc, #COF                 ;; Coeficient of friction
    ld h, e_vy(ix)
    ld l, e_vy+1(ix)
    bit 7, h                    ;; test if vx is positive or negative
    jr nz, _vy_negative         ;; if bit 7 is set, z is not set and vx is positive
                                ;; so the COF should be substracted
    or a                        ;; reset c
    sbc hl,bc                   ;; substract bc from hl
    jp p, _vy_restore           ;;
    ld h, #0                    ;; if vx has gone negative vx = 0
    ld l, h                     ;;
    jr _vy_restore
_vy_negative:
    add hl, bc                  ;; add COF to vx
    jp m, _vy_restore           ;;
    ld h, #0                    ;; if vx has gone positive vx = 0
    ld l, h                     ;;
_vy_restore:
    ld e_vy(ix), h              ;; restore updated vx
    ld e_vy+1(ix), l            ;; restore updated vx
    ret


;;-----------------------------------------------------------------
;;
;; sys_physics_check_out_of_bounds_x
;;
;;  Initilizes render system
;;  Input: ix : pointer to the entity
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_physics_check_out_of_bounds_x::
    call man_entity_getBallPositionIY
    ld a, e_x(iy)
    cp #80
    ret c                               ;; If we are not out of bounds, ret
    ld a, e_vx(iy)
    bit 7, a                 ;; check the orientation of the hor speed
    jr nz, _spcob_going_left
    ld e_x(iy), #79
    jr _spcob_reverse
_spcob_going_left:
    ld e_x(iy), #0
_spcob_reverse:
    ld e_x+1(iy), #0
    call man_ball_reverse_hor_speed
    ret

;;-----------------------------------------------------------------
;;
;; sys_physics_check_out_of_bounds_y
;;
;;  Initilizes render system
;;  Input: ix : pointer to the entity
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_physics_check_out_of_bounds_y::
    ld a, #199                          ;; calculate 199 - Height
    ld b, e_h(ix)
    sub b
    ld b, a
    ld a, e_y(ix)
    cp b                
    ret c                               ;; If we are not out of bounds, ret
    ld a, e_vy(iy)
    bit 7, a                            ;; check the orientation of the ver speed
    jr nz, _spcoby_going_left
    ld e_y(iy), #79
    jr _spcoby_reverse
_spcoby_going_left:
    ld e_x(iy), #0
_spcoby_reverse:
    ld e_x+1(iy), #0
    call man_ball_reverse_hor_speed
    ret


;;-----------------------------------------------------------------
;;
;; sys_physics_update_one_entity
;;
;;  Initilizes render system
;;  Input: ix : pointer to the entity
;;  Output: 
;;  Modified: AF, BC, HL
;;
sys_physics_update_one_entity::
    ;; update x coord with vx
    ld a, e_vx(ix)              ;; check if the speed in x is 0
    ld c, e_vx+1(ix)            ;;
    or c                        ;; check if vx == 0
    jr z, spuoe_yCoord          ;; move to y coord if vx === 0

    ld b, e_vx(ix)              ;; lower part of the vx speed c, so bc = vx
    ld h, e_x(ix)               ;; get the x coord in hl
    ld l, e_x+1(ix)             ;; 
    ld a, h                     ;; save h value in a
    add hl, bc                  ;; add x+vx
    call sys_physics_check_out_of_bounds_x  ;; check if we the ball has gone out of bounds in the x axis
    ld e_x(ix), h               ;; update entity with new position
    ld e_x+1(ix), l             ;;
    ;; check if screen coord has changed to update moved.
    cp h                        ;; if h has changed (high value)moved = true
    jr z, spuoe_yCoord          ;;
    ld e_moved(ix), #1          ;; flag the entity as moved
    
spuoe_yCoord:
    ;; update y coord with vy
    ld a, e_vy(ix)              ;; check if the speed in y is 0
    ld c, e_vy+1(ix)            ;;
    or c                        ;; check if vx == 0
    jr z, spuoe_exit            ;; move to ret coord if vx === 0
    
    ld b, e_vy(ix)              ;; lower part of the vy speed c, so bc = vy
    ld h, e_y(ix)               ;; get the y coord in hl
    ld l, e_y+1(ix)             ;; 
    ld a, h                     ;; save h value in a
    add hl, bc                  ;; add y+vy
    ld e_y(ix), h               ;; update entity with new position
    ld e_y+1(ix), l             ;;
    ;; check if screen coord has changed to update moved.
    cp h                        ;; if h has changed (high value)moved = true
    jr z, spuoe_exit            ;; screen coord has not changed->check the ground
    ld e_moved(ix), #1          ;; flag the entity as moved

spuoe_exit:
    ;; Friction & Gravity
    ld a, e_type(ix)             ;; only apply frcition to player paddles 
    cp #1                       ;;
    ret nz                      ;; return otherwise
    ;;call sys_physics_apply_friction_vx  
    ;;jp sys_physics_apply_friction_vy            ;; call + ret = jp
    ret

;;-----------------------------------------------------------------
;;
;; sys_physics_update
;;
;;  Initilizes physics system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;

sys_physics_update::

_ent_array_ptr = . + 1
    ld  hl, #0x0000

    _loop:
    ;;  Select the pointer to the entity with AI and prepare the next position for the next iteration.
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

    call sys_physics_update_one_entity

	pop hl

    jr _loop

    ret
    
