            DEVICE ZXSPECTRUM48
            org 0x8000

            ld hl,0
            ld de,0x4000
            ld bc,0x1800
texturelp
            ld a,(hl)
            inc hl
            and (hl)
            inc hl
            ld (de),a
            inc de
            dec bc
            ld a,b
            or c
            jr nz,texturelp

            ld hl,text
do_text
            ld a,(hl)
            or a
            jr z,text_done
            rst 0x10
            inc hl
            jr do_text

text_done
frame_lp
            ei  ; what asshole disabled interrupts by default???
            halt

            ld a,2
            out (254),a

frame_num   ld a,0
            inc a
            and 31
            ld (frame_num+1),a
            jr nz,no_change_attr

            ld a,(attr_mod+1)
            inc a
            cp 63
            jr nz,no_reset_mod
            ld a,4
no_reset_mod
            ld (attr_mod+1),a

no_change_attr

            ld hl,0x5800
            call attr_splurge
            ld hl,0x5a00
            call attr_splurge

            ld hl,0x5901
            ld de,0x5900
            ld bc,0xff
            ldir

scrl_counter
            ld a,0
            dec a
            and 7
            ld (scrl_counter+1),a
            jr nz,scrl_skip_char

scrltext_pos            ld hl,scroller
            ld a,(hl)
            or a
            jr nz,scrltext_notdone
            ld hl,scroller
            ld a,(hl)
scrltext_notdone
            inc hl
            ld (scrltext_pos+1),hl

            ld l,a
            ld h,0
            add hl,hl
            add hl,hl
            add hl,hl
            ld de,0x3c00
            add hl,de
            ld de,scrlbuf
            ld bc,8
            ldir

scrl_skip_char

            ld de,scrlbuf
            ld hl,0x591f

            rept 8
                        ld a,(de)
                        add a,a
                        ld (de),a
                        sbc a,a
                        inc de
                        ld b,a
                        ld a,r
                        and 7
                        or b
                        ld (hl),a
                        ld bc,0x0020
                        add hl,bc
            edup

            xor a
            out (254), a
            jp frame_lp

attr_splurge
            ld b,0
attr_mod
            ld d,4
first_b
            ld a,0
attr_lp
            ld (hl),a
            inc a
            cp d
            jr nz,no_attr_reset
            ld a,0
no_attr_reset
            inc hl
            djnz attr_lp

            ld a,(attr_mod+1)
            ld b,a
            ld a,(first_b+1)
            inc a
            cp b
            jr c,no_reset_first_b
            xor a
no_reset_first_b
            ld (first_b+1),a
            ret

text
            db "ladies and gentlemen, the first ever zx spectrum jam!"
            db 0

scrlbuf     db 0,0,0,0,0,0,0,0

scroller    db "Party on dudes and dudesses!!!! Greetings to nico - dave84 - tobach - "
            db "alia - mantratronic - jtruk - fell - evvvvil - deathboy - aldroid - kris !!!", 0

            SAVESNA "jam.sna", 0x8000
