sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random
pi=math.pi

starx={}
stary={}
stars={}
starc={}

function BOOT()
 vbank(1)
 poke(0x03ff8,4)
 for i=0,300 do
  starx[i]=rand(0,239)
  stary[i]=rand(0,46)
  stars[i]=3*rand()
  starc[i]=8+rand(0,4)
 end
end

function textball(ox,oy,size,zplan)
 ttri(ox-16*size,oy-16*size,
      ox+16*size,oy-16*size,
      ox-16*size,oy+16*size,
      0,0,33,0,0,33,2,1,zplan,zplan,zplan)
 ttri(ox+16*size,oy-16*size,
      ox-16*size,oy+16*size,
      ox+16*size,oy+16*size,
      33,0,0,33,33,33,2,1,zplan,zplan,zplan)
end

function drawball()
 vbank(1)
 cls(1)
 circ(16,16,16,0)
 circb(16,16,16,13) 
 clip(0,0,14,14)
 circb(16,16,16,12)
 clip(8,8,25,25)
 circb(16,16,16,14)
 clip(16,16,25,25)
 circb(16,16,16,15) 
 clip()
 circ(10,10,5,15)
 circ(10,10,4,14)
 circ(10,10,2,13)
 circ(10,10,1,12) 
end

function drawgrid(t)
 line(0,90,240,90,15)
 line(0,92,240,92,15)
 line(0,95,240,95,15)
 line(0,99,240,99,14)
 line(0,105,240,105,14)
 line(0,113,240,113,13)
 line(0,129,240,129,13) 
-- line(120,90,120,95,15)
-- line(120,95,120,105,14)
-- line(120,105,120,136,13) 
end

function drawstars(tim)
 for i=0,300 do
  pix((starx[i]-stars[i]*tim)%240,
       stary[i]+90,starc[i])
 end
end

function drawscroll(tim)
 hackfest={'H','i',' ','H','a',
           'c','k','f','e','s',
           't',' ','2','0','2',
           '5',' ','G','r','e',
           'e','t','i','n','g',
           's',' ',' ','f','r',
           'o','m',' ','S','u',
           'u','l','e',',','A',
           'l','d','r','o','i',
           'd',',','J','t','r',
           'u','k',',','F','R',
           'e','a','d','y',' ',
           'a','n','d',' ','B',
           'o','r','i','s','!',}
 for i=1,70 do  
  print(hackfest[71-i],820-i*8-tim*2%980,50+8*sin(i+tim/5),12,1,1,1)
 end
end

function TIC()
 t=time()/60
 drawball()
 vbank(0)
 cls(4)
 drawgrid()
 elli((t*5)%300-30,107,8-4*abs(sin(t/5)),2-1*abs(sin(t/5)),15)
 textball((t*5)%300-30,100-50*abs(sin(t/5)),0.5,3)
 elli((t*8)%350-60,111,12-6*abs(sin(t/5)),3-1.5*abs(sin(t/5)),15)
 textball((t*8)%350-60,100-70*abs(sin(t/5)),0.75,2)
 elli((t*6)%400-45,116,16-8*abs(sin(t/5)),4-2*abs(sin(t/5)),15)
 textball((t*6)%400-45,100-60*abs(sin(t/5)),1,1)
 elli((t*5.5)%475-75,120,20-10*abs(sin(t/6)),5-2.5*abs(sin(t/6)),15)
 textball((t*5.5)%475-75,100-70*abs(sin(t/6)),1.25,0)
 memcpy(0x08000,0x0000,16320)
 vbank(1)
 memcpy(0x00000,0x08000,16320)
 vbank(0)
 cls(0)
 drawstars(t)
 drawscroll(t)
end
