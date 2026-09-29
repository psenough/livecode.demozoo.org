
-- Boris

s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi
floor = math.floor

h = 136
w = 240

t=0

FONT1 = 0x14604*8
FONT2 = 0x14A04*8
SPR = 0x4000*2

strs = {
"Monday Night Bytes  ",
"Jammin'  ",
"Field FX - ",
}


-- black font
for c=32,127 do
  for y=0,7 do
    for x=0,7 do
      poke4(SPR+x+8*y+64*(128+c),
        1-peek1(FONT1+64*c+x+8*y))
        end
  end
end

parx = {}
pary = {}
NP = 500
for p=0,NP do
  parx[p] = -1
  pary[p] = -1
end




function TIC()
  -- color font
  for c=32,127 do
    for y=0,7 do
      for x=0,7 do
        col = 1+(y + floor(t/8))%10
        poke4(SPR+x+8*y+64*c,
            col*peek1(FONT1+64*c+x+8*y))
      end
    end
  end

  cls(0)
  for i=0,16 do
    ti = 0.3*t*(1+ (4*(0.5+0.5*s(0.5*i)))%4)
    ofs = -6 + ti % 6
    ofs2 = -floor(ti/6)
    str = strs[1+i%#strs]
    for x = 0,40 do
      cofs = ofs + 2*s(0.1*t + 0.2*x) 
      c = 1 + (ofs2 + x)%#str
      spr(string.byte(str,c,c+1),
         cofs+6*x,8*i, 0,1)
    end
  end
  for i=0,8 do
    ti = 0.3*t*(1+ (4*(0.5+0.5*s(0.5*i)))%4)
    ofs = -12 + ti % 12
    ofs2 = -floor(ti/12)
    str = strs[1+i%#strs]
    for x = 0,20 do
      cofs = ofs + 4*s(0.1*t + 0.2*x) 
      c = 1 + (ofs2 + x)%#str
      xpos = cofs + 12*x
      ypos = 16*i + 3*s(0.1*(cofs+12*x))
      spr(128+string.byte(str,c,c+1),
         xpos+2,ypos+2, 1,2)
      spr(128+string.byte(str,c,c+1),
         xpos-2,ypos+2, 1,2)
      spr(128+string.byte(str,c,c+1),
         xpos+2,ypos-2, 1,2)
      spr(128+string.byte(str,c,c+1),
         xpos-2,ypos-2, 1,2)
      spr(string.byte(str,c,c+1),
         xpos,ypos, 0,2)
      if rand(3) > 1 then
         newpi = rand(NP)
         parx[newpi] = xpos+4
         pary[newpi] = ypos
            end
    end
  end
  for p=0,NP do
    if parx[p] > -1 then
       --circ(parx[p],pary[p], 1, 2)
       circ(parx[p],pary[p], 0, 12)
       pary[p] = pary[p] - 0.5
       parx[p] = parx[p] + -1 + rand(2)
    end
  end


  t = t + 1
end

