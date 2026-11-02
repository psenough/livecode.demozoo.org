SCX,SCY=240,136
M,T=math,table
TAU=2*M.pi

SHOTS={}
TLAST=nil
THETIME=nil
DT=nil
GRAV = 20.0
LASTFIRE=nil
FONTDATA={}
SPARKS= {}

STRS = {"donk","DONK","FieldFX","byte","jam"}

function rndel(t)
  return t[M.random(1,#t)]
end

function dotime()
  local t=time()/1000.0
  if (TLAST==nil) then
    TLAST=t
    THETIME=t
    DT=0.0001
    LASTFIRE=t
  else
    DT=t-TLAST
    TLAST=THETIME
    THETIME=t
  end
end

function fire(x0,y0,vx,vy,xtime)
  local s = {
    vx=vx,vy=vy,c=3,x=x0,y=y0,xtime=THETIME+xtime
  }
  T.insert(SHOTS,s)
end

function dochar(cno)
  local adr = 0x14604 + 8*cno
  local res = {}
  for dy=0,7 do
    local row=peek(adr+dy)
    for dx=0,7 do
      if (1==(math.floor(row)&1)) then
        T.insert(res,{dx,dy})
      end
      row=row/2
    end
  end
  return res
end

function initfont()
  for i=1,128 do
    local s=string.char(i)
    FONTDATA[s] = dochar(i)
  end
end

function to8(x)
  x=x*255
  if x<0 then x=0 end
  if x>255 then x=255 end
  return x
end



function hsv2rgb(h,s,v)
  function f(n)
    k=(n+6*h)%6
    return v-v*s*M.max(0,M.min(k,4-k,1))
  end
  return {to8(f(5)),to8(f(3)),to8(f(1))}
end

function pal(n,r,g,b)
  local adr = 0x3fc0 + 3*n
  poke(adr,r)
  poke(adr+1,g)
  poke(adr+2,b)
end

function BDR(y)

  local h0=(time()/5000.0 + (y/SCY)*0.5)
  local v=1.0
  local s=1.0
  local rgb
  local h
  for i=0,3 do
    local x=M.floor(255*i/3)
    pal(i,x,x,x)
    
    local lvls = { 0.5,0.7,0.9,1.0}
    local ll = lvls[i+1]
   
    h=(h0+0.25)%1
    rgb=hsv2rgb(h,1.0,ll)
    pal(i+4,rgb[1],rgb[2],rgb[3])

    h=(h0+0.5)%1
 
    rgb=hsv2rgb(h,1.0,ll)
    
    pal(i+8,rgb[1],rgb[2],rgb[3])

    h=(h0+0.75)%1
    rgb=hsv2rgb(h,1.0,1.0) -- 1.0/3.0*i
    rgb=hsv2rgb(h,1.0,ll)
    pal(i+12,rgb[1],rgb[2],rgb[3])
    

  end

end
FFT={}
function dofft()
  for i=1,128 do
    FFT[i]=fft(i)
  end
end

function doprint()
 local x=16
 local y=64
 local s="Hello this is doop's tic80"
 local scl=100.0
 
 
 for i=1,#s do
   local c=string.sub(s,i,i)
   local ix=M.floor((i/#s)*128)
   local dy=FFT[ix]
   if (dy==nil) then
     dy=0.0
   else
     dy=-dy*scl
   end
   print(c,x,SCY-8+dy,15)
   x=x+6
   
 end

end

function BOOT()
 initfont()
end

function TIC()
 cls()
 dotime()
 dofft()
-- doprint()
 
 if (#SHOTS) < 5 then
   if ((THETIME-LASTFIRE) > 1) or ((#SHOTS)==0) then
     local tt = 0.5+M.random() * 3.0
     
     local vy = tt * GRAV
     local th = (0.125 + M.random() * 0.125)*TAU
     local vx = vy / M.tan(th)
     
     local xfrac =0.25 * 0.5*M.random()
     local xtime = (xfrac*SCX)/vx
     
     if (M.random() > 0.5) then
       fire(0,SCY-1,vx,-vy,xtime)
     else
       fire(SCX-1,SCY-1,-vx,-vy,xtime)
     end
   end
 end
 
 local newshots = {}
 local newexps = {}
 
 for i,s in pairs(SHOTS) do
   s.x = s.x + s.vx * DT
   s.y = s.y + s.vy * DT
   s.vy = s.vy + GRAV *DT
   
   if (THETIME >= s.xtime) then --if (THETIME >= s.xtime) then
     T.insert(newexps,s)
   else 
     if (s.x>0) and (s.y>0) and (s.x<SCX) and (s.y<SCY) then
       T.insert(newshots,s)
     end
   end
 end
 SHOTS = newshots
 
 local newsparks = {}
 
 for i,s in pairs(SPARKS) do
   s.x = s.x + s.vx * DT
   s.y = s.y + s.vy * DT
   s.vy = s.vy + GRAV *DT
   if (s.x>0) and (s.y>0) and (s.x<SCX) and (s.y<SCY) then
     T.insert(newsparks,s)
   end
 end
     
 for i,s in pairs(newexps) do
   mystr = rndel(STRS)
   
   local dv=-(#mystr)*6/2
   
   local xxx=M.random()
   if (xxx<0.333) then
     c=7
   elseif (xxx<0.6666) then
     c=0xb
   else
     c=15
   end
   
   local c=M.floor(M.random()*4)*4+3
   
   for j=1,#mystr do
     local cdata = FONTDATA[string.sub(mystr,j,j)]
     
     for k,px in pairs(cdata) do
       local dx=px[1]
       local dy=px[2]
       local vsc = 2.0
       
       for ii=0,3 do
         local js=10.0
         local dth = M.random() * TAU /365.0 * 5
         local jdx = M.cos(dth)*js
         local jdy = M.sin(dth)*js
         local vx = s.vx + vsc *(dv+dx) + jdx
         local vy=s.vy + vsc*dy + jdy
         local spk = {
           x=s.x,y=s.y,c=c-ii,
           vx=vx,
           vy=vy
         }
         
         T.insert(newsparks,spk)
       end
     end
     dv = dv + 6.0
   end
 end
 
 SPARKS=newsparks
 
 -- draw
 
 for i,s in pairs(SHOTS) do
   pix(s.x,s.y,s.c)
   pix(s.x+1,s.y,s.c)
   pix(s.x,s.y+1,s.c)
   pix(s.x+1,s.y+1,s.c)

 end
 
 for i,s in pairs(SPARKS) do
   pix(s.x,s.y,s.c)
 end


end
