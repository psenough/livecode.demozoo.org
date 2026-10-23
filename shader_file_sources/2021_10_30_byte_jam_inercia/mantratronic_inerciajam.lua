local pal = "0500042b2b2156553b33803378801c86807aaaaa23d1e129acaa9bffe167bffb63cc8000dbd5d1f3ff79fefffeff9d37"
function tovram(str)
  local o=0
  for c=1,#str,2 do
    local v=tonumber(str:sub(c,c+1),16)
    poke(0x3fc0+o,v) o=o+1
  end
end
tovram(pal)
local gfx = "8040fffffffffffffffffffffffffffffffffffffffffffffff0ffffff05ffffff08ffffff00fff00058ff05ced9f08e999908d999998d999999d99999999999999900000000eedddddd999999999999e9999999999999999999999999999999777000ffffffc000ffff9dd800ff9999900f9999920099602eec902ec9992ec99999fffffffffffffff0fff0000e0000eecceecc9999999999999999999799999999ffff00000000ccccecc99ddd99999999999920007777750c7e999100999999420fffffffc0000000ddee90dd9999999c2699999909999990199991029999025ef00000ff00e9920f9996990f9999990f11111000b282bc8020cc2c50e18c2880ffffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000007fffff000fffffff1fffffff0fffffff0ffffff02ffffff00ffffff0c7777721e77770ecc7770ec99770e999970d999990d9999e7c999997999999799c9999979999779999979999297990990799029109990990099909909999099079909999990c999990c999e99c9999999c9999777999777999777999977999999999999999999929999999991799999189999962c9999905899991851999618e09100288505cc5885b85ed1c81885e01cd188e021e80221208501200f010010f1e22e5081e1082110c011010f8021220f1158010f01000ffff0ffffff10f10f00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1c9fffff199ffff0c99fff0c999fff0c999ff0c9999ff199999f0c9999e99997999999979999997990999799990999999969999999999999990999999970990d7070996077960970799990779990777999990799999079999e9799999997999999999999999999999999999999999999999e999999999999999999999999a9120029961200099500101999999999999dddd9ddddddddddddddddddddddd1021c000e105880c22212112ddddddddddddddddddddddddddddddddddddddddc1120120828c08c021c82cc562111210ddddddd1ddddddd0ddddddd0ddddddd0fffffffffffffffffffffffffffffff0fffffff0fffffff0fffff004fff00919f0999999089999990997999949779999997799999777799997777999777777999999997799999799999979999997999999999999999999999999e999999999979999999999999999999099699999009999904999990d99999049999990d999999999999d9999d6ad9999d0ad999d0aad999e0aad99d0aada9d40aaaadc1aaaaaddddddddddddddddddddddddddddddaddddddadddddaaaddaaaaaaddaaaaaaeddddddddddddddddadddddddaddddddaddddddaddddddaddddddaddddddadddddaddddd00dddddd0fdddddd0fddddd00fddddd0ffdddd00ffdddd0fffddd00fffff099709fff17709ffff0707fffff007ffffff07ffffff07ffffff07ffffff077777777977777777777777777777777777777777777777777777777777777777999999777999977777797777777777777e777776777777707777777077777770099999990999999d099999d009999d030999e03a999d03aa99d03aaadd03aaaac13aaaaa13aaaaaa3aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeaaaaaaaaaddaaaaaaadaaaaaaaaaaaaaaaaaaaaa2aaaaaa2aaaaa22aaaaa27aaaaaddddddddddddddddaddddddaaaaaaaaaaaaaaaaaaaaaaaa4aaaaaa40aaaaaa01dda0ffffda00ffffaa0fffffa000ffff0120ffff0110ffff1220ffff122b0fffffffff06fffffff0fffffff1fffffff0fffffff0fffffff0fffffffffff000007777777777777777777777777777777777777777677777770777777707777707777777607777770c7777770077777aaa7777aaaa6777aaaa077aaaaa07aaaaaae03aaaaa03aaaaaa3aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2aaaa222aaa22aaaaaaaaaaa2aaaaaa27aaaa22aaaaa27aaaa22aaaaa2aaaaaaaaaaaaaaaaaaaaaaa2aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0aaaaaa00aaaa400faaaaa000aaaa00ffaaa00fffaa00ffff400fffff00ffffffffffffffffffffff22b90fff08950ffff0920fffff00fffffff0ffffffffffffffffffffffffffffff07d777f077d7770a77777700000007fffffff1fffffff0fffffff0ffffffff077777060677776070777777766777776777777a27777700077777aa0006777a07aaaaaa7aaaaaaa7aaaaaaa7aaaaaaaaaaaaaaaaaaaaaaa200000000fffffffaaaaaaaaaaaaaaaeaaaaaaaaaaaaaaaaaaaaaaaaaaaa4000000000ffffffffffaaaaaaaaaaaaaaaaaaaaaa40aaaaa000a40000ff000fffffffffffffffffffffaa4000ffa000ffff01ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00a77affff077affff077affff00aafffff0a0fffff0a0ffff0d00ffff000f0fffffff0fffffff0fffffff0fffffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
function tomem(str)
  local tnb=tonumber
  local o=tnb(str:sub(1,2),16)*256
  local w=tnb(str:sub(3,4),16)*8-1
  local d=str:sub(5,str:len())
  local y=0
  for x = 1,#d,1 do
    local c=tnb(d:sub(x,x),16)
    poke4(o+y,c) y=y+1
    if y>w then y=0 o=o+1024 end
  end
