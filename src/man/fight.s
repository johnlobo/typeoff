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



.module fight_manager

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

first_lvl::
.asciz "THE DOOR                     "  ;; Name
.db 5                                   ;; Rounds
.db 0                                   ;; curent round
.db 1, 2, 3
.db 1, 2, 3
.db 1, 2, 3
.db 1, 2, 3
.db 1, 2, 3

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_fight_init
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_fight_init::
    ret


;;-----------------------------------------------------------------
;;
;; man_fight_update
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_fight_update::
    ret