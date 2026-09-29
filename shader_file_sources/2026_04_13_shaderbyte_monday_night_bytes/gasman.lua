-- hello from gasman

-- happy neil banging out the tunes day
-- to all who celebrate

sin=math.sin
cos=math.cos

pal={}
for i=0,15 do
 pal[i]={
  peek(16320+i*3),
  peek(16321+i*3),
  peek(16322+i*3)
 }
end

for i=0,6 do
 poke(16320+i*3,i*51)
 poke(16321+i*3,0)
 poke(16322+i*3,0)

 poke(16320+15+i*3,0)
 poke(16321+15+i*3,i*51)
 poke(16322+15+i*3,0)

 poke(16320+30+i*3,0)
 poke(16321+30+i*3,0)
 poke(16322+30+i*3,i*51)
end

function TIC()
 tm=time()
 camx=tm/545
 camy=20*sin(tm/18444)
 camz=sin(tm/686)-1

 fwdx0=0
 fwdy0=0
 fwdz0=1
 
 rtx0=1
 rty0=0
 rtz0=0
 
 upx0=0
 upy0=-1
 upz0=0
 
 rotx=0.5*sin(tm/1000)
 roty=0.5*sin(tm/1212)
 
 fwdx1=fwdx0
 fwdy1=fwdy0*cos(rotx)+fwdz0*sin(rotx)
 fwdz1=fwdz0*cos(rotx)-fwdy0*sin(rotx)

 rtx1=rtx0
 rty1=rty0*cos(rotx)+rtz0*sin(rotx)
 rtz1=rtz0*cos(rotx)-rty0*sin(rotx)

 upx1=upx0
 upy1=upy0*cos(rotx)+upz0*sin(rotx)
 upz1=upz0*cos(rotx)-upy0*sin(rotx)
 
 fwdx=fwdx1*cos(roty)+fwdz1*sin(roty)
 fwdy=fwdy1
 fwdz=fwdz1*cos(roty)-fwdx1*sin(roty)
 
 rtx=rtx1*cos(roty)+rtz1*sin(roty)
 rty=rty1
 rtz=rtz1*cos(roty)-rtx1*sin(roty)

 upx=upx1*cos(roty)+upz1*sin(roty)
 upy=upy1
 upz=upz1*cos(roty)-upx1*sin(roty)
 
 for sy=0,135 do
  for sx=0,239 do
   y=(sy-67.5)/120
   x=(sx-119.5)/120
   vx=fwdx-y*upx+x*rtx
   vy=fwdy-y*upy+x*rty
   vz=fwdz-y*upz+x*rtz
   -- p=cam+t*v
   -- find t at z=1
   t=(1-camz)/vz
   if t<0 then
    pix(sx,sy,0)
   else
    px=camx+t*vx
    py=camy+t*vy-12
    texx=px*4//1
    texy=py*4//1
        
    elem=(px*4%1)*3//1
    frx=(px*4%1)*3%1
    fry=py*4%1
    if (
     (frx-0.5)^2+(fry-0.5)^2
     > 0.2
    ) then
     pix(sx,sy,0)
    else

     dist=math.sqrt(texx*texx+texy*texy)
     if (dist-tm/100)/5%3 < 1 then
      lum=5
     else

      val=(
       sin(texx/5+tm/523)
       +sin(texx/6+tm/624)
       +sin(texy/7+tm/725)
       +sin(texy/8+tm/826)
      )*4//1%16

      lum=pal[val][elem+1]//51
     end
     pix(sx,sy,elem*5+lum)
    end
   end
  end
 end

end
