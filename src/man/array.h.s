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


.include "common.h.s"

;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================


;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_array_init
.globl man_array_create_element
.globl man_array_remove_element
.globl man_array_get_element
.globl man_array_get_random_element
.globl man_array_move_all_elements
.globl man_array_execute_each
.globl man_array_execute_each_matching
.globl man_array_first_element

;;===============================================================================
;; COMPONENT DEFINITION MACRO
;;===============================================================================


.macro DefineArray _Tname, _MaxElements, _ComponentSize
      _Tname'_count::                     .db 0
      _Tname'_delta::                     .db 0
      _Tname'_component_size::            .db _ComponentSize
      _Tname'_component_max_number::      .db _MaxElements
      _Tname'_pend::                      .dw _Tname'_array 
      _Tname'_selected::                  .db 0
      _Tname'_array::
            .ds _MaxElements * _ComponentSize
.endm

;;===============================================================================
;; DATA ARRAY STRUCTURE CREATION
;;===============================================================================
BeginStruct a
Field a, count , 1
Field a, delta , 1
Field a, component_size , 1
Field a, component_max_number , 1
Field a, pend , 2
Field a, selected , 1
Field a, array , 1
EndStruct a