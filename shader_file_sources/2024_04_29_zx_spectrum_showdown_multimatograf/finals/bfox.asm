    org 0x8000

atrbuf1     equ #a000
atrbuf2     equ #a800
atrbuf3     equ #b000

loop
    call    one
    call    two

    halt










    ld  l,0
    ld  de,#5800
    ld  lx,atrbuf1/256
    ld  c,atrbuf2/256
    ld  b,atrbuf3/256
    ld  hx,3
prnt1
    ld  a,lx : ld  h,a
    ld  a,(hl)
    ld  h,c
    or  (hl)
    ld  h,b
    or  (hl)
    ld  (de),a
    inc de
    inc l
    jp  nz,prnt1
    inc h
    inc lx
    inc c
    inc b
    dec hx
    jp  nz,prnt1

    jr  loop

;---------------------------------------
one
        ld  a,1
txt1    equ $-1
        dec a
        ld  (txt1),a
        jr  nz,nxt1
        ld  a,8
        ld  (txt1),a

        ld  hl,text1-1
tx1     equ $-2
        inc hl
        ld  a,(hl)  : or a
        jr  nz,tt1
        ld  hl,text1-1
tt1     ld  (tx1),hl

        ld  l,(hl)
        ld  h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld  bc,15616-256
        add hl,bc
        ld  de,txt1buf
        ldi:ldi:ldi:ldi:ldi:ldi:ldi:ldi
nxt1

        ld  hl,atrbuf1+1
        ld  de,atrbuf1
        ld  a,255
ld1     ldi
        dec a
        jp  nz,ld1

        ld  hl,txt1buf
        ld  de,atrbuf1+31
        ld  b,8
lp1
        rlc (hl)
        inc hl
        sbc a,a
        and 4*8+64
        ld  (de),a
        ld  a,32
        add a,e
        ld  e,a
        djnz    lp1
        ret
;--------------------------
two
        ld  a,1
txt2    equ $-1
        dec a
        ld  (txt2),a
        jr  nz,nxt2
        ld  a,8
        ld  (txt2),a

        ld  hl,text2-1
tx2     equ $-2
        inc hl
        ld  a,(hl)  : or a
        jr  nz,tt2
        ld  hl,text2-1
tt2     ld  (tx2),hl

        ld  l,(hl)
        ld  h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld  bc,15616-256
        add hl,bc
        ld  de,txt2buf
        ldi:ldi:ldi:ldi:ldi:ldi:ldi:ldi
nxt2

        ld  hl,atrbuf2+1
        ld  de,atrbuf2
        ld  a,255
ld2     ldi
        dec a
        jp  nz,ld2

        ld  hl,txt2buf
        ld  de,atrbuf2+31
        ld  b,8
lp2
        rlc (hl)
        inc hl
        sbc a,a
        and 1*8+64
        ld  (de),a
        ld  a,32
        add a,e
        ld  e,a
        djnz    lp2
        ret

                
        
        jr  $
        
text1   db  " MULTIMATOGRAF          ",0,0
text2   db  "               DEMOPARTY ",0,0

txt1buf equ #c000
txt2buf equ #c100
txt3buf equ #c200
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
