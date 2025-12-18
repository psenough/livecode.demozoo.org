    org 0x8000

    ld ix, sintable
    call gen_sin
    
    ld hl, #5800
    ld de, #5801
    ld bc, #02ff
    ld (hl), l
    ldir

loop
    ei
    halt
    ld a, 0
    out (254), a

counter: equ $+1
    ld a, 0


    ld b, 192
sfloop:
    push bc


    ; TODO
    ld a, 192
    sub b
    ld h, a

    ld e, a
    ld d, 5
    ld a, (de)
    ld l, a             ; coord Y

    and 3
    jr z, mx0
    dec a
    jr z, mx1
    dec a
    jr z, mx2
mx2
    ld a, (counter)
    add a, a
    add a, a
    add a, a
    jr set_x    
    
mx1
    ld a, (counter)
    add a, a
    add a, a
    jr set_x

mx0
    ld a, (counter)
    add a, a

set_x:
    add a, l
    cpl
    ld l, a             ; coord X
    
    call set_point
    inc l
    ld (hl), 0
    push hl
    
    call scr_to_attrs
    ld a, r
    and 7
    or #44
    ld (hl), a
    
    pop hl
    ld a, l
    and %11100000
    ld l, a
    ld (hl), 0

    pop bc
    djnz sfloop

;----------------------------------


    ld b, 192
    ld hl, #4005
wloop:
    push bc
    push hl
    
    
    ld a, (counter)
    rrca
    rrca
    and 7
    ld de, pulse
    ld e, a
    ld a, (de)
    ;ld (hl), a          ; pulse
    ld (cx1), a


    ld de, sintable
    ld a, (counter)
    and %00001110
    rrca : rrca : rrca : rrca
    add a, b
    ld e, a
    ld a, (de)
    
    ;inc l
    ;inc l
    ;ld (hl), a          ; bsin
    ld (cx2), a

    ld a, (counter)
    and %00000111
    rrca :rrca :rrca
    add a, b
    ld e, a
    ld a, (de)
    
    ;inc l
    ;inc l
    ;ld (hl), a         ; msin
    ld (cx3), a


    ld d, 6    
    ld a, (de)
    
    inc l 
    inc l
    ;ld (hl), a          ; musor
    ;ld (cx4), a


;cx4: equ $+1
;    add a, 0

cx1: equ $+1
    ld a, 0
cx2: equ $+1
    add a, 0
cx3: equ $+1
    add a, 0

    and %11111000
    rrca : rrca : rrca
    ld (hl), a
    ld c, a
    
    ld a, r
    and 3
    add a, c
    or #90
    ld d, a
    ld e, 0
    ld (#4000), de
    ex de, hl
    push hl
    ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi
    pop hl
    ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi
    



    
    pop hl
    call down_hl

    pop bc
    djnz wloop



    ld hl, counter
    inc (hl)
    
    xor a
    out (254), a
    jp loop


    align 256
pulse:
    db 19,18,17,16,15,14,13,12


    align 256
sintable:
    ds 256



    org #9000

    ; 0 
    align 256
    db #00,#00,#00,#01,#80,#00,#00,#00
    align 256
    db #00,#00,#00,#03,#c0,#00,#00,#00
    align 256
    db #00,#00,#00,#07,#e0,#00,#00,#00
    align 256
    db #00,#00,#00,#0f,#f0,#00,#00,#00

    ; 4
    align 256
    db #00,#00,#00,#1f,#f8,#00,#00,#00
    align 256
    db #00,#00,#00,#3f,#fc,#00,#00,#00
    align 256
    db #00,#00,#00,#7f,#fe,#00,#00,#00
    align 256
    db #00,#00,#00,#ff,#ff,#00,#00,#00

    ; 8
    align 256
    db #00,#00,#03,#ff,#ff,#c0,#00,#00
    align 256
    db #00,#00,#0f,#ff,#ff,#f0,#00,#00
    align 256
    db #00,#00,#3f,#ff,#ff,#fc,#00,#00
    align 256
    db #00,#00,#ff,#ff,#ff,#ff,#00,#00

    ; 12
    align 256
    db #00,#03,#ff,#ff,#ff,#ff,#00,#00
    align 256
    db #00,#0f,#ff,#ff,#ff,#ff,#c0,#00
    align 256
    db #00,#3f,#ff,#ff,#ff,#ff,#fc,#00
    align 256
    db #00,#ff,#ff,#ff,#ff,#ff,#ff,#00

    ; 16
    align 256
    db #03,#ff,#ff,#ff,#ff,#ff,#ff,#c0
    align 256
    db #0f,#ff,#ff,#ff,#ff,#ff,#ff,#f0
    align 256
    db #3f,#ff,#ff,#ff,#ff,#ff,#ff,#fc
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff

    ; 20
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff





    align 256
    
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
