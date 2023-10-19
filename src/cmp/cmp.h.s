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

.include "macros.h.s" 

;;===============================================================================
;; CARD DEFINITION MACRO
;;===============================================================================
.macro DefineCard _cpms, _status, _sprite, _name, _rarity, _type, _energy, _description, _damage, _block, _vulnerable, _weak, _strengh, _exhaust, _add_card, _execute_routine
    .db _cpms
    .db _status
    .dw _sprite
    .db _type
    .db _energy
    .asciz "_description"
    .db _damage
    .db _block
    .db _vulnerable
    .db _weak
    .db _strengh
    .db _exhaust
    .dw _execute_routine
.endm

;;===============================================================================
;; CARD SCTRUCTURE CREATION
;;===============================================================================
BeginStruct c
Field c, cpms , 1
Field c, status , 1
Field c, sprite , 2
Field c, type , 1
Field c, energy , 1
Field c, description , 31
Field c, damage , 1
Field c, block , 1
Field c, vulnerable , 1
Field c, weak , 1
Field c, strengh , 1
Field c, exhaust , 1
Field c, execute_routine, 2
EndStruct c

;;===============================================================================
;; POINTER TO CARD STRUCTURE CREATION
;;===============================================================================
BeginStruct e
Field e, cpms , 1
Field e, status , 1
Field e, p , 2
EndStruct e