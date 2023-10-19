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


;;==============================================================================================================================
;;==============================================================================================================================
;;  ENTITY MANAGER
;;		Handles entities using a linked list.
;;		Allows to create, delete and update entities.
;;==============================================================================================================================
;;==============================================================================================================================
;;==============================================================================================================================
;;==============================================================================================================================
.include "man/components.h.s"
.include "common.h.s"
.include "macros.h.s"
.include "cpctelera.h.s"

.module Entity_Manager

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

DefineComponentArrayStructure_Size _entity, MAX_ENTITIES, sizeof_e

;;
;; Start of _CODE area
;; 
.area _CODE

;;==============================================================================================================================
;;==============================================================================================================================
;;  Private functions
;;==============================================================================================================================
;;==============================================================================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Destroy
;;		Destroy the marked entity by copying the last one of the vector to its position
;;  	and marking its an invalid.
;;  INPUT:
;;		IX: Pointer to the entity to destroy.
;;		DE: Pointer to the linked entity.
;;		BC: e_ptr_h(ix), e_ptr_l(ix)
;;  MODIFY:
;;      HL, A, IX
;;
man_entity_destroy::
	push de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	DESTROY POINTER VECTOR COMPONENTS - OPTIMIZE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	ld a, e_cmps(ix)
	and #e_cmp_ai
	jr z, _noAID

	_AId:
	ld a, #e_cmpID_AI
	call man_components_removePtr

	_noAID:
	ld a, e_cmps(ix)
	and #e_cmp_collisionable
	jr z, _noCollisionableD

	_Collisionabled:
	ld a, #e_cmpID_Collision
	call man_components_removePtr

	_noCollisionableD:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	pop de

	ld hl, (_entity_free_list)					;;	\	The free list will now start at the end pointer of
	ld (_entity_free_list), ix					;;	|	the deleted entity and contain a pointers to its old
	ld e_ptr(ix), l				    			;;	|	position.
	ld e_ptr+1(ix), h							;;	/

	ld hl, #_entity_num
	dec (hl)

	ld a, e										;;	\	If DE points to null, it means it is the las entity
	or d										;;	|	and _entity_list will point to the next entity
	jr z, #__is_the_last_entity					;;	/	in the list.

__it_is_not_the_last_entity:					;;	\	If it is not the las entity, the entity
	ld l, e										;;	|	that linked it will point to the pointer that
	ld h, d										;;	|	it contained.
	ld (hl), c									;;	|
	inc hl										;;	|
	ld (hl), b									;;	/

	ret

__is_the_last_entity:
	ld (_entity_list), bc

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::new
;;      
;;  INPUT:
;;		HL: Pointer to the entity to create.
;;  MODIFY:
;;       HL, BC, DE
;;	   
man_entity_new::

	;; Increment number of templates
	ld hl, #_entity_num
	inc (hl)

	;; updates pointer to free space
	ld hl, (_entity_free_list)	;; HL = Pointer to free space.

	push hl

	ld e, (hl)							;;	\	Extract from HL the pointer to the next
	inc hl								;;	|	free element.
	ld d, (hl)							;;  |	Free space will now start on that element.
	ld (_entity_free_list), de			;;	/

	ld hl, (_entity_list)				;;	HL = Pointer to the first item in the list.

	ld c, l								;;	BC = HL
	ld b, h

	pop hl

	ld e, l								;;	\	Save the pointer where the new entity will be positioned in DE increasing two
	ld d, h								;;	/	so as not to delete the pointer to the next entity.

	;; Update the pointer to the next entity
	ld (_entity_list), hl				;;	\	Assign to _entity_list the pointer of the new position that will host an entity.
	ld (hl), c							;;	|	If it's the first entity that is created, DE will contain a pointer to null, otherwise,
	inc hl								;;	|	the pointer to the next entity.
	ld (hl), b							;;	/

	ld bc, #sizeof_e - 2

	ret

