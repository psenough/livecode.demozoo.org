    ; superogue here!
    ; Are you ready for the first ever zx spectrum live coding
    ; matchup using the lovebyte bazematic.demozoo.org ?

    ; - have a great lovebyte! 

    org 0x7ffe

sintab = 0x8200

    jr hoplite

fancycolors:   ; insert spongebob snobism gif
    db 0,1,69,71,69,3,1,8
hoplite:

    call singen
    call copytile
loop

    ; abuse IY (noooo, noooo!)
    ld a,ixl
    sra a
    sra a
    sra a
    ld iyl,a

    ; update screen
    ld de,0x5800    ; COLORRAM (32 x 24)
    ld b,24
yloop:
    ld c,32
xloop:
    push bc
    push hl
    
    ; grab sinvalue
    ld a,b
    add ixl
    and iyl
    ld h,0x82
    ld l,a
    ld a,(hl)
    ld l,a
    
    ; this is where the magic(?) happens
    ; okay lets make some magic
    ; c=abs(c)
    ld a,c
    add 112
    jp p,absx
    neg
absx:
    add l
    ld c,a
    ld a,c
    add ixl
    ld h,a
    
    ld a,c
    sub b
    add ixl
    and h
    sra a
    sra a
    and 3
    
    ; grab them fancy colors (spongebob gif again!)
    ld h,0x80
    ld l,a
    ld a,(hl)
    ld (de),a
    inc de

    pop hl
    pop bc
    dec c
    jr nz,xloop
    djnz yloop

    ; next frame
    inc ix

    jr loop
    

; lets load an interesting pattern
copytile:
    ld h,0x57
loop3:
    ld de,tiledata
    ld b,8 ; 8 height
loop2:
    ld a,(de)
loop1:
    ld (hl),a
    inc l
    jr nz,loop1
    dec h
    inc e
    djnz loop2
    bit 6,h
    jr nz,loop3
    ret

tiledata:
    db %11110010
    db %11110110
    db %11110000
    db %00000000
    db %00001111
    db %01101001
    db %01001111
    db %00000000


    ; thanks to neon!
singen:
    ld de,0x00fe
    ld h,d
    ld l,d
    ld bc,sintab
sloop:
    rrc c
    sbc a
    xor h
    ld (bc),a
    add hl,de
    dec de
    dec de
    rlc c
    inc c
    jr nz,sloop
    ret
    ret





    
    
