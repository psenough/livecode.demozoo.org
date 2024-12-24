-- mt here
-- greets to hoffman,aldroid,violet,
--            gasman,   doctor soft,
--   visy,     ^lynn,      evilpaul,
--    lex,    tobach,         jtruk.

m=math
s=m.sin
c=m.cos

local ffth={}
local fftn={}
local texts={
   {"1YEAR",3},
   {"BYTE",4},
   {"JAAAM",3}}

function rot(i,ax,ay,az)
local ret = rotx(i,ax)
ret = roty(ret,ay)
ret = rotz(ret,az)
return ret
end

function rotx(i,ax)
local xx,yy,zz
yy = i.y*c(ax)-i.z*s(ax)
zz = i.z*c(ax)+i.y*s(ax)
return {x=i.x,y=yy,z=zz}
end

function roty(i,ay)
local xx,yy,zz
xx = i.x*c(ay)-i.z*s(ay)
zz = i.z*c(ay)+i.x*s(ay)
return {x=xx,y=i.y,z=zz}
end

function rotz(i,az)
local xx,yy,zz
xx = i.x*c(az)-i.y*s(az)
yy = i.y*c(az)+i.x*s(az)
return {x=xx,y=yy,z=i.z}
end

local ps={}
local npx=10
local npy=10
local npz=5
local eps={}

function T2P(tex,siz)
hi=siz
cls()
ps={}
lp=print(tex,0,0,15,false,hi,false)
npx=lp
npy=hi*6
for i=1,npx do
for j=1,npy do
if pix(i,j) == 15 then
for k=1,npz do
table.insert(ps,{x=i-npx/2,y=j-npy/2,z=k-npz/2})
end
end
end
end
end

function BOOT()
for i=0,255 do
ffth[i]=0
fftn[i]=0
end
end

local ot=-1
local fa=0
local rp={}
function TIC()t=time()/32

if (t/500)//1%#texts ~= ot then
 ot = (ot+1)%#texts
 for i=1,#rp,5 do
  table.insert(eps,rp[i])
 end
 T2P(texts[ot+1][1],texts[ot+1][2])
end

rs=7+4*s(t/100)
gs=7+4*s(t/100+m.pi*2/3)
bs=7+4*s(t/100+m.pi*4/3)
for i=1,14 do
 poke(0x3fc0+i*3,10+i*rs)
 poke(0x3fc0+i*3+1,10+i*gs)
 poke(0x3fc0+i*3+2,10+i*bs)
end
 poke(0x3fc0+0,0)
 poke(0x3fc0+1,0)
 poke(0x3fc0+2,0)
 poke(0x3fc0+15*3,205)
 poke(0x3fc0+15*3+1,227)
 poke(0x3fc0+15*3+2,255)

cls()
for i=0,255 do
fi=fft(i)
if fi > fftn[i] then
 fftn[i]=fi
end

ffth[i]=ffth[i]*.9 + (fi/fftn[i])*.1
pix(i,130-ffth[i]*5,15)
end
fa=fa+ffth[5]
lp=print("1 Year of Jam Packed Bytes!",0,140,15)
print("1 Year of Jam Packed Bytes!",240-lp,131,15)

rp={}
for i=1,#ps do
 rp[i]=rot(ps[i],fa/200+s(ps[i].x/10+fa/25),fa/50,fa/100)
end
table.insert(eps,rp[m.random(#rp)])
for i=1,#eps do
 if eps[i]~=nil then
  eps[i].x=eps[i].x+0.05+0.1*s(fa/10)
  eps[i].y=eps[i].y-0.1
  eps[i].z=eps[i].z-0.05

  if eps[i].y < -50 then
   table.remove(eps,i)
  end
 end
 if eps[i]~=nil then
  table.insert(rp,eps[i])
 end
end
table.sort(rp, function (a,b) return a.z < b.z end)
--[[
for i=1,5 do
 first = m.random(#eps)+1
 while eps[first]~=nil do
 first = m.random(#eps)+1
 end
 second = m.random(#eps)+1
 while eps[first]~=nil do
 second = m.random(#eps)+1
 end
 
 sz1=(eps[first].z+npy/2)/3
 sz2=(eps[second].z+npy/2)/3
 line(120+eps[first].x*sz1,73+eps[first].x*sz1-ffth[5]*6,
						120+eps[second].x*sz2,73+eps[second].x*sz2-ffth[5]*6,15)
end
--]]
for i=1,#rp do
 sz=(rp[i].z+npy/2)/3
 if sz>0 then
 circ(120+rp[i].x*sz,73+rp[i].y*sz-ffth[5]*6,2+sz/2,m.max(1,m.min(14,sz*1.4)))
 end
end


end
