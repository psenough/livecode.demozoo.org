-- mantratronic here
-- congrats on unesco acceptance
-- and greetings to all

M=math
R=M.random
S=M.sin

nmb=3
mb={}
t=0

function BDR(l)
 for i=0,15 do
  poke(0x3fc0+i*3,i/15*128+i/15*128*S(2+t/100+l/100))
  poke(0x3fc0+i*3+1,i/15*128+i/15*128*S(4+t/100+l/100))
  poke(0x3fc0+i*3+2,i/15*128+i/15*128*S(t/100+l/100))
 end
end

function BOOT()
 for i=1,nmb do
  mb[i]={x=1,y=1}
 end
end

function dist(a,b)
 return ((a.x-b.x)^2+(a.y-b.y)^2)^.5
end

function clamp(x,a,b)
 return M.max(a,M.min(b,x))
end

cen={x=0,y=0}
ffth={0,0,0}

function TIC()t=time()/32
cls(0)

ffth[1]=ffth[1]+fft(2)/2
ffth[2]=ffth[2]+fft(10)*2
ffth[3]=ffth[3]+fft(100)*6

for i=1,nmb do
 mb[i].x = 80*S(i/5 * ffth[i])
 mb[i].y = 60*S(i/5 * ffth[i]*.9)
 
end

for y=0,136 do for x=0,200 do
 local sum=0
 for i=1,nmb do
  sum=sum+50/dist(mb[i],{x=x-100,y=y-68})
 end
 if ((y/2+ffth[1]+5*S(x/30+t/20+ffth[2]))%20)>7-fft(0)*10 then
	 pix(x+40,y,clamp(sum*3,0,15))
 else
  local ll = (3*sum%1)/(.5*sum//1)
  if ll < 0.05 then
 	 pix(x+40,y,3)
  elseif ll < 0.1 then
 	 pix(x+40,y,7)
  elseif ll < 0.15 then
 	 pix(x+40,y,11)
  elseif ll < 0.2 then
 	 pix(x+40,y,15)
  elseif ll < 0.25 then
 	 pix(x+40,y,11)
  elseif ll < 0.3 then
 	 pix(x+40,y,7)
  elseif ll < 0.35 then
 	 pix(x+40,y,3)
  end
  
	end 
end end 

for i=1,nmb do
-- circ(140+mb[i].x,68+mb[i].y,10,12)
end

print("U",8,2,15,true,4)
print("N",8,24,15,true,4)
print("E",8,46,15,true,4)
print("S",8,68,15,true,4)
print("C",8,90,15,true,4)
print("O",8,112,15,true,4)

end

--[[  .____..____._.____.   .___.
     /    //    /   \    \  \    \
    /    //    /    _\    `-|     \
   /    //    /    /  \            \ 
  /    _     /     \___\     , .    \
 /    //    /          \\     \ \    \
|____//____/ \__________|\____|\|\____|

            ------------|
           /  |      |  |
           |  |      |  |
           |  |      |  |
           |  \______/  |
           |            |
           |     __     |
           |    /  \    |
           |   < <> >   |
           |    \__/    |
           |            |
           \____________/
           
--]]

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

