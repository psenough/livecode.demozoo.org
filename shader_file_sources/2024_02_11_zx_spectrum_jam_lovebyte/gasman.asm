    org 0x8000

sintab equ 0x8200

    ld    de, 0x00fe
    ld    h, d
    ld    l, d
    ld    bc, sintab
sine_loop:
    rrc    c
    sbc    a,a
    xor    h
    ld    (bc), a
    add    hl, de
    dec    de
    dec    de
    rlc    c
    inc    c
    jr    nz, sine_loop

    ld hl,0x4000
    ld (hl),0x5a
    ld de,0x4001
    ld bc,0x0100
    ldir
    dec h
    inc d
    ld bc,0x1600
    ldir

frame
    halt
pctr
    ld a,1
    rrca
    ld (pctr+1),a
    jr nc,no_new_char
textpos
    ld hl,text
    ld a,(hl)
    or a
    jr nz,no_wrap
    ld hl,text
    ld a,(hl)
no_wrap
    inc hl
    ld (textpos+1),hl
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,0x3c00
    add hl,de
    ld de,charbuf
    ld b,8
    ldir
no_new_char
    ld hl,scrbuf+1
    ld de,scrbuf
    ld bc,0x0100
    ldir

    ld b,8
    ld ix,charbuf
    ld hl,scrbuf+0x1f
buf2scr
    sla (ix)
    sbc a,a
    and b
    add a,a
    add a,a
    ld (hl),a
    ld de,0x0020
    add hl,de
    inc ix
    djnz buf2scr

wavepos
    ld hl,sintab
    ld a,(hl)
    srl a
    ld (wave+1),a
    inc l
    inc l
    ld (wavepos+1),hl

    ld hl,scrbuf
    ld de,0x5800
    ld b,24
linelp
    exx
sinpos
    ld hl,sintab
    exx
    push bc
    ld b,32
charlp
    push hl
    exx
    ld a,(hl)
    inc l
    add a,a
    add a,a
    add a,a
    and 0xe0
    exx
    add a,l
    ld l,a
    ld a,e
wave
    add a,0
    and 0x07
    or (hl)
    pop hl
    ld (de),a
    inc de
    inc l
    djnz charlp
    ld a,(wave+1)
    inc a
    ld (wave+1),a
    pop bc
    djnz linelp

    ld a,(sinpos+1)
    add a,4
    ld (sinpos+1),a
    jp frame

text
    db "lovebyte <3 ",0

charbuf equ 0x8800
scrbuf equ 0x9000
