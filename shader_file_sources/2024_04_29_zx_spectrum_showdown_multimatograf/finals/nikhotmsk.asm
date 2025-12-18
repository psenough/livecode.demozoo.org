    org 0x8000

    ld a,0
    out (254),a
    
    ld hl, 0x3d00 ; where the font is
    ld de, 0x5800 ; where the screen attributes are
    
    
;;;;;;;;;;;;;;;;;;;;;;;
; variables initialization here
;;;;;;;;;;;;;;;;;;;;;;;



loop


    ld de, 0x5800 ; TODO new location
    push hl
    ex hl,de
    
    ex hl,de
    pop hl
    
    push hl
    ld hl, (randomness)
    ld a, (hl)
    inc hl
    ld (randomness), hl
    ld (color_one), a
    pop hl
    
    push hl
    ld hl, (randomness)
    ld a, (hl)
    inc hl
    ld (randomness), hl
    ld (color_two), a
    pop hl
    
    push hl
    ld hl, (randomness)
    ld a, h
    and 0b00111111
    ld h, a
    ld (randomness), hl
    pop hl
    
    ld b, 8
draw_cycle_glyph:
    call draw_row
    push hl
    ex hl, de
    ld de, 32 - 8 ; advance to next row
    add hl, de
    ex hl,de
    pop hl
    
    dec b
    jr nz, draw_cycle_glyph
    
    ld de, 0x4000
    or a ; clear carry flag
    sbc hl, de
    add hl, de ; this is super cool word compare method
    jr c, draw_cycle_glyph_skip_no_wraparound
    ld hl, 0x3d00
draw_cycle_glyph_skip_no_wraparound:
    
    
    
    ld bc, 20000
busy_loop:
    dec bc
    ld a, b
    or c
    jr nz, busy_loop
    
    jr loop

;;;;;;;;;;;;;;;;;;;;;;;;;
; variables here
;;;;;;;;;;;;;;;;;;;;;;;;;
color_two: db 0b01000000
color_one: db 0b01111111
randomness: dw 0

;;;;;;;;;;;;;;;;;;
; draw_row
;;;;;;;;;;;;;;;;;;

draw_row:
    ld a, (hl)
    ;;;;;;;;;;;;;;;;
    ; draw column 0
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_0
    ld a, (color_two) ; color
color_skip_0:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 1
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_1
    ld a, (color_two) ; color
color_skip_1:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 2
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_2
    ld a, (color_two) ; color
color_skip_2:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 3
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_3
    ld a, (color_two) ; color
color_skip_3:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 4
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_4
    ld a, (color_two) ; color
color_skip_4:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 5
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_5
    ld a, (color_two) ; color
color_skip_5:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 6
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_6
    ld a, (color_two) ; color
color_skip_6:
    ld (de), a
    pop af
    inc de
    ;;;;;;;;;;;;;;;;
    ; draw column 7
    ;;;;;;;;;;;;;;;;
    or a ; clear carry flag
    rlca
    push af
    ld a, (color_one) ; color
    jr c, color_skip_7
    ld a, (color_two) ; color
color_skip_7:
    ld (de), a
    pop af
    inc de
    inc hl
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
    inc h 
    ld a, h 
    and #07 
    ret nz 
    ld a, l 
    sub #e0 
    ld l, a 
    sbc a, a 
    and #f8 
    add a, h 
    ld h, a 
    ret

;----------------------------------------
; Previous screen line address in HL
;----------------------------------------
up_hl	
    dec h 
    ld a, h 
    cpl 
    and #07 
    ret nz 
    ld a, l 
    sub #20 
    ld l, a 
    ret c 
    ld a, h 
    add a, #08 
    ld h, a 
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
    rlca : rlca : rlca
    xor  h
    and  #c7
    xor  h
    rlca : rlca
    ld   l, a
    ld   a, h
    and  #c0
    inc  a
    rra : rra : rra
    xor  h
    and  #f8
    xor  h
    ld   h, a
    ld   a, c
    and 7
    ret

;----------------------------------------
; in:  HL = addr in screen [4000..57FF]
; out: HL = addr in attrs [5800..5AFF]
;----------------------------------------
scr_to_attrs
    ld   a, h
    rrca : rrca : rrca
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
    add  a, e
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    ret

    align 8
pixel_tbl 
    db   #80,#40,#20,#10,#08,#04,#02,#01

;----------------------------------------
; in:  none
; out: HL = random 16bit value
;----------------------------------------
rnd16
.sd equ  $+1
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
.st ld  (.sd), hl
    ret
    
;----------------------------------------
; in:  IX = addr of 256b buffer
; out: generated sin table
;----------------------------------------
gen_sin
    ld   de, #7fbc
    ld   hl, #ff7f
.g0 ld   a, d
    xor  #80 ; uncomment for unsigned
    ld   (ix), a
    xor  #80 ; uncomment for unsigned
    rla
    sbc  a, a
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
    sra b : rra
    sra b : rra
    sra b : rra
    ld   c, a
    ;or   a
    sbc  hl, bc
    ex   de, hl
    inc  ixl
    jr   nz, .g0
    ret
