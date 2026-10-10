local rand=math.random
local pi=math.pi
local cos=math.cos
local sin=math.sin
local abs=math.abs
local flr=math.floor
local add=table.insert
local rem=table.remove

starsx={}
starsy={}
starsc={}
clouds1={}
clouds2={}
clouds3={}

pal={0x07,0x08,0x0c,
     0x89,0x83,0x78,
     0xc4,0xb5,0x9b,
     0xe7,0xce,0xa2,

     0xff,0xe3,0xb2,
     0xdc,0x21,0x21,
     0x91,0x10,0x10,
     0x0d,0x16,0x3f,

     0x29,0x36,0x6f,
     0x3b,0x5d,0xc9,
     0x41,0xa6,0xf6,
     0x73,0xef,0xf7,

     0xf4,0xf4,0xf4,
     0x94,0xb0,0xc2,
     0x55,0x6c,0x86,
     0x33,0x3c,0x57 }

function BOOT()
 for i=0,72 do 
  starsx[i]=240*rand()
  starsy[i]=86*rand()
  starsc[i]=11+4*rand()
 end
-- Silly LUA, indicies start at 0 :)
 for i=1,#pal do
  poke(0x03FC0+i-1,pal[i])
 end 
 for i=0,240 do
  clouds1[i]=0
  clouds2[i]=0
  clouds3[i]=0    
 end
end

function cycleit()
 rem(clouds1,240)
 add(clouds1,1,flr(64*fft(0)-1))
 rem(clouds2,240)
 add(clouds2,1,flr(64*fft(4)-1)) 
 rem(clouds3,240)
 add(clouds3,1,flr(64*fft(8)-1)) 
end

function drwstrs()
 vbank(0)
 for i=0,72 do
  pix(starsx[i],starsy[i],starsc[i])
 end 
end

function drwmnts()
 vbank(0)
 for i=0,239 do
  _1wav=3*cos(2-(i/8.1)/4*pi)
  _2wav=3*cos((i/4.7)/4*pi) 
  _3wav=3*cos((i/5.4)/4*pi) 
  line(i,60+_1wav+_2wav+_3wav,i,87,8)
  _1wav=sin((i/8.2)/5*pi)
  _2wav=sin((i/12.7)/5*pi) 
  _3wav=sin((i/3.2)/5*pi) 
  line(i,74+_1wav+_2wav+_3wav,i,87,9)
  _1wav=sin((i/12.2)/5*pi)
  _2wav=sin((i/2.7)/5*pi) 
  _3wav=sin((i/8.2)/5*pi) 
  line(i,82+_1wav+_2wav+_3wav,i,87,10)
 end
end

function drwmn()
 circ(120,25,21,4)
-- circ(120,25,14,3) 
 elli(120,26,16,13,2)
 ellib(120,26,16,12,1)
 elli(120,24,16,11,4)
 circ(111,18,5,2)
 circ(111,19,4,0)
 circ(129,18,5,2)
 circ(129,19,4,0)
 tri(120,25,125,29,115,29,2)
 circ(111,21,1,5)
 circ(129,21,1,5)   
end

-- ATTEMPT 2

function drwclds()
 for j=0,240 do
  if clouds3[j] > 0 then 
   circ(j,26,clouds3[j],13) 
   circ(j,28,clouds3[j],12)
  end 
  if clouds2[j] > 0 then   
   circ(j,36,clouds2[j],13) 
   circ(j,34,clouds2[j],12)
  end 
  if clouds1[j] > 0 then   
   circ(j,42,clouds1[j],13) 
   circ(j,40,clouds1[j],12)
  end 
 end 
end
    
function TIC()
 timepass=time()//20
 cls(0)
 drwstrs()
 drwmnts()
 drwmn()
 cycleit()
 drwclds()
 
end

function SCN(row)
 if row > 87 then
  vbank(0)
  for index=0,239 do 
   colour=pix(index,87-(row-87)*2)
   pix(index,row,colour)
  end
  poke(0x03FF9, 3*sin((87-row+timepass/6)/4*pi)) 
 else
  poke(0x03FF9, 0)
 end
end  



 


