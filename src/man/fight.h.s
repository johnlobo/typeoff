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

.module fight_manager

;;------------------------------------------------------------------------------
;; Global constants
;;------------------------------------------------------------------------------

COMBAT_CARDS_PER_ROUND = 3
COMBAT_MAX_ROUNDS = 12

;;------------------------------------------------------------------------------
;; Global variables
;;------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; Global routines
;;------------------------------------------------------------------------------

.globl man_fight_init
.globl man_fight_update


;;===============================================================================
;; MACROS
;;===============================================================================


;;===============================================================================
;; DATA ARRAY STRUCTURE CREATION
;;===============================================================================
BeginStruct fight
Field fight, name , 30
Field fight, rounds , 1
Field fight, current_round , 1
Field fight, cards, (COMBAT_MAX_ROUNDS*COMBAT_CARDS_PER_ROUND) 
EndStruct fight
