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

.module timers_system

.include "system.h.s"
.include "common.h.s"
.include "cpctelera.h.s"
.include "sys/timers.h.s"
.include "man/array.h.s"


;;
;; Start of _DATA area 
;;
.area _DATA

timers::
DefineArray timer, 4, sizeof_timer

timerTpl:
.db #e_timer_active
.dw #0000

;;
;; Start of _CODE area
;; 
.area _CODE


;;-----------------------------------------------------------------
;;
;; sys_util_timers_init
;;
;;  Initilizes timers system
;;  Input: 
;;  Output: 
;;  Modified: 
;;
sys_util_timers_init::
    ld ix, #timers                  ;; initialize timers
    call man_array_init             ;;
ret

;;-----------------------------------------------------------------
;;
;; sys_util_timers_create_timer
;;
;;  Initilizes timers system
;;  Input: 
;;  Output: hl points to the new created timer
;;  Modified: 
;;
sys_util_timers_create_timer::
    ld ix, #timers                  ;; initialize timers
    ld hl, #timerTpl                ;;
    call man_array_create_element   ;;
ret

;;-----------------------------------------------------------------
;;
;; sys_util_timers_update
;;
;;  Initilizes timers system
;;  Input: 
;;  Output: 
;;  Modified: 
;;
sys_util_timers_update::
ret