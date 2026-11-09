-- greetz to catnip, lex, violet, & you!
sx=240
sy=136
fw=4
fh=6

myfft = {}
fm = {}
nbux = 255
msg="   HELLO :)  GREETZ TO: LEX, CATNIP, VIOLET, ALDROID, POLYNOMIAL, AND EVERYONE WATCHING THE STREAM! ALSO APOLOGIES TO PETER SAVILE...     "
bl={}
function pal(i,r,g,b)
  adr=0x3fc0+3*i
  poke(adr,r)
  poke(adr+1,g)
  poke(adr+2,b)
end

function init()
  for i=1,nbux do
    myfft[i]=0
    fm[i]=0
  end
  
  vbank(0)
  cls(0)
  cw=sx/fw
  nl=math.ceil((#msg)/cw)
  for i=0,nl-1 do
    s=string.sub(msg,1+i*cw,(i+1)*cw)
    print(s,0,i*fh, 1, 1,1, true)
  end
  vbank(1)
  pal(1,0,0,0)
  pal(2,255,255,255)
end
init()


function dofft()
  for i=1,nbux do
   f=fft(i)
   if f>fm[i] then
     fm[i]=f
   end
   if 0==fm[i] then
     myfft[i]=0
   else
     myfft[i]=f/fm[i]
   end
  end
end

function getheight(cx,cy)
  xx = cx*fw
  yy = cy*(fh-1)
  while xx>sx do
    xx=xx-sx
    yy=yy+fh
  end
  vbank(0)
  h=pix(xx,yy)
  vbank(1)
  return h
  
 
  
end

sin=math.sin
pi=math.pi
function BDR(y)
  ph=time()/1000/2*pi + y/64*pi
  b=24
  a=255-b
  r=a+b*sin(ph)
  g=a+b*sin(ph+0.66*pi)
  b=a+b*sin(ph+1.33*pi)
  vbank(1)
  pal(12,r,g,b)
end

function xpr(s,x0,y0,c,ss)
  x=x0
  y=y0

  for i=1,#s do
    ii = math.floor( (i/#s)*#bl )
    if (ii<=0) then ii=1 end
    dy = bl[ii]*16*ss
    dx = print(string.sub(s,i,i),x,y+dy,c, 2,2)
    x=x+dx
  end
end

lines={}
function TIC()
  dofft()
  vbank(1)

  cls(1)
  
  l={}
  for i=1,64 do
    l[i]=myfft[i]
  end
  table.insert(lines,l)
  if ((#lines)>16) then
    table.remove(lines,1)
  end
  
  bb=0
  nbb=16
  for i=1,nbb do
    bb=bb+l[i]
  end
  bb=bb/nbb
  table.insert(bl,bb)
  if (#bl>16) then
    table.remove(bl,1)
  end
  
  cps=1
  cpos = ( (time()/1000)*cps )%(#msg)

  xpr("Jam Division",48,0,2,1)
  --print("Unknown Bytes",48, 117, 2, 2,2)
  xpr("Unknown Bytes",48,117, 2, -1)
  for lno=1,#lines do
   l=lines[lno]
   lwid = 128 + 64*lno/#lines
   for i=1,#l do
     x=sx/2 -lwid/2 + lwid*(i/#l) 
     dy_fft = -l[i]*8
     dy_msg = -20*getheight(cpos+(i/#l)*2.5, lno/#lines)
     y = 26 + 85*(lno/#lines) + dy_fft + dy_msg
     
     if (i>1) then
       line(xprev,yprev,x,y,12)
     end
     xprev=x
     yprev=y
   end
  end

end

