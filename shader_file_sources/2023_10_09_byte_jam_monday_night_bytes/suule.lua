abs=math.abs
rand=math.random
sin=math.sin
cos=math.cos
pi=math.pi
flr=math.floor
ceil=math.ceiling

starsx={}
starsy={}
starsc={}

function BOOT()
 for i=0,72 do 
  starsx[i]=240*rand()
  starsy[i]=100*rand()
  starsc[i]=11+4*rand()
 end
end


-- I LOVE QUADS!
function quad(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x2,y2,x3,y3,x4,y4,col)
end

function kitupperbody(shftx)
 -- kimono
 quad(103,64, 123,46, 104,84, 132,77, 13)
 quad(123,46, 128,46, 132,77, 135,75, 15) 
 quad(104,84, 132,77, 105,95, 128,86, 14)
 quad(132,77, 135,75, 128,86, 133,85, 15)
 quad(107,50, 126,44, 103,62, 127,47, 1)
 quad(110,50, 124,44, 105,58, 105,63, 12) 
 quad(109,49, 113,49, 105,58, 105,60, 13)  
 quad(116,51, 122,46, 118,52, 122,48, 1)
 quad(107,59, 117,51, 109,61, 118,52, 2) 
 quad(103,64, 107,59, 103,69, 109,61, 2)
 -- sash
 quad(105,91, 118,89, 104,99, 119,96, 2)
 quad(118,89, 129,85, 119,97, 128,93, 2) 
 quad(129,85, 133,82, 128,93, 132,91, 1)  
 quad(129,85, 133,82, 128,93, 132,91, 1)   
 quad(133,85, 138+shftx,80, 132,89, 137+shftx,92, 1) 
 quad(138+shftx,80, 140+shftx,78, 137+shftx,92, 139+shftx,91, 2)    
end 

function kitlowerbody(shftx)
 quad(105,98, 128,93, 96+shftx/2, 117,123+shftx/2,114,13)
 quad( 96+shftx/2,117,123+shftx/2,114,84+shftx, 136,119,136,13) 
 tri(109,114,100+shftx,136,107+shftx,136,14)
 quad(128,93, 130,91,123+shftx/2,114,128+shftx/2,114,14)  
 quad(123+shftx/2,114,128+shftx/2,114,114+shftx,136,126+shftx,136,14)   
 quad(130,91, 132,90, 128+shftx/2,114,135,112,15)   
 quad(128+shftx/2,114,135,112,126+shftx,136,132+shftx,136,15)    
end

function kithandsfront(shftx)
 tri(123,48,128,65,136,65,14)
 quad(118,59, 130,69, 108+shftx,106,112+shftx,106,15)
 quad(114,94, 128+shftx/2,65, 112+shftx,106,136+shftx/2,65,14)
 quad(111,77, 118,59, 114,94, 128+shftx/2,65,13) 
 line(111,77,118,59,14) 
 tri(111,75,113,79,116,77,2)
 quad(113,79,116,77,113+shftx/2,93,115+shftx/2,93,2)
 quad(113+shftx/2,93,115+shftx/2,93,110+shftx,106,112+shftx,106,2)
 quad(80,74, 173,22, 81,76, 175,24, 1) 
 -- Hands 
 tri(97,74,113,87,112,90, 13) 
 quad(102,70, 111,76, 97, 74, 109,84, 12)
 quad(111,76, 113,79, 109,84, 113,87, 12)
 quad(97,74,  102,70, 93,62,  100,61, 12)
 quad(98,71,  98,74, 91,69, 93,62,   12)
end

function kitears(shftx)
 tri(128+shftx,13,118,24,124,29,12)
 tri(124+shftx,20,120,25,122,28,13)
 tri(113+shftx,12,110,24,115,24,12) 
 tri(112+shftx,18,111,23,113,23,13)  
end 

function kithead(shfty,tim)
 -- headshape
 quad(108,45,125, 40, 110,50, 124,44,13)
 quad(124,28,129, 33, 117,39, 131,45,13)
 quad(88, 40, 93, 37, 99, 48, 128,41,12)
 quad(93, 37, 128,41, 104,32, 123,31,12)
 quad(104,32, 125,31, 108,25, 118,22,12)
 quad(88, 37, 89, 42, 93, 36, 93, 40,15)
 -- eyes
 if tim%120 > 60 then
 elli(111,32,3,1,2)
 elli(111,33,3,1,13)
 elli(111,34,3,1,12)
 else
 elli(111,31,3,1,2)
 elli(111,32,3,1,13)
 elli(111,33,3,1,4) 
 elli(111,34,3,1,12)
 pix(110,32,0)
 end
 -- that smile :)
 line(97,45,99,45,14) 
 line(100,44,104,44,14)
 line(104,44,108,42,14) 
 line(108,42,111,39,14)
 --markings
 quad(120,34,122,34,126,30,124,28,2)
 tri(120,34,122,34,115,37,3)
 line(105,32,110,27,2)
 trib(106,31,108,26,110,27,2)   
end

function ashf(tim,fact)
 return fact*sin(tim/40*pi)
end

function background()
 for i=0,72 do
  pix(starsx[i],starsy[i],starsc[i])
 end 
 for i=0,240 do
  line(i,3*sin(i/16*pi)+3*sin(i/46*pi)+5*sin(i/126*pi)+5*sin(i/39*pi)+100,i,136,7)
 end 
 circ(190,40,10,4)
end 

function TIC()
 cls(0)
 t=time()/60
 background()
 kitupperbody(ashf(t,1.5))
 kitlowerbody(ashf(t,2.5))
 kithandsfront(ashf(t,2))
 kithead(0,t)
 kitears(ashf(t,3))
end

