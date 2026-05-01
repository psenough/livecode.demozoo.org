
/*                |                     |    o
   ,---.,   ..   .|__/ ,---.,--.--.,---.|--- .,---.
   |   ||   ||   ||  \ |   ||  |  |,---||    ||
   `   '`---|`---'`   ``---'`  '  '`---^`---'``---'
        `---'              :.by..stardust..2025.:   */

; default org = $6000 (any address within $6000..$ff00 is fine)
; esc: toggle editor | f1: options | f5: recompile | f12: reset

	org $6000           

	call init
	
frameloop:
	ei
	halt
	call present
	call sc_switch	
	ld hl, (scene_ptr)
	call call_hl
		
	jr frameloop



call_hl:
	jp (hl)



init:
	ld ix, sin_table
	call gen_sin
	
	ld hl, #4000
	ld de, #4001
	ld bc, #17ff
	ld (hl), %00111110
	ldir
	/*
	ld hl, 0
	ld de, #4000
	ld bc, #1800
	ldir
	*/
	ret



present:
	ld hl, buffer
	ld de, #5800
	ld a, 24
.loop:
	dup 32
	  ldi
	edup
	ld l, 0
	inc h

	dec a
	jr nz, .loop


	ld a, r
	and 0
	out (254), a
	ret



counter: 	db 0
scene_ptr: 	dw scene0
;pal_ptr:	dw palette1


sc_switch:
	ld hl, counter
	inc (hl)
	;ret
	
	/*
	ld a, (hl)
	and %00111111
	ret nz
.do_switch:	
	ld hl, (scene_ptr)
	inc l
	inc l
	
	ld a, l
	and 0		; scene limit
	ld l, a
	
	ld (scene_ptr), hl
	ret	
	*/


pal_switch:
	ld a, (counter)
	and %000111111
	ret nz

	ld a, (pal_ptr + 1)
	inc a
	and #73
	ld (pal_ptr + 1), a	
	ret



prepare:
	ret



scene0:
	ld ix, sin_table
	ld a, (counter)
	ld ixl, a
		

	ld hl, buffer
pal_ptr: equ $+1
	ld de, palette1

	
	ld c, 24
.vloop:
	ld a, (ix)
	rlca
	rlca
	rlca
	rlca
	rlca
	and %00011111
	ld e, a
	
	
	ld b, 32
.hloop:
	ld a, (de)
	ld (hl), a : inc l
	
	ld a, e
	inc a
	and 15
	ld e, a
	djnz .hloop	
	
	inc h
	ld l, 0

	inc ixl	
	
	dec c
	jr nz, .vloop
	
	
		
	;ld a, (counter)
	;ld (buffer + 31), a
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



	org #7000
palette1:
	db 007o, 017o, 026o, 036o, 045o, 055o, 064o, 074o
	db 101o, 111o, 122o, 132o, 143o, 153o, 164o, 174o
	

	align 256
palette2:
	db 127o, 132o, 112o, 001o, 145o, 151o, 017o, 000o	
	db 127o, 132o, 112o, 001o, 145o, 151o, 017o, 000o


	align 256
palette3:
	db 007o, 02o, 122o, 033o, 133o, 155o, 116o, 011o
	db 017o, 117o, 155o, 133o, 033o, 122o, 026o, 000o


	align 256
palette4:
	db 060o, 061o, 151o, 151o, 051o, 1, 1, 1
	db 032o, 032o, 132o, 132o, 062o, 2, 2, 2




	org #7800
sin_table:
	ds 256





	org #c000
buffer:
	db #11,#22
	ds 256 * 24




