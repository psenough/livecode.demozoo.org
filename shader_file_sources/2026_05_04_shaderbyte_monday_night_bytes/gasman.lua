sin=math.sin
cos=math.cos

yellowr=peek(16320+12)
yellowg=peek(16320+13)
yellowb=peek(16320+14)

function BDR(y)
 poke(16320+12,yellowr*(y/142))
 poke(16320+13,yellowg*(y/142))
 poke(16320+14,yellowb*(y/142))
end

text={
 "EPISODE IV",
 "A new jam",
 "",
 "It is a period",
 "of civil jam.",
 "Rebel TIC80ers",
 "striking from",
 "a hidden base,",
 "have won their",
 "first victory",
 "against the",
 "evil",
 "Bonzomatic",
 "empire.",
 "",
 "",
 "May the 4th",
 "be with you",
 "",
 ""
}

tex={}
texw=80
for line=1,#text do
 yoff=(line-1)*8
 linew=print(text[line],0,0,4)
 cls()
 print(text[line],(texw-linew)//2,0,4)
 for y=0,7 do
  tex[y+yoff]={}
  for x=0,texw do
   tex[y+yoff][x]=pix(x,y)
  end
 end
end

texh=#tex

stars={}
starcount=100
for i=0,starcount do
 stars[i]={
  (math.random()*4)-2,
  (math.random()*4)-2,
  math.random(),
 }
end

function TIC()
 cls()

 tm=time()

 for tm1=0,8 do
  for i=0,starcount do
   star=stars[i]
   starz=(star[3]-(tm+tm1*20)/1234)%1
   starx=star[1]/(starz*2+1)
   stary=star[2]/(starz*2+1)
   pix(
    starx*120+120,
    stary*120+68,
    12+(starz*4)
   )
  end
 end

 camx=0
 camy=-time()/434
 camz=0
 fwdx0=0
 fwdy0=0
 fwdz0=1
 rgtx0=1
 rgty0=0
 rgtz0=0
 upx0=0
 upy0=-1
 upz0=0

 rotx=1--+.2*sin(time()/534)
 
 fwdx=fwdx0
 fwdy=fwdy0*cos(rotx)+fwdz0*sin(rotx)
 fwdz=fwdz0*cos(rotx)-fwdy0*sin(rotx)
 rgtx=rgtx0
 rgty=rgty0*cos(rotx)+rgtz0*sin(rotx)
 rgtz=rgtz0*cos(rotx)-rgty0*sin(rotx)
 upx=upx0
 upy=upy0*cos(rotx)+upz0*sin(rotx)
 upz=upz0*cos(rotx)-upy0*sin(rotx)
 zfar=5

 for sy=0,135 do
  y=(sy-67.5)/120
  for sx=0,239 do
   x=(sx-119.5)/120
   vx=fwdx+x*rgtx+y*upx
   vy=fwdy+x*rgty+y*upy
   vz=fwdz+x*rgtz+y*upz
   
   -- camera vector = cam+t*v
   -- t at z=zfar: (zfar-camz)/vz=t
   tfar=(zfar-camz)/vz
   if tfar>0 then
    xfar=camx+tfar*vx
    yfar=camy+tfar*vy
    xtex=(xfar*4+texw//2)//1
    ytex=(-yfar*3//1)%texh
    if xtex<0 or xtex>=texw then
     --pix(sx,sy,0)
    else
     val=tex[ytex][xtex]
     if val>0 then
      pix(sx,sy,val)
     end
    end
   else
    --pix(sx,sy,0)
   end
  end
 end
end
