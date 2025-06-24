


    org 0x8000

    ld ix, sin_table
    call gen_sin

loop

.counter: equ $+1
    ld a, 0
    inc a
    ld (.counter), a


    ld hl, sin_table
    ld l, a
    ld a, (hl)

    and %00011100
    rrca : rrca
    ld (.bglow), a

    /*
    ld a, (.counter)
    add a, 64
    ld hl, sin_table
    ld l, a
    ld a, (hl)

    and %11110000
    rlca :rlca :rlca :rlca
    or #a0
    ;ld (.bghigh), a
    */
    
    ld b, 3
    ld de, #5800

.bgloop:
    push bc

.bglow equ $+1
.bghigh equ $+2
    ld hl, bg    
    ld bc, 256
    ldir
    
    pop bc
    djnz .bgloop



    di
    ld (.sp), sp




    ld hl, wave
    ld de, #4008

    ld a, (.counter)
    ld (.temp), a
    
    ld b, 192
.waveloop:   
    push bc
    

.temp: equ $+1
    ld a, 0
    inc a
    ld (.temp), a
    
    ld hl, sin_table
    ld l, a
    ld a, (hl)
    and %00111000
    rrca :rrca :rrca

    ;ld (#4000), a
    
    ld hl, wave
    or #90
    ld h, a
    
    ld a, (.counter)
    ld b, 0
    ld c, a
    ld a, (bc)
    and 3
    add a, h
    ld h, a

    push de
    ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi
    ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi
    pop de
    
     ex de, hl
     call down_hl
     ex de, hl

     pop bc
     djnz .waveloop

    
    
    
.sp equ $+1
    ld sp, 0
    ei

    jp loop



sin_table: equ #8800


    org #8800
pulse:
    db 5,4,3,2,2,1,0,0


    org #9000
wave:
    align 256
    db #00,#00,#00,#00,#00,#00,#00,#0f,#f0,#00,#00,#00,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#00,#00,#00,#00,#ff,#ff,#00,#00,#00,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#00,#00,#00,#0f,#ff,#ff,#f0,#00,#00,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#00,#00,#00,#ff,#ff,#ff,#ff,#00,#00,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#00,#00,#0f,#ff,#ff,#ff,#ff,#f0,#00,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#00,#00,#ff,#ff,#ff,#ff,#ff,#ff,#00,#00,#00,#00,#00

    align 256
    db #00,#00,#00,#00,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#00,#00,#00,#00
    align 256
    db #00,#00,#00,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#00,#00,#00

    /*

    align 256
    db #00,#00,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#00,#00,#00
    align 256
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#00

    */
    





q   equ #57
w   equ #4F
y   equ #03

    org #a000
bg:
    db q,q,q,q,y,w,w,w
    db q,q,q,q,y,w,w,w
    db q,q,q,q,y,w,w,w
    db q,q,q,q,y,w,w,w

    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y

    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y

    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y
    db q,q,q,q,w,y,y,y


    db 0,w,w,w,q,q,q,q
    db 0,w,w,w,q,q,q,q
    db 0,w,w,w,q,q,q,q
    db 0,w,w,w,q,q,q,q

    db 0,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q

    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q

    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q
    db w,0,0,0,q,q,q,q






    
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
