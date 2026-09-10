    ; HI!
    ; nyuk here agains!
    
    org 0x8000

    call fill
    call fill2
    
    ld a,0
    out (254),a
    
    ld hl, #5800
    ld de, #5801
    ld bc, #02ff
    ld (hl), %01000111
    ldir
    
loop
    call rl0
    call rl0
    call rl0
    call mve
    halt
    call rl0
    call rl0
    call rl0
    call rl0
    halt

    call rl0
    call rl0
    call rl0
    call rl0
    call mve
    halt
    call rl0
    call rl0
    call rl0
    call rl0
    halt

    call rl0
    call rl0
    call rl0
    call mve2
    halt
    call rl0
    call rl0
    call rl0
    call rl0
    halt

    call rl0
    call rl0
    call rl0
    call rl0
    call mve2
    halt
    call rl0
    call rl0
    call rl0
    call rl0
    halt
    
    jr loop

mve
    ld hl, #9000
    push hl
    ld de, #5900 - 32
    ld bc, 256 + 32
    ldir
    pop hl
    inc hl
    ld a, l : and %00011111
    ld (mve+1), a
    ld (mve2+1), a
    ret

mve2
    ld hl, #a000
    push hl
    ld de, #5900 - 32
    ld bc, 256 + 32
    ldir   
    pop hl
    inc hl
    ld a, l : and %00011111
    ld (mve+1), a
    ld (mve2+1), a
    ret
    
fill    
    ld hl, #9000
    ld de, #9001
    ld (hl), %01000111
    ld bc, 512
    ldir
    ld hl, #9000
    ld a, %01011011
    call f1
    ret

fill2    
    ld hl, #a000
    ld de, #a001
    ld (hl), %01000111
    ld bc, 512
    ldir
    ld hl, #a000
    ld a, %01110110
    call f1
    
    ld a, %01000111
    ld (#a0f1), a
    ld (#a0f2), a
    ld (#a0f3), a    
    ret
    
f1  ld l, #32 : ld (hl), a
    ld l, #33 : ld (hl), a
    ld l, #34 : ld (hl), a
    ld l, #35 : ld (hl), a
    
    ld l, #51 : ld (hl), a
    ld l, #52 : ld (hl), a
    ld l, #53 : ld (hl), a
    ld l, #54 : ld (hl), a
    ld l, #55 : ld (hl), a
    ld l, #56 : ld (hl), a

    ld l, #70 : ld (hl), a
    ld l, #71 : ld (hl), a
    ld l, #73 : ld (hl), a
    ld l, #74 : ld (hl), a
    ld l, #75 : ld (hl), a
    ld l, #76 : ld (hl), a
    ld l, #77 : ld (hl), a

    ld l, #90 : ld (hl), a
    ld l, #91 : ld (hl), a
    ld l, #92 : ld (hl), a
    ld l, #93 : ld (hl), a
    ld l, #94 : ld (hl), a
    ld l, #95 : ld (hl), a
    ld l, #96 : ld (hl), a
    ld l, #97 : ld (hl), a

    ld l, #b0 : ld (hl), a
    ld l, #b1 : ld (hl), a
    ld l, #b2 : ld (hl), a
    ld l, #b3 : ld (hl), a
    ld l, #b4 : ld (hl), a
    ld l, #b5 : ld (hl), a
    ld l, #b6 : ld (hl), a
    ld l, #b7 : ld (hl), a

    ;ld l, #d3 : ld (hl), a
    ld l, #d4 : ld (hl), a
    ld l, #d5 : ld (hl), a
    ld l, #d6 : ld (hl), a
    ld l, #d7 : ld (hl), a
    
    ld l, #f1 : ld (hl), a
    ld l, #f2 : ld (hl), a
    ld l, #f3 : ld (hl), a
    ld l, #f4 : ld (hl), a
    ld l, #f5 : ld (hl), a
    ld l, #f6 : ld (hl), a

    inc h

    ld l, #12 : ld (hl), a
    ld l, #13 : ld (hl), a
    ld l, #14 : ld (hl), a
    ld l, #15 : ld (hl), a

    ret
    
rl0  
    ld b, #40
    call rl1

    ld b, #48
    call rl1

    ld b, #50

rl1
    call rnd16
    ld a, h : and %00000011
    rla
    or b
    ld d, a
    
    ld a, l : and %11100000 : ld e, a
    ld bc, 32
    push de
    call rnd16
    pop de
    ld h, 0
    ldir
    ret
    
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
    
