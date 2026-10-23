-- greets! hope you are all well
-- love to my fellow jammers,
-- weatherman115, immibis, g33kou,
-- pumpuli and totetmatt. Thank you
-- violet for hosting and Perc! for
-- the tunes!

-- i need an idea... can you tell?
rn=math.random
C=math.cos
S=math.sin

for i=0,15 do
poke(0x3fc0+3*i,i*255/16)
poke(0x3fc1+3*i,i*255/16)
poke(0x3fc2+3*i,i*255/16)
end

npt = 30
ptp = {}
ptv = {}
pta = {}
for i=0,npt do
ptp[i]={rn(0,239),rn(0,135)}
ptv[i]={rn()*2-1,rn()*2-1}
pta[i]={rn()*2-1,rn()*2-1}
end

function nz(v2)
 h=(v2[1]^2+v2[2]^2)^0.5
 return {v2[1]/h,v2[2]/h}
end

function bug(pt,pd)
 pd = nz(pd)
 sz=4
 
 upx=pd[1]
 upy=pd[2]
 rx=-pd[2]
 ry=pd[1]
 
 tpx=pt[1]+upx*sz
 tpy=pt[2]+upy*sz
 b1x=pt[1]-upx*sz-rx*sz
 b1y=pt[2]-upy*sz-ry*sz
 b2x=pt[1]-upx*sz+ry*sz
 b2y=pt[2]-upy*sz+ry*sz
 tri(tpx,tpy,b1x,b1y,b2x,b2y,15)
end

sceng=0.99

cls(0)
function TIC()
for x=0,239 do for y=0,135 do
px=peek4(x+y*240)
poke4(x+y*240,px*0.95+rn(0,1))
end end
maxdist=0
T=time()/1000
cx=120+50*C(T)
cy=68-50*S(T)
circ(cx,cy,4,4)
for pi=0,npt do
pt=ptp[pi]
pv=ptv[pi]
pa=pta[pi]
bug(pt,pv)
vlm=.4
pt[1]=pt[1]+pv[1]*vlm
pt[2]=pt[2]+pv[2]*vlm

pv[1]=(pv[1]+pa[1]*vlm)*sceng
pv[2]=(pv[2]+pa[2]*vlm)*sceng

dcx=pt[1]-cx
dcy=pt[2]-cy
maxdist=math.max((dcx^2+dcy^2)^0.5,maxdist)
dr=-1+fft(1)*10/math.max(maxdist/50,1)
ni=nz({dr*dcx,dr*dcy})
ra={rn()*2-1,rn()*2-1}
pa[1]=(pa[1]*4+ni[1]*2+ra[1])/7
pa[2]=(pa[2]*4+ni[2]*2+ra[2])/7
end
end