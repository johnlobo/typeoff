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
.module Entity_Manager

.globl man_entity_init
.globl man_entity_create
.globl man_entity_getEntityArrayIX
.globl man_entity_getEntityArrayIY
.globl man_entity_next_entity_iy
.globl man_entity_getPlayerPosition
.globl man_entity_getOponentPosition
.globl man_entity_getBallPositionIY
.globl man_entity_set4destruction
.globl man_entity_update
.globl man_entity_deleteEverythingExceptPlayer
.globl man_entity_forall_matching_iy