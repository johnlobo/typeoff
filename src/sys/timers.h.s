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
;; PUBLIC ROUTINES
;;===============================================================================

.globl sys_util_timers_init
.globl sys_util_timers_update

;;===============================================================================
;; DATA TIMER STRUCTURE CREATION
;;===============================================================================
BeginStruct timer
Field timer, status , 1
Field timer, lapse  , 2
EndStruct timer

;;===============================================================================
;; TIMER STATUS
;;===============================================================================
e_timer_null    = 0x00
e_timer_active  = 0x01