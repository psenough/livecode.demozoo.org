;;;;;;;;;;;;;;;;;;;;;;
; nikhotmsk livecoding at Multimatograf, day ONE
; Check chibiakumas.org Z80 tutorial
;;;;;;;;;;;;;;;;;;;;;;



    org 0x8000
    
;;;;;;;;;;;;;;;;;;;;
; init variables here
;;;;;;;;;;;;;;;;;;;;
    ld a, 0
    ld hl, 1
    ld (border_counter), hl
    ld (slide), hl
    ld (border), a
    
loop
    
    ld b, 0                       ; DEBUG TODO
    ; call do_spectrometer
    
    call do_random_colors
    
    call border_blink
    jr loop

;;;;;;;;;;;;;;;;;;
; variables here
;;;;;;;;;;;;;;;;;;
border_counter: dw 0
border: db 0

border_blink:
    ld de, (border_counter)
    dec de
    ld (border_counter), de
    ld a, d
    or e
    jr nz, border_skip
    ld a, (border)
    inc a
    and 0b00000111
    ld (border), a
    out (254),a
    ld de, 4
    
    ld (border_counter), de
border_skip:
    
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;
; do_random_colors
;;;;;;;;;;;;;;;;;;;;;;;;;
    do_random_colors:
    ld hl, 0x5800
    ;ld de, 0 ; read from ROM, yeah!
    push hl
    ld hl, (slide)
    inc hl
    ld (slide), hl
    ld de, hl
    pop hl
    
    ld bc, 256 + 256 + 256
    
do_random_colors_cycle:
    ld a, (de)
    and 0b11111111 ; drop blinking flag
    ld (hl), a
    
    inc hl
    inc de
    dec bc
    ld a, b
    or c
    jr nz, do_random_colors_cycle
    
    ret

;;;;;;;;;;;;;;;;;;;;;;;
; do_spectrometer
; b - column number
;;;;;;;;;;;;;;;;;;;;;;;
do_spectrometer:
    
    ld de, 0x5800
    
    ; TODO move de around
    
    ld hl, spectrometer_decay_array
    
    ; TODO move it around depending on b
    
    ld a, (hl)
    and 0b00001111
    
    ld b, a
    or a
    jr z, do_spectrometer_cycle_no_need_to_move
do_spectrometer_cycle1:
    ; DO CYCLE HERE
    
    dec b
    jr nz, do_spectrometer_cycle1
do_spectrometer_cycle_no_need_to_move:
    
    ld a, 0b01101101 ; a color
    
    ; TODO compute color
    
    ld (de), a
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;
; spectrometer_decay_array
;;;;;;;;;;;;;;;;;;;;;;;;;
spectrometer_decay_array:
    .32 db 0 ; copy it 32 times, easy
slide: dw, 0

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
