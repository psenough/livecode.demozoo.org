Clock.bpm=135

## FoxDot newbie, decided to have a play after
## seeing Violeta's talk at Inercia




p2 >> play("happy solstice :)", dur=0.25)
m1 >> play(" ss", sample=3)
p3 >> play("x x ")

p4 >> jbass([0,None,5,4,5,4],dur=[1,1,0.5,0.5,0.5,0.5], scale=Scale.phrygian)
l1 >> loop("drumloop1", dur=4,amp=0.6)

p4.stop()

p5 >> pulse([2,3,4,6,7,8],dur=0.25,sus=0.1,scale=Scale.phrygian)

p5.stop()

l1.stop()
p6.stop()
p7.stop()


p6 >> pads([(2,4,-6),(3,5,-4)],dur=2,scale=Scale.phrygian,amp=0.3)
p7 >> pads([-6,-5,-4],dur=3,amp=0.9, scale=Scale.phrygian)

## wonder what these do :D

d1 >> space(1,dur=3,amp=0.7)

d1.stop()

d2 >> arpy([6,7,8],dur=[0.5,0.25,0.25])