;;==============================================================================================================================
;;==============================================================================================================================
;;  Public functions
;;==============================================================================================================================
;;==============================================================================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Init
;;      Sets the vector of entities to zero.
;;  INPUT:
;;  MODIFY:
;;       A, HL, DE, BC
;;
man_entity_init::
	call man_components_init
	
	xor a
	ld (_entity_num), a

	ld hl, #nullptr
	ld (_entity_list), hl

	ld hl, #_entity_array
	ld (_entity_free_list), hl		;;	List of free entities.
	
	push hl

	ld 	(hl), #0							;;	\	Initialize the components of the list
	ld 	d, h								;; 	|	elements to zero.
	ld	e, l								;; 	|
	inc de									;; 	|
	ld bc, #MAX_ENTITIES * sizeof_e - 1		;; 	|
	ldir									;; 	/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	DON'T PUT CODE HERE!
;;
;;	The init method calls the ENTITY_MANAGER::Init_linked_list
;;	method immediately.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Init_inked_list
;;      Sets pointers to the beginning of each entity
;;		in the next free position.
;;  INPUT:
;;  MODIFY:
;;       A, HL, DE
;;
man_entity_init_linked_list::
	ld a, #MAX_ENTITIES - 1		;;	\	The entity counter is only necessary until the penultimate, 
	ld (_ent_counter), a		;;	/	since the las one haas to have a null value.

	ld bc, #sizeof_e

	pop hl

	ld e, l
	ld d, h	

__init_loop:
	add hl, bc				;;	Save in HL the pointer to the next free space.

	ex de, hl				;;	DE = HL, HL = DE

	ld (hl), e				;;	\	Copy the address to the next free space
	inc hl					;;	|	in the first two bytes of the previous element
	ld (hl), d				;;	/	the address to the next free space.

	ld l, e					;; L = E
	ld h, d					;; H = D

	_ent_counter = . + 1
	ld a, #0
	dec a
	ret z

	ld (_ent_counter), a

jr __init_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Set4destruction
;;      Marks and entity to be destroyed
;;  INPUT:
;;		IX: Pointer to the entity to mark to be destroyed
;;  MODIFY:
;;       A
;;
man_entity_set4destruction::
	ld a, e_type(ix)
	and #e_type_block
	jr z, _not_player
	;; Set state to game over
	;;ld a, #4
	;;call game_manager_set_state
	ret
_not_player:
	ld a, #e_type_dead
	ld e_type(ix), a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Update
;;      Update the vector of entitites destroying the marked ones.
;;  INPUT:
;;  MODIFY:
;;       DE, BC, A, IX
;;	   
man_entity_update::

	call man_entity_getEntityArrayIX
	ld de, #nullptr						;; 	Initialize DE with a pointer to null to know if the entity to delete will be the first in the linked list.

_loop:

	ld c, e_ptr(ix) 					;;	\	Save in BC the pointer to the next entity.
    ld b, e_ptr+1(ix)					;;	/
	
	ld__a_ixl							;;	\	Ends when finding a null point, the end of the list.
	or__ixh								;;	|
	ret	z								;;	/

	ld a, e_type(ix)					;;	\ 	It is checked if the entity is marked to die.
	and #e_type_dead					;; 	|
	jr nz, #__marked_for_death			;;	/

__unmarked:
	ld__e_ixl							;;	\	If the entity is not marked, its pointer is saved.
    ld__d_ixh							;;	|
	jr #__check_next_entity				;;	/

__marked_for_death:						;;	The destructor is called to delete the marked entity.
	call man_entity_destroy

__check_next_entity:

    ld__ixl_c
    ld__ixh_b

	jr _loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::Create
;;      Creates a new entity.
;;  INPUT:
;;		HL: Pointer to the entity to create
;;	OUTPUT:
;;		IX: Pointer to the new entity created
;;  MODIFY:
;;       DE, BC, A
;;	   
man_entity_create::
	push hl
	call man_entity_new

	ld__ixh_d
	ld__ixl_e

	pop hl

	;;	HL and DE are incremented so as not to overwrite the list pointers	to the next entity.
	inc hl	
	inc hl
	inc de
	inc de
	ldir

	;;	ASSIGN ENTITY TO VECTOR OF POINTERS

	ld a, e_cmps(ix)
	and a, #e_cmp_render
	jr z, _noRender
	_Render:
	ld a, #e_cmpID_Render
	call man_components_add

	_noRender:
	ld a, e_cmps(ix)
	and #e_cmp_ai
	jr z, _noAI

	_AI:
	ld a, #e_cmpID_AI
	call man_components_add

	_noAI:
	ld a, e_cmps(ix)
	and #e_cmp_collider
	jr z, _noCollider

	_Collider:
	ld a, #e_cmpID_Collision
	call man_components_add

	_noCollider:
	ld a, e_cmps(ix)
	and #e_cmp_physics
	jr z, _noPhysics

	_Physics:
	ld a, #e_cmpID_Physics
	call man_components_add
	_noPhysics:	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::GetEntityArrayIX
