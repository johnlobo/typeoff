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


.include "man/components.h.s"
.include "sys/util.h.s"
.include "common.h.s"
.include "cpctelera.h.s"

.module component_manager


DefineComponentPointerTable _entities, e_cmpID_Num_Components, MAX_ENTITIES
_components_size = . - _entities_components


;;-----------------------------------------------------------------
;;
;; man_components_init
;;
;;  Input:  
;;  Output: 
;;  Destroyed: af, hl, de, bc
;;
;;  lronaldo code (https://www.youtube.com/watch?v=OEETYTu-viw&t=1774s)
;;
man_components_init::
    ;; Set all values of the pointer array to nullpointer
    ;; filling in the array with zeroes
    ld hl, # _entities_components        ;; hl points to the start of the components array
    ld de, # _entities_components + 1    ;; de points to hl + 1
    ld (hl), #0                         ;; set the first byte of the array to 0
    ld bc, #_components_size-1          ;; set bc to the bytes to be filled
    ldir

    ;; Set the values for all Pend pointers in all pointer vectors
    ld b, #e_cmpID_Num_Components       ;; b = number of components
_init_next_pend:
    ;; Get in hl a pointer to the next component
    ld a, b                             ;; a = b
    dec a
    call man_components_getComponentPtrHL
    ld e, l
    ld d, h
    inc de
    inc de 
    ld (hl), e
    inc hl
    ld (hl), d
djnz _init_next_pend

ret


;;-----------------------------------------------------------------
;;
;; man_components_getComponentPtrHL
;;
;;  Input:  a: component id
;;  Output: hl: pointer to the start of the component structure
;;  Destroyed: af
;;
;;  lronaldo code (https://www.youtube.com/watch?v=OEETYTu-viw&t=1774s)
;;
man_components_getComponentPtrHL::
    ld hl, # _entities_access_table      ;; hl points to the Entity components table
    add a                               ;; a = 2a
    add_hl_a                            ;; hl = 2a
    ;; Get pointer to the component structure
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ret

;;-----------------------------------------------------------------
;;
;; man_components_getArrayHL
;;
;;  Input:  a: component id
;;  Output: hl: pointer to the start of the array of pointers for the selected component
;;  Destroyed: af
;;
;;  lronaldo code (https://www.youtube.com/watch?v=OEETYTu-viw&t=1774s)
;;
man_components_getArrayHL::
    call man_components_getComponentPtrHL
    inc hl
    inc hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  COMPONENT_MANAGER::add
;;      Adda a pointer to the entity in the corresponding array of components.
;;  INPUT:
;;      IX: Pointer to entity.
;;  MODIFY:
;;       A, HL
;;  RETURNS:
;;
;;  MoonBreak_arqstrad code (cpcretrodev 2020)
;;
man_components_add::
    ;;  Gets the pointer to the component's array.
	call man_components_getComponentPtrHL

    ;;  DE = Pointer to the first free position of the array of pointers.
    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl

    ;;  Copy the pointer of the entity that handles that component to the
    ;;  array of pointers.
    ld__a_ixl
    ld (de), a
    inc de
    ld__a_ixh
    ld (de), a
    inc de

    ;;  (HL) = Next free position of the pointer array.
    ld (hl), e
    inc hl
    ld (hl), d

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  COMPONENT_MANAGER::removePtr
;;      Remove the pointer from the destroyed entity replacing it with the
;;      last pointer of the array.
;;  INPUT:
;;		IX: Entity pointer.
;;		A:  Component ID.
;;  MODIFY:
;;      HL, DE, BC, A
;;  RETURNS:
;;	   
;;
;;  MoonBreak_arqstrad code (cpcretrodev 2020)
;;
man_components_removePtr::
    ;;  HL = First pointer of the relevant component array.
	call man_components_getComponentPtrHL
    push hl
    ;;  DE = Address insert new pointer.
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl      ;;  HL = Address to the first pointer of the array.

	__loop:
	ld a, (hl)
	inc hl
    cp__ixl
    jr nz, __loop

	ld a, (hl)
	inc hl
    cp__ixh
    jr nz, __loop

__delete_pointer:
    ;;  The last pointer is copied in the direction of the pointer to be deleted.
    ;;  HL = Pointer direction to remove.
    ;;  DE = Last array pointer.
    dec de
    ld a, (de)
    dec hl
    ld (hl), a

    dec de
    ld a, (de)
    dec hl
    ld (hl), a

__last_array_pointer:
    ;;  HL = Address containing the pointer to the next free address in the array.
    pop hl

    ;;  (HL) = New free position.
    ld (hl), e
    inc hl
    ld (hl), d

    ;;  The content of the las pointer of the array becomes null because it has been
    ;;  copied to the position of the deleted pointer.
    xor a
    ld (de), a
    inc de
    ld (de), a
	ret