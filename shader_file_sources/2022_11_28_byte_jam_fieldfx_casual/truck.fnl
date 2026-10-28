; well this will be an interesting
;; expiriment... do not expect much
;; wait this isn't the blank thing
;; craaaaap
;; I'm just you know trying to...
;; get stuff on the screen (:
;; script: fennel
;; ok what am I doing...
;; yes circle things
(global mf math.floor)
(global ms math.sin)
(global mc math.cos)

(global x1 3)
(global y1 80)
(global x2 108)
(global y2 55)

(set-forcibly! TIC (fn []
 (global t (mf (/ (time) 36)))
 (global ts (ms (/ (time) 256)))
 (global tc (mc (/ (time) 256)))
 (cls 0)
 (bgthing)
 ( for [i 4 0 -1]
  (circthing (+ 120 (- (* tc 120)) (* i 10))
             (* i 20)
;; I keep typing X instead of * ...
   (* 3 (* (+ ts tc) (* 2 (+ 1 tc)) i) ) i )
 )
 ; um hello linething?
 ; oh right it needs values
 (linething x1 y1 x2 y2)
 (+ x1 (* 15 ts))
 (+ x2 (* 15 tc))
 (+ y1 (* 15 ts))
 (+ y2 (* 15 tc))
 
 ; hmm this is not what I want to do... but
 ; I don't think I can draw a circle from
 ; but I can do a textured triangle hmm
 ; you know let's do the line funk thing cuz
 ; why not
 

;
)
)
; ok seriously how do I get a
; second function, I need more
; than one
; ok that's how
(set-forcibly! circthing (fn [a b r c]
 (circ (+ a (* 20 ts))
       (+  b (* 3 ts (* 20 tc)) )
       r  c
 )
)
)

(set-forcibly! bgthing (fn []
 ( for [x 0 240]
  ( for [y 0 136 3]
    ( pix x y (+ x y (* ts 8) (* tc x)) )
  )
 )
 )
)
; try without set-forcibly)
; well that doesn't work I wonder why
; well we are wrapping up so I will
; leave this unfinished (:
; naw let's move it or something

(set-forcibly! linething (fn [x1 y1 x2 y2]
 (line x1 y1 x2 y2 1)
 (line (+ 5 x1) (+ 5 y1) (+ 5 x2) (+ 5 y2) 8)
 (line (+ 10 x1) (+ 10 y1) (+ 10 x2) (+ 10 y2) 7)
 (line (+ 15 x1) (+ 15 y1) (+ 15 x2) (+ 15 y2) 9)
 )
)
;; this needs better paren editing