;;      Returns the pointer to the entity array and the number of entities
;;  INPUT:
;;  MODIFY:
;;       IX, A
;;	   
man_entity_getEntityArrayIX::
	ld ix, #_entity_array
	ld a, (_entity_num)
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ENTITY_MANAGER::GetEntityArrayIY
;;      Returns the pointer to the entity array and the number of entities
;;  INPUT:
;;  MODIFY:
;;       IX, A
;;	   
man_entity_getEntityArrayIY::
	ld iy, #_entity_array
	ld a, (_entity_num)
	ret

;;-----------------------------------------------------------------
;;	man_next_entity_iy
;;	INPUT: iy pointer to one the entities
;;	OUTPUT: iy points to the nect
;;
man_entity_next_entity_iy::
	cpctm_push hl, bc
	push iy
	pop hl
	ld bc, #sizeof_e
	add hl, bc
	push hl
	pop iy
	cpctm_pop bc, hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	ENTITY_MANAGER::man_entity_getPlayerPosition
;;		Returns a pointer to the player for input system
;;	INPUT:
;;	MODIFY:
;;		HL
;;	   
man_entity_getPlayerPosition::
	ld ix, #_entity_array
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	ENTITY_MANAGER::man_entity_getOponentPosition
;;		Returns a pointer to the oponent
;;	INPUT:
;;	MODIFY:
;;		HL
;;	   
man_entity_getOponentPosition::
	cpctm_push hl, bc
	ld hl, #_entity_array
	ld bc, #sizeof_e
	add hl, bc
	push hl
	pop iy
	cpctm_pop bc, hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	ENTITY_MANAGER::man_entity_getBallPositionIY
;;		Returns a pointer to the player for input system
;;	INPUT:
;;	MODIFY:
;;		HL
;;	   
man_entity_getBallPositionIY::
	cpctm_push hl, bc
	ld hl, #_entity_array
	ld bc, #sizeof_e
	add hl, bc
	add hl, bc
	push hl
	pop iy
	cpctm_pop bc, hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	ENTITY_MANAGER::deleteEverythingExceptPlayer
;;		Remove all entities except the player'.
;;	INPUT:
;;	MODIFY:
;;		A
;;	   
man_entity_deleteEverythingExceptPlayer::
	call man_entity_getEntityArrayIX

	__loop:
	;;	If the pointer to the next element in the list is null the entity is the player
	;; 	and the loop is terminated.
	ld a, e_ptr(ix)
	ld c, a
	ld b, e_ptr+1(ix)
	or c
	ret z

	;;	The entity is marked for deletion.
	call man_entity_set4destruction

	ld__ixl_c
	ld__ixh_b
	jr __loop

;; Pointer to function
function_for_all: .db #0x00, #0x00

;; ---------------------------------------------
;; Applies a function filtering specific criteria
;; B -> Mask of bytes (e_cmps)
;; ---------------------------------------------
man_entity_forall_matching_iy::
    ld (function_for_all), hl
    call man_entity_getEntityArrayIY ;; IY points to the first entity

    ld a,e_cmps(iy) ;;si la primera entidad es invalida, salimos de la funcion
    and #0xFF
    ret z

    loop_forall_matching:
        push bc ;;guardo mascara de bytes
        ld a, e_cmps(iy)
        and b
        cp b
        jr nz, afterjp_matching
   
        ld hl, #afterjp_matching
        push hl

        ld hl, (function_for_all)
        jp (hl)

    afterjp_matching:
        call man_entity_next_entity_iy
        
        ld a,e_cmps(iy)
        and #0xff
        pop bc
    jr nz, loop_forall_matching

	ret