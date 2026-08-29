    ; hi
    ; nyuk here
    ; u menya konchilis idei :-)
    
    org 0x8000

    ld a,0
    out (254),a
    
    ld hl, #5800
    ld de, #5801
    ld bc, #02ff
    ld (hl), l
    ldir
    
    ld hl, 0
    ld de, #4000
s1   
    ld a, (hl)
    and %00111100
    ld (de), a
    inc hl
    inc de
    ld a, d
    cp #58
    jr nz, s1
    
loop
    call mtx

    halt
    ld a, %01000010
    ld (logoC + 1), a
    call logo

    halt
    ld a, %01000010
    ld (logoC + 1), a
    call logo

    jr loop


logo
    ld a, #00 : call lOne
    ld a, #07 : call lOne
    
    ld a, #20 : call lOne
    ld a, #21 : call lOne
    ld a, #26 : call lOne
    ld a, #27 : call lOne
    
    ld a, #40 : call lOne
    ld a, #41 : call lOne
    ld a, #42 : call lOne
    ld a, #45 : call lOne
    ld a, #46 : call lOne
    ld a, #47 : call lOne

    ld a, #60 : call lOne
    ld a, #61 : call lOne
    ld a, #62 : call lOne
    ld a, #63 : call lOne
    ld a, #64 : call lOne
    ld a, #65 : call lOne
    ld a, #66 : call lOne
    ld a, #67 : call lOne

    ld a, #80 : call lOne
    ld a, #81 : call lOne
    ld a, #82 : call lOne
    ld a, #83 : call lOne
    ld a, #84 : call lOne
    ld a, #85 : call lOne
    ld a, #86 : call lOne
    ld a, #87 : call lOne

    ld a, #a0 : call lOne
    ld a, #a1 : call lOne
    ld a, #a2 : call lOne
    ld a, #a3 : call lOne
    ld a, #a4 : call lOne
    ld a, #a5 : call lOne
    ld a, #a6 : call lOne
    ld a, #a7 : call lOne
    
    ld a, #c0 : call lOne
    ld a, #c1 : call lOne
    ld a, #c2 : call lOne
    ld a, #c3 : call lOne
    ld a, #c4 : call lOne
    ld a, #c5 : call lOne
    ld a, #c6 : call lOne
    ld a, #c7 : call lOne

    ld a, #e1 : call lOne
    ld a, #e2 : call lOne
    ld a, #e3 : call lOne
    ld a, #e4 : call lOne
    ld a, #e5 : call lOne
    ld a, #e6 : call lOne

    ret
    
lOne
    ld h, #48
    add 12
    ld l, a
    push hl
    
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), %11111110 : inc h
    ld (hl), 0

    pop hl
    ld de, #5900 - #4800
    add hl, de

logoC
    ld (hl), %01000010
    
    ret
    
    
mtx
    ld b, 32
    ld iy, ADDR
    ld ix, SPD
    ld hl, #5800 - 32
mtl
    push hl
    call mtxOne
    pop hl
    inc l
    inc iy
    inc ix
    djnz mtl
    ret
    
mtxOne
    ld a, (iy + 0)
    add (ix + 0)
    cp 62
    jr c, mtm1
    xor a
mtm1
    ld (iy + 0), a
    ld de, 32
mt0 add hl, de
    dec a
    jr nz, mt0
    
    ld de, -32
    
    ld a, h : cp #5c : jp z, mte    
    
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %01000111

    add hl, de
    ld a, h : cp #5c : jp z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %01000100

    add hl, de
    ld a, h : cp #5c : jp z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %01000100

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %00000100

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %01000001

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), %00000001

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), 0

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), 0

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), 0

    add hl, de
    ld a, h : cp #5c : jr z, mte
    ld a, (hl) : cp %01000010 : jr z, $+4
    ld (hl), 0
    
mte    ret
    
ADDR 
    db 01, 22, 33, 11, 17, 08, 34, 27
    db 07, 12, 43, 05, 04, 28, 36, 03
    db 10, 04, 47, 25, 14, 31, 03, 23
    db 20, 11, 13, 15, 24, 09, 13, 33
    

SPD 
    db 1, 2, 3, 1, 1, 2, 1, 3
    db 1, 2, 2, 1, 3, 2, 1, 1
    db 1, 2, 2, 3, 1, 2, 1, 1
    db 1, 3, 2, 1, 1, 3, 1, 1
    
