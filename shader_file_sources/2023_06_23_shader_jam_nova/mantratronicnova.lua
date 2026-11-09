isfirst=true

djp={}

texts={"NOVA",
"DEATHBOY",
"SELLS",
"AVON",
"SUNA"
}

function TIC() t=time()/100
 tt=t//40%#texts+1
 rt=t
 t=t%40
 if t<.5 then
  isfirst=true
  djp={}
 end
 
 for i=0,47 do
  poke(0x3fc0+i,i*4)
 end
 
 if isfirst then
  isfirst=false
  cls(0)
   
  
  -- feel free to replace this
  len = print(texts[tt],240,136,12,false,5)
  print(texts[tt],120-len/2,70,12,false,5)
  
  for y=0,135 do
   for x=0,239 do
    if pix(x,y) == 12 then
     local p = {x=x,y=y,c=15,s=1}
     table.insert(djp,p)
    end
   end
  end
 else
  divide = math.min((t*50)//1,#djp)
  for i=1,divide do
   dx=120-djp[i].x
   dy=68-djp[i].y
   a=math.atan2(dx,dy)+rt/10000
   d=(dx^2+dy^2)^.5
  
   djp[i].x = 120+ (math.random()+d)*math.sin(a)
   djp[i].y = 68+ (math.random()+d)*math.cos(a)
   djp[i].c = math.max(6,math.min(15,djp[i].c +(math.random() -.45)))
   djp[i].s = djp[i].s +(math.random() -.5)
   local p = djp[i]
   circ(p.x,p.y,p.s,p.c)
  end
  
  for i=1,3000 do
   x=math.random(239)-1
   y=math.random(135)-1
   pix(x,y-1, (pix(x,y) + pix(x+1,y+1) + pix(x+1,y-1) + pix(x-1,y+1) + pix(x-1,y-1))/5)
  end
  
  for i=divide,#djp do
   local p = djp[i]
   pix(p.x,p.y,15)
  end
 end
 
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
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

