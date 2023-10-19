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

;;===============================================================================
;; INTERRUPT MACROS
;;===============================================================================
.mdelete m_inc_nInterrupt
.macro m_inc_nInterrupt
    ;;ld a, (nInterrupt)
    ;;inc a
    ;;ld (nInterrupt), a 
    ld hl, #nInterrupt
    inc (hl)
.endm



;;===============================================================================
;; STRUCT MACROS
;;===============================================================================
.mdelete BeginStruct
.macro BeginStruct struct
    struct'_offset = 0
.endm

.mdelete Field
.macro Field struct, field, size
    struct'_'field = struct'_offset
    struct'_offset = struct'_offset + size
.endm

.mdelete EndStruct
.macro EndStruct struct
    sizeof_'struct = struct'_offset
.endm

;;===============================================================================
;; Macro
;;
;; Macro modified from cpctelera cpctm_screenPtr_asm
;;===============================================================================

.mdelete m_center_screen_ptr 
.macro m_center_screen_ptr REG16, VMEM, Y, WIDTH
   ld REG16, #VMEM + 80 * (Y / 8) + 2048 * (Y & 7) + ((80 - WIDTH)/2)   ;; [3] REG16 = screenPtr
.endm

;;===============================================================================
;; MACRO
;;===============================================================================
.mdelete ld_de_backbuffer
.macro ld_de_backbuffer
   ld   a, (sys_render_back_buffer)          ;; DE = Pointer to start of the screen
   ld   d, a
   ld   e, #00
.endm

.mdelete ld_de_frontbuffer
.macro ld_de_frontbuffer
   ld   a, (sys_render_front_buffer)         ;; DE = Pointer to start of the screen
   ld   d, a
   ld   e, #00
.endm

.mdelete m_screenPtr_backbuffer
.macro m_screenPtr_backbuffer X, Y
   push hl
   ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
   ld a, (sys_render_back_buffer)
   ld h, a
   ld l, #0         
   add hl, de
   ex de, hl
   pop hl
.endm

.mdelete m_screenPtr_frontbuffer
.macro m_screenPtr_frontbuffer X, Y
   push hl
   ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
   ld a, (sys_render_front_buffer)
   ld h, a
   ld l, #0         
   add hl, de
   ex de, hl
   pop hl
.endm


.mdelete m_draw_blank_small_number
.macro m_draw_blank_small_number
   push de
   push hl
   ld c, #6
   ld b, #5
   ld a, #0                         ;; Patern of solid box
   call cpct_drawSolidBox_asm
   pop hl
   pop de
.endm

;;===============================================================================
;; ENTITY DEFINITION MACRO
;;===============================================================================
.mdelete DefineEntity
.macro DefineEntity _cpms, _ptr, _type, _color, _x, _y, _w, _h, _vxh, _vxl _vyh, _vyl, _sprite, _address, _p_address, _collsion_callback, _ai_callback
    .dw _ptr
    .db _cpms
    .db _type
    .db _color
    .dw _x
    .dw _y
    .db _w
    .db _h
    .db _x+_w
    .db _y+_h
    .db #0
    .db #0
    .db _vxh
    .db _vxl
    .db _vyh
    .db _vyl
    .dw _sprite
    .dw _address
    .dw _p_address
    .db #0
    .dw _collsion_callback
    .db #0
    .dw _ai_callback
    .db #1           ;; moved 1 default
.endm

;;==============================================================================================================================
;;==============================================================================================================================
;;  MACRO FOR ENUM DEFINITIONS
;;==============================================================================================================================
;;==============================================================================================================================
.mdelete DefEnum
.macro DefEnum _name
    _name'_offset = 0
.endm

;;  Define enumeration element for an enumeration name.
.mdelete Enum
.macro Enum _enumname, _element
    _enumname'_'_element = _enumname'_offset
    _enumname'_offset = _enumname'_offset + 1
.endm

;;==============================================================================================================================
;;==============================================================================================================================
;;  DEFINE LINKED LIST STRUCTURE
;;==============================================================================================================================
;;==============================================================================================================================

;;  Defines the structure for a basic memory manager.
.mdelete DefineBasicStructureArray_Size
.macro DefineBasicStructureArray_Size _Tname, _N, _ComponentSize
    _Tname'_array::
        .ds _N * _ComponentSize
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Defines the structure of the entity array.
.mdelete DefineComponentArrayStructure_Size
.macro DefineComponentArrayStructure_Size _Tname, _N, _ComponentSize
    _Tname'_num::         .db 0
    _Tname'_list::        .dw nullptr
    _Tname'_free_list::   .dw _Tname'_array
    _Tname'_array::
        .ds _N * _ComponentSize
.endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Defines the structure for the component handler.
.mdelete DefineComponentPointerTable
.macro DefineComponentPointerTable _Tname, _N_Cmps, _N
    _c = 0
    ;;  Array containing pointers to component pointer arrays.
    _Tname'_access_table::
    .rept _N_Cmps
        DefineComponentPointerAccessTable _Tname, \_c, _N, _N_Cmps
        _c = _c + 1
    .endm
    ;;  Zero-fill the component array with two additional words for the
    ;;  next free position and a null pointer fot he end of the array.
    _Tname'_components::
   .rept _N_Cmps
        DefineComponentArray _N
        .dw 0x0000
        .dw 0x0000
    .endm
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Defines the pointers of the componente array pointer access table.
.mdelete DefineComponentPointerAccessTable
.macro DefineComponentPointerAccessTable _Tname, _suf, _N, _N_Cmps
    _Tname'_components'_suf'_ptr_pend::    .dw . + 2*_N_Cmps+ + _suf*2*_N + 2*_suf
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Zero-pad an array of size n.
.mdelete DefineComponentArray
.macro DefineComponentArray _N
    .rept _N
        .dw 0x0000
    .endm
.endm

;; WinAPE special BRK instruction
;; - more info at http://www.winape.net/help/debug.html
.mdelete BREAKPOINT
.macro BREAKPOINT
  .db #0xed, #0xff
.endm
