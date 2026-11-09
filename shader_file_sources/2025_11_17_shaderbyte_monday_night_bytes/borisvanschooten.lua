
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

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2

ghost1
= "ffaaaaff"
.."faaaaaaf"
.."aaccacca"
.."aac0ac0a"
.."aaaaaaaa"
.."aaaaaaaa"
.."aafaafaa"
.."affaffaf"

ghost2
= "ffaaaaff"
.."faaaaaaf"
.."aac0ac0a"
.."aaccacca"
.."aaaaaaaa"
.."aaaaaaaa"
.."aafaafaa"
.."affaffaf"


pac1
= "ff4444ff"
.."f44cc44f"
.."444c0444"
.."44444444"
.."444444ff"
.."44444444"
.."f444444f"
.."ff4444ff"

pac2
= "ff4444ff"
.."f44cc44f"
.."444c0444"
.."44444fff"
.."444fffff"
.."44444fff"
.."f444444f"
.."ff4444ff"


ghost1sh
= "ff0000ff"
.."f000000f"
.."00000000"
.."00000000"
.."00000000"
.."00000000"
.."00f00f00"
.."0ff0ff0f"

function sprite(sprIx,sprDataHex,srccol,dstcol)
  for i=1,NIBBLES_IN_SPR do
    nibble=tonumber(sprDataHex:sub(i,i),16)
    if nibble == srccol then
      nibble = dstcol
    end
    poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
  end
end

sprite(0,ghost1sh,0x0,0x0)
sprite(1,pac1,0x0,0x0)
sprite(2,pac2,0x0,0x0)
sprite(3,pac1,0x04,0x0)
sprite(4,pac2,0x04,0x0)


for i=0,10 do
  sprite(10+i,ghost1,0xa,i+1)
  sprite(30+i,ghost2,0xa,i+1)
end

function TIC()
  --cls(14)
  for y=h,0,-1 do
    for x=0,w do
      col = pix(x,y)
      if col > 0 then
        if rand(0,3) < 1 then
          pix(x,y,15)
        else
          if rand(0,8) < 1 then
            pix(x,y-1,col)
          end
        end
      else
        pix(x,y,15)
      end
    end
  end
  for y=0,10 do
    for x=0,11 do
      xp = t + 20*x + 6*s(0.07*t+x+1.5*y)
      ypn= 24+ 10*y + 7*s(0.042*t+0.8*y+x)
      ypo= 24+ 10*y + 7*s(0.042*(t-1)+0.8*y+x)
      xp = -16 + xp % (w+32)
      yp = -16 + ypn % (h+32)
      if x < 9 then
        ofs = 10
        if ypo > ypn then
          ofs = 30
        end
        --spr(1,xp-2,yp-2,15,2)
        spr(0,xp+2,yp+2,15,2)
        spr(ofs+y%11,xp,yp,15,2)
      end
      if x > 10 and y % 2 == 0 then
        spr(3 + (0.1*t + y/2)%2,xp+2,yp+2,15,2)
        spr(1 + (0.1*t + y/2)%2,xp,yp,15,2)
      end
    end
  end
  t = t + 1
end
