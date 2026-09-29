
/*                |                     |    o
   ,---.,   ..   .|__/ ,---.,--.--.,---.|--- .,---.
   |   ||   ||   ||  \ |   ||  |  |,---||    ||
   `   '`---|`---'`   ``---'`  '  '`---^`---'``---'
        `---'              :.by..stardust..2025.:   */

; default org = $6000 (any address within $6000..$ff00 is fine)
; esc: toggle editor | f1: options | f5: recompile | f12: reset

	org $6000

;1	inc a : and 7:out (254),a : jr 1b


loop	ld hl, $5800
	ld de, $5801
	ld bc, 767
	ld a,5
	out ($fe), a
	.3 add a
	ld (hl), a
	ldir
;	jr loop

	di
	ld	a,#c3,i,a
	ld	hl,int,(#c3c4),hl
	im	2
	ei

lpp
	halt

	ld	b,32
line	push	bc

	halt

	ld	a,0
cnt2	equ	$-1
	inc	a
	and	31
	ld	(cnt2),a
	ld	hl,scrtbl
	add	a
	ld	l,a
	ld	e,(hl):inc l:ld d,(hl)

	ld	a,e:add a,b:ld e,a

;	ld	a,"A"
	call	rnd16
	add	a
	add	a
	add	a
	ld	h,high 15616+1 , l,a
	dup	8
	ld	a,(hl),(de),a : inc l,d
	edup

	pop	bc
	dec	b
	jp	nz,line

	jp	lpp
;----------------------------------------
int
	push	hl,de,bc,af
	ld	a,0
cnt	equ	$-1
	inc	a
	and	7
	ld	(cnt),a
	add	a
	ld	c,a,b,0,hl,fout
	add	hl,bc
	ld	e,(hl) : inc hl
	ld	d,(hl)
	exd
	ld	(save_sp),sp
	ld	de,#0800

	dup	3
	ld	sp,hl

	ld	bc,0
	dup	128
	push	bc
	edup
	add	hl,de
	edup
	
	ld	sp,0
save_sp	equ	$-2
	pop	af,bc,de,hl

	ei
	ret


fout
	dw	#40ff+1
	dw	#44ff+1
	dw	#42ff+1
	dw	#46ff+1
	dw	#41ff+1
	dw	#45ff+1
	dw	#43ff+1
	dw	#47ff+1


	org	#c300
	block	257,#c3
	

	align	256

scrtbl
	block	16
	
	dw	#4000
	dw	#4020
	dw	#4040
	dw	#4060
	dw	#4080
	dw	#40a0
	dw	#40c0
	dw	#40e0

	dw	#4800
	dw	#4820
	dw	#4840
	dw	#4860
	dw	#4880
	dw	#48a0
	dw	#48c0
	dw	#48e0
	
	dw	#5000
	dw	#5020
	dw	#5040
	dw	#5060
	dw	#5080
	dw	#50a0
	dw	#50c0
	dw	#50e0

	align	256
txtbuff
	block	32

	align	256
coords
	block	32
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
	push	hl,de,af
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
	pop	af,de,hl
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
