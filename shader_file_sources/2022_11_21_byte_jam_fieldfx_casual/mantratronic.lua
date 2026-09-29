-- logo is bad tic80 copy 
-- of an ne7 amiga ascii (sry!)
logo={"  `___//  __//_ __//___//_---//___;---//__;--\\\\__.",
"  /  //--Y     \\   _/   _/        Y       Y      |",
" /       |  // |   _/   _/   /    |   a   |   // |",
"/   //   |     |  |/|  |/|  // // |   /   |  //  |",
"\\--//____/-//-_/\\-/  \\-/ |-//_//_mtr-//--|/-//___|"}

bpm=130
s=math.sin
c=math.cos
pi=math.pi
tau=2*pi
t=0

function println(x,y,kx,ky,col)
 for i=1,5 do
  l=string.len(logo[i])
  for ch=1,l do
   print(string.sub(logo[i],ch,ch),x+(ch-1)*kx,y+(i-1)*ky,col+i,true,1,true)
  end
 end
end

function arc(x,y,w,r,ca,wa,col)
for i=ca-wa/2,ca+wa/2,.1/r do
si=s(i)
ci=c(i)
line(x+r*si,y+r*ci,x+(r+w)*si,y+(r+w)*ci,col)
end
end

function tangent(x,y,w,r,ca,l,col)
cx=r*s(ca)
cy=r*c(ca)
wx=(r+w)*s(ca)
wy=(r+w)*c(ca)
tx=l*s(ca-pi/2)
ty=l*c(ca-pi/2)
for i=-l,l,.5 do
 line(x+cx+tx*i/l,y+cy+ty*i/l,x+wx+tx*i/l,y+wy+ty*i/l,col)
end
end

function clamp(x,e1,e2)
 return math.max(e1,math.min(x,e2))
end

function ss(x,e1,e2)
 y=clamp(x,e1,e2)
 st=(y-e1)/(e2-e1)
 return st*st*(3-2*st)
end

function TIC()t=time()/99
 beat=time()/100*60/bpm
 if (beat/2%12 < 11) then
  cls(1)
 end
 ta=ss(beat%4/4,0,1)
 for j=1,20 do
  n=3+j
  d=(4*j-beat%64)
  if d~=0 then d=99/d end
  
  if d<120 and d >5 then 
   w=d/6
   chroma=.01*(1+s(ta))
   cr=ss((beat/4+2*j)%5,2,4)*tau
   if j%2 == 0 then
    for i=1,n do
     if (beat/4%8 < 4) then
      arc(120,68,w,d,cr + tau/n*i +j/10,pi/n,12)
     else
      arc(120,68,1,d*(1-chroma),cr + tau/n*i +j/10,pi/n,2)
      arc(120,68,1,d+w,cr + tau/n*i +j/10,pi/n,10)
      arc(120,68,w,d,cr + tau/n*i +j/10,pi/n,12)
     end
    end
   else
    for i=1,n do
     if (beat/4%6 < 3) then
      tangent(120,68,1,d-1,cr + tau/n*i +j/10,d,0)
      tangent(120,68,w,d,cr + tau/n*i +j/10,d,11+(j/2)%4)
     else
      tangent(120,68,1,d*(1-chroma),cr + tau/n*i +j/10,d,1)
      tangent(120,68,1,d*(1+chroma),cr + tau/n*i +j/10,d,9)
      tangent(120,68,w,d,cr + tau/n*i +j/10,d,11+(j/2)%4)
     end
    end
   end
  end
 end
 if (beat/4%4 > 1) then ta = 0 else ta = s(pi*ta) end
 println(44-ta*24,58-ta*1.5,3+ta,3+ta,0+beat*2)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

