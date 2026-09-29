
/*                |                     |    o
   ,---.,   ..   .|__/ ,---.,--.--.,---.|--- .,---.
   |   ||   ||   ||  \ |   ||  |  |,---||    ||
   `   '`---|`---'`   ``---'`  '  '`---^`---'``---'
        `---'              :.by..stardust..2025.:   */

; default org = $6000 (any address within $6000..$ff00 is fine)
; esc: toggle editor | f1: options | f5: recompile | f12: reset

	org $6000


	ld hl, $5800
	ld de, $5801
	ld bc, 767
	ld a, 0
	and 7
	out ($fe), a
	.3 add a
	ld (hl), a
	ldir



	ei

loop
	halt
	call write_field
	
	jr loop
	
write_field:
	ld ix, table
	ld b, table_size
write_field_loop:
	push bc
	call un_write_box
	call move_box
	call write_box
	pop bc
	ld de, entry_size
	add ix, de
	dec b
	jr nz, write_field_loop
	
	ret

table_size: .equ 22
entry_size: .equ entry_one - table
table:
	;;; cube 000
	dw 0x5800 + 256	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 3		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7
entry_one
	;;; cube 001
	dw 0x5824 + 256	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 002
	dw 0x5835 + 256	;;; attr address	;;; 0
	db 0b01101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 003
	dw 0x5841 + 256	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 004
	dw 0x5811 + 256	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 005
	dw 0x581f + 256	;;; attr address	;;; 0
	db 0b01101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 006
	dw 0x5900 + 256	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 007
	dw 0x5911 + 256	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 008
	dw 0x5930 + 256	;;; attr address	;;; 0
	db 0b01101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 009
	dw 0x5802 + 256	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 6		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7
	;;; cube 010
	dw 0x5824 + 0  	;;; attr address	;;; 0
	db 0b01111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 011
	dw 0x5800 + 200	;;; attr address	;;; 0
	db 0b01101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 012
	dw 0x5841 +   8	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7
	;;; cube 013
	dw 0x5824 +  30	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 014
	dw 0x5835 + 45 	;;; attr address	;;; 0
	db 0b01101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 015
	dw 0x5841 + 51 	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7
	;;; cube 016
	dw 0x5824 + 66 	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 017
	dw 0x5835 + 0	;;; attr address	;;; 0
	db 0b00111101 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 8		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 018
	dw 0x5841 + 402	;;; attr address	;;; 0
	db 0b01011001 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7
	;;; cube 019
	dw 0x5824 + 412	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 4		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 020
	dw 0x5835 + 121	;;; attr address	;;; 0
	db 0b11101001 	;;; color		;;; 2
	db 1		;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; cube 021
	dw 0x5841 + 112	;;; attr address	;;; 0
	db 0b11111000 	;;; color		;;; 2
	db 10	;;; timer running	;;; 3
	db 2		;;; timer set		;;; 4
	dw 1		;;; speed		;;; 5
	dw 1		;;; enable		;;; 7

	;;; total 22 cobes



;;; IX - pointer to table
un_write_box:
	ld a, 0 ; black
	jr unwrite_box_skip
write_box:
	ld a, (ix + 2)
unwrite_box_skip:

	ld d, a
	ld a, (ix + 7)
	and a
	ret z
	ld a, d

	ld hl, (ix + 0)
	ld (hl), a ;;; write to screen
	ret
	
move_box:
	ld a, (ix + 3)
	dec a
	ld (ix + 3), a
	ret nz
	ld a, (ix + 4)
	ld (ix + 3), a
	ld hl, (ix + 0)
	ld de, (ix + 5)
	ld a, l
	and 0b00011111
	cp 31
	jr nz, no_right_border
	ld de, -1
	ld (ix + 5), de
no_right_border:

	ld a, l
	and 0b00011111
	jr nz, no_left_border
	ld de, 1
	ld (ix + 5), de
no_left_border:

	add hl, de
	ld (ix + 0), hl ;;; box moved
	ret

;----------------------------------------
; Snippets:
;  down_hl
;  up_hl
;  hl_to_scr
;  scr_to_attrs
;  set_point
;  rnd16
;  gen_sin
;----------------------------------------

;----------------------------------------
; Next screen line address in HL
;----------------------------------------
down_hl
	inc  h
	ld   a, h
	and  #07
	ret  nz
	ld   a, l
	sub  #e0
	ld   l, a
	sbc  a
	and  #f8
	add  h
	ld   h, a
	ret

;----------------------------------------
; Previous screen line address in HL
;----------------------------------------
up_hl
	dec  h
	ld   a, h
	cpl
	and  #07
	ret  nz
	ld   a, l
	sub  #20
	ld   l, a
	ret  c
	ld   a, h
	add  #08
	ld   h, a
	ret

;----------------------------------------
; in:  L = x [0..255]
;      H = y [0..191]
; out: HL = addr in screen [4000..57FF]
;      C = pixel number [0..7]
;----------------------------------------
hl_to_scr
	ld   c, l
	ld   a, l
	.3   rlca
	xor  h
	and  #c7
	xor  h
	.2   rlca
	ld   l, a
	ld   a, h
	and  #c0
	inc  a
	.3   rra
	xor  h
	and  #f8
	xor  h
	ld   h, a
	ld   a, c
	and  7
	ret

;----------------------------------------
; in:  HL = addr in screen [4000..57FF]
; out: HL = addr in attrs [5800..5AFF]
;----------------------------------------
scr_to_attrs
	ld   a, h
	.3   rrca
	and  #03
	or   #58
	ld   h, a
	ret

;----------------------------------------
; in:  L = x [0..255]
;      H = y [0..191]
;----------------------------------------
set_point
	call hl_to_scr
	ld   de, pixel_tbl
	add  e
	ld   e, a
	ld   a, (de)
	ld   (hl), a
	ret

	align 8
pixel_tbl
	db #80,#40,#20,#10,#08,#04,#02,#01

;----------------------------------------
; in:  none
; out: HL = random 16bit value
;----------------------------------------
rnd16
.sd	equ  $+1
	ld   de, 0
	ld   a, d
	ld   h, e
	ld   l, 253
	or   a
	sbc  hl, de
	sbc  a, 0
	sbc  hl, de
	ld   d, 0
	sbc  a, d
	ld   e, a
	sbc  hl, de
	jr   nc, .st
	inc  hl
.st	ld  (.sd), hl
	ret

;----------------------------------------
; in:  IX = addr of 256b buffer
; out: generated sin table
;----------------------------------------
gen_sin
	ld   de, #7fbc
	ld   hl, #ff7f
.g0	ld   a, d
	xor  #80 ; uncomment for unsigned
	ld   (ix), a
	xor  #80 ; uncomment for unsigned
	rla
	sbc  a
	ld   b, a
	ld   c, d
	adc  hl, bc
	rr   c
	rrca
	rr   c
	add  hl, bc
	ld   b, h
	ld   a, l
	ex   de, hl
	sra  b: rra
	sra  b: rra
	sra  b: rra
	ld   c, a
	; or   a
	sbc  hl, bc
	ex   de, hl
	inc  ixl
	jr   nz, .g0
	ret