end
tomem(gfx)

strings={"Hello!",
"My name is Diego Mantroya!",
"You mistook my nationality",
"prepare to die.",
"",
"Psychic is mind magic we wish we had",
"Psychics are people you can pay",
"to tell you what you want to hear",
"Psychics are full of shit!",
"",
"Symphonies are a type",
"of classical music",
"Symphonies use lots of instruments",
"Symphonies are longer than",
"most drone songs",
"",
"Psychic Symphony is",
"nothing to do with either of these",
"He is PS",
"and is probably wishing I'd stop!",
"He should drink caipirinha!",
"And more superbock!",
"",
"If you are a Lemon Shark",
"Please dont eat Psychic Symphony",
"He is full of noise.",
"If you like jazz though...",
"Jeenio is full of that!",
"",
"Happy 20th INERCIA!",
"May it always be 2005!",
"",
"Image tool code by Decca, release soon",
"the rest by Diego Mantroya",
""}




-- nothing to see up there! 
-- no idea why that character count is
-- so high...

strings2 = {
"ok time to get weird",
"we dont need trolling",
"where we're going",
""}

shapes = 5
shape = 4
tau = math.pi*2
s1 = 40
s2 = 20
 sxo=0
 syo=0
 nxo=0
 nyo=0
nc=3
function throwshapes(ft,levels)
 for i=0,shapes do
  sa=tau/shapes*i + ft/3
  sx=s1*math.sin(sa)
  sy=s1*math.cos(sa)
  if i==0 then
  else
   line(sx+120,sy+68,sxo+120,syo+68,nc)
   for j=0,shape do
    na=tau/shape*j +(sa+ft)
    nx=math.sin(na)
    ny=math.cos(na)
    if j==0 then
    else
     for k=1,levels do
      line(nx*s2/k+sx+120,ny*s2/k+sy+68,nxo*s2/k+sx+120,nyo*s2/k+sy+68,nc)
     end
    end
    nxo=nx
    nyo=ny
   end
  end
  sxo=sx
  syo=sy
 end
end

ot=-1
c=10
sc=14
ls=3
p={}
function TIC()
cls(c)
t=time()
for I=0,376,3 do
dI=I-(t/300)%3
line(dI,0,dI-136,136,c-1)
end
lt=t//4000
if lt==ot then
else
shapes=(math.random()*8 + 3)//1
shape=shapes
ls=(math.random()*3 + 1)//1
ot=lt
c=16*math.random()
nc=c+6
sc=c+4
s2=30+20*math.random()
s1=30+20*math.random()
for I=1,400 do
p[I] = {x=240*math.random(),y=136*math.random()}
end
end
throwshapes(t/1000,ls)
for I=1,10 do
 dx=40*math.sin(t/1000+tau*I/10)
 dy=40*math.cos(t/1000+tau*I/10)
 spr(0,5+dx,30+dy,15,1,0,0,8,8)
 spr(0,235-64+dx,30+dy,15,1,1,0,8,8)
end
for I=1,400 do
pc=pix(p[I].x,p[I].y)
dis=t//100-lt*40
if lt%2 == 0 then
for J=-dis//2,dis//2 do
pix(p[I].x+J,p[I].y,pc)
end
else
for J=-dis//2,dis//2 do
pix(p[I].x,p[I].y+J,pc)
end
end
end
str=(lt% #strings2)+1
strlen=print(strings2[str],0,-10)
print(strings2[str],120-strlen/2,115,0)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

