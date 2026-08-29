-- by alice
--
-- greets:
--   gasman, jtruk, catnip, pumpuli
--
--   and of course reality404

-- pico8 the colors
pico8="0000001D2B537E2553008751AB52365F574FC2C3C7FFF1E8FF004DFFA300FFEC2700E43629ADFF83769CFF77A8FFCCAA"

function palit(p)
 for i=1,#p,6 do
  for j=0,2 do
   poke(0x3fc0+((i//6)*3)+j,
    tonumber(p:sub(i+j*2,i+j*2+1),16))
  end
 end
end

palit(pico8)


m = "FieldFX"
t = 0
w,h=120,68
sin,cos=math.sin,math.cos
pi=math.pi
sub=string.sub
function TIC()
 t = t+0.03
 cls(0)
 hm = "OMG HI MOM"
 -- get length
 e=print(hm,0,-6)
 print(hm,(240-e)//2,(130)//2-50,8)
 s=sin(t)*29.9
 c=cos(t)*h*2/3.99
 --print("a", w+s, h+c, 5)
 --print("b", w-s, h-c, 6)
 -- for each fft bin (give or take)
 for i=0,239 do
 	f = ffts(i*4)
  rect(i,136-f*136,1,300,7)
  --for j=0,10 do
	  print(m, w-20+(s*2), c+e+f*136, 1+i%15)
	  print("come to EMF", w-20-(s*2), c+e+f*136, 1+i%15)
	  --print(sub(m,1,j), w-50+s, c+f*136, 1+i%15)
		--end
 end

 print("hi from alice",174,0,7)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

