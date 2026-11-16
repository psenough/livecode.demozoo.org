-- title:   ThePetsMode at Evokea
-- author:  jamque
-- desc:    thepetsmode logo inthe stars 
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

point = {}
function point:new(x,y)
  local t= setmetatable({},{__index=point})
  t.x=(x or 0)
  t.y=(y or 0)
  return t
end

function point:rot(angle)
 x2 = (self.x)*math.cos(angle)-(self.y)*math.sin(angle)
 y2 = (self.y)*math.cos(angle)+(self.x)*math.sin(angle)
 self.x = x2
 self.y = y2
end

function point:set(x,y)
 self.x=x
 self.y=y
end

t=0
side=18
-- 240 x 136 (120 - 68)

star={}

function initPart()
 for i=0,50 do
  star[i]=point:new(math.random(0,240),
                     math.random(68-50,68-50+100))
 end
end

function runPart()
 for i=0,50 do
  pix(star[i].x,star[i].y,14)
  star[i].x =star[i].x - 1
  if (star[i].x < 0) then
   star[i].x=240
   star[i].y=math.random(68-50,68-50+100)
  end
 end
end

function BG()
 rect(0,68-50,240,100,0)
 runPart()
 for i=0,15 do
  pos =68+50*math.sin((t+i*5)/30)
	 line(0,pos,240,pos,i)
	end
end

initPart()

function TIC()
	cls(13)

 BG()

center=point:new(0,0)
--center:rot(t/10)
center.x = center.x +120
center.y = center.y +68
y=center.y
posL=point:new(center.x-side*2,y)
posC=point:new(center.x,y)
posR=point:new(center.x+side*2,y)

-- superior
 posL.y = center.y-side*2
 posC.y = posL.y
 posR.y = posL.y
 upTri(posL,12)
 downTri(posL,12)
 upTri(posC,12)
 downTri(posC,12)
 upTri(posR,12)
 downTri(posR,12)
-- central
 posL.y=center.y
 posR.y=posL.y
 upTri(posL,12)
 downTri(posL,12)
 upTri(posR,12)
 downTri(posR,12)
-- inferior
 posL.y=center.y+side*2
 posC.y=posL.y
 posR.y=posL.y
 upTri(posL,12)
 downTri(posL,12)
 upTri(posC,12)
 downTri(posC,12)
 upTri(posR,12)
 downTri(posR,12)
-- whites
 posL:set(center.x-side,center.y-side*3)
 downTri(posL,12)
 posL:set(center.x+side,center.y+side*3)
 upTri(posL,12)
 posL:set(center.x-side*3,center.y+side)
 rightTri(posL,12)
 posL:set(center.x+side*3,center.y-side)
 leftTri(posL,12)
-- black
 posC:set(center.x+side,center.y-side)
 upTri(posC,0)
 posC:set(center.x-side,center.y+side)
 downTri(posC,0)
 posC:set(center.x-side,center.y-side)
 leftTri(posC,0)
 posC:set(center.x+side*3,center.y+side)
 leftTri(posC,0)

-- text
 print("THE PETS MODE at EVOKE 2025",
 			   2+240-t%550,110+8*math.cos(t/10)+2,0,false,2)
 print("THE PETS MODE at EVOKE 2025",
 			   240-t%550,110+8*math.cos(t/10),11,false,2)

	t=t+1
 side=14+8*math.sin((t/100))
end

function upTri(base,color)
	tri(base.x,base.y-side,
	    base.x-side,base.y,
					base.x+side,base.y,color)
	line(base.x,base.y-side,
	    base.x-side,base.y,0)
	line(base.x,base.y-side,
	    base.x+side,base.y,0)
end

function downTri(base,color)
	tri(base.x,base.y+side,
	    base.x-side,base.y,
					base.x+side,base.y,color)
	line(base.x,base.y+side,
	    base.x-side,base.y,0)
	line(base.x,base.y+side,
	    base.x+side,base.y,0)
end

function rightTri(base,color)
	tri(base.x,base.y-side,
	    base.x,base.y+side,
					base.x+side,base.y,color)
	line(base.x,base.y-side,
	    base.x+side,base.y,0)
	line(base.x,base.y+side,
	    base.x+side,base.y,0)
end

function leftTri(base,color)
	tri(base.x,base.y-side,
	    base.x,base.y+side,
					base.x-side,base.y,color)
	line(base.x,base.y-side,
	    base.x-side,base.y,0)
	line(base.x,base.y+side,
	    base.x-side,base.y,0)
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f43c3c64566c86333c57
-- </PALETTE>

