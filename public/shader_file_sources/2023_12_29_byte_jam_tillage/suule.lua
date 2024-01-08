-- HELLO EVERYBODY!!!!
-- I have something fun to show today
-- Mind you I went overboard with code
-- again and the pre-prepared code is
-- 10kb :D, the rest I will finish
-- during the jam!

-- Greetz to the people in chat and
-- co-participants - MrsBeanbag,
-- Gasman and JTruk!

sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi
ins=table.insert
rem=table.remove
l=line

circles={}
circlec={}

function BOOT()
 for i=1,22 do
  circles[i]=i*20
  circlec[i]=1+i%4
 end
end

-- Let's start with simple stuff

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c)
 tri(x2,y2,x3,y3,x4,y4,c)
end

function clmp(var,lrng,hrng)
 if var < lrng then 
  return lrng
 else
  if var > hrng then 
   return hrng 
  else 
   return var 
  end 
 end
end

-- And follow with the monster!

function head(x,y,ax,ay,m,st)
 ox=x+ax
 oy=y+ay
 if st == 0 then 
  q(ox+m*3,oy-11, ox+m*10,oy-9, ox+m*-3,oy+10, ox+m*17,oy+5, 13)
  q(ox+m*-3,oy+10, ox+m*17,oy+5,ox+m*-4+ax*0.5,oy+20, ox+m*14+ax*0.5,oy+20, 14)    
  q(ox+m*-11,oy+8, ox+m*-3,oy+10, ox+m-17+ax*0.25,oy+20, ox+m*-4+ax*0.5,oy+20, 14)  
  q(ox+m*-10,oy-10,ox+m*-8,oy-14, ox+m-9,oy-8, ox+m*-4,oy-9, 13) 
  q(ox+m-15,oy-9,  ox+m*-8,oy-14, ox+m*-15,oy-7,ox+m*-10,oy-10, 13)   
  q(ox+m*-3,        oy+10, ox+m*17,       oy+5,  ox+m*-4+ax*0.5, oy+20, ox+m*14+ax*0.5,oy+20, 14)    
  q(ox+m*-11,       oy+8,  ox+m*-3,       oy+10, ox+m-17+ax*0.25,oy+20, ox+m*-4+ax*0.5,oy+20, 14)  
  q(ox+m*-4+ax*0.5, oy+20, ox+m*14+ax*0.5,oy+20, ox+m*-4+ax*0.5, oy+30, ox+m*10+ax*0.5,oy+25, 14)    
  q(ox+m-17+ax*0.25,oy+20, ox+m*-4+ax*0.5,oy+20, ox+m*-11+ax*0.5,oy+28,  ox+m*-4+ax*0.5,oy+30, 14) 
  elli(ox+m*0,oy,10,11,13)
  elli(ox+m*-1,oy-1,9,11,12)
  q(ox+m*-11,oy-3, ox+m*-1,oy-3, ox+m*-11,oy+8, ox+m*-1,oy+9,12)
  q(ox+m*-22,oy-3, ox+m*-1,oy-3, ox+m*-22,oy+4, ox+m*-8,oy+9,13) 
  q(ox+m*-22,oy-3, ox+m*-1,oy-3, ox+m*-22,oy+4, ox+m*-7,oy+8,12)    
  q(ox+m*-27,oy-3,ox+m*-22,oy-3, ox+m*-25,oy+3, ox+m*-22,oy+4,12)  
  q(ox+m*-27,oy-3,ox+m*-23,oy-3, ox+m*-27,oy+1, ox+m*-23,oy,  15)   
 -- hair  
  q(ox+m*-4,oy-14, ox+m*3,oy-12, ox+m*-7,oy-8,ox+m*4,oy-10, 12) 
  q(ox+m*-8,oy-10, ox+m*-4,oy-14,ox+m*-15,oy-11,ox+m*-7,oy-8, 12)   
 -- ear
  q(ox+m*1,oy-9,  ox+m*6,oy-11,  ox+m*6,oy-4, ox+m*9,oy-6, 13)
  q(ox+m*6,oy-11,  ox+m*11,oy-12,ox+m*9,oy-6, ox+m*14,oy-7,12)  
  q(ox+m*9,oy-6, ox+m*14,oy-7,   ox+m*10,oy-4,ox+m*12,oy-4,12)    
 -- face
  l(ox+m*-11,oy-4,ox+m*-10,oy-4,14)
  l(ox+m*-13,oy+6,ox+m*-10,oy+6,14)
  l(ox+m*-10,oy+6,ox+m*-8,oy+4,14) 
  l(ox+m*-5,oy-3,ox+m,oy-4,14)  
 end 
end

function upperbody(ax,ay,bx,by)
-- neck
 q(115+ax,45+ay, 117+ax,45+ay, 113+ax,49+ay, 117+ax,50+ay, 13) 
 q(117+ax,45+ay, 122+ax,45+ay, 117+ax,50+ay, 122+ax,50+ay, 13) 
 q(122+ax,45+ay, 124+ax,45+ay, 122+ax,50+ay, 126+ax,49+ay, 13)  
-- top
 elli(105+ax,59+ay,6,6,13)
 elli(135+ax,59+ay,6,6,13) 
 q(106+ax,52+ay, 113+ax,49+ay, 108+ax,56+ay, 114+ax,53+ay, 2)
 q(113+ax,49+ay, 117+ax,50+ay, 114+ax,53+ay, 117+ax,54+ay, 12) 
 q(117+ax,50+ay, 122+ax,50+ay, 117+ax,54+ay, 122+ax,54+ay, 12) 
 q(122+ax,50+ay, 126+ax,49+ay, 122+ax,54+ay, 125+ax,53+ay, 12)  
 q(126+ax,49+ay, 133+ax,52+ay, 125+ax,53+ay, 131+ax,56+ay, 2)   

 q(108+ax,56+ay, 114+ax,53+ay, 108+ax,60+ay, 114+ax,62+ay, 2)
 q(114+ax,53+ay, 117+ax,54+ay, 114+ax,62+ay, 118+ax,63+ay, 2) 
 q(117+ax,54+ay, 122+ax,54+ay, 118+ax,63+ay, 121+ax,63+ay, 2) 
 q(122+ax,54+ay, 125+ax,53+ay, 121+ax,63+ay, 125+ax,62+ay, 2)  
 q(125+ax,53+ay, 131+ax,56+ay, 125+ax,62+ay, 131+ax,60+ay, 2)   

 q(102+ax,66+ay, 108+ax,60+ay, 106+ax,74+ay, 110+ax,72+ay, 1)
 q(108+ax,60+ay, 114+ax,62+ay, 110+ax,72+ay, 114+ax,71+ay, 1)
 q(114+ax,62+ay, 118+ax,63+ay, 114+ax,71+ay, 118+ax,70+ay, 1) 
 q(118+ax,63+ay, 121+ax,63+ay, 118+ax,70+ay, 121+ax,70+ay, 1) 
 q(121+ax,63+ay, 125+ax,62+ay, 121+ax,70+ay, 125+ax,71+ay, 1)  
 q(125+ax,62+ay, 131+ax,60+ay, 125+ax,71+ay, 129+ax,72+ay, 1)   
 q(131+ax,60+ay, 137+ax,66+ay, 129+ax,72+ay, 133+ax,74+ay, 1)    
-- body
 q(106+ax,74+ay, 110+ax,72+ay, 109+ax+bx/2,81+ay+by/2, 112+ax+bx/2,77+ay+by/2, 13)
 q(110+ax,72+ay, 114+ax,71+ay, 112+ax+bx/2,77+ay+by/2, 115+ax+bx/2,75+ay+by/2, 13)
 q(114+ax,71+ay, 118+ax,70+ay, 115+ax+bx/2,75+ay+by/2, 118+ax+bx/2,74+ay+by/2, 13) 
 q(118+ax,70+ay, 121+ax,70+ay, 118+ax+bx/2,74+ay+by/2, 121+ax+bx/2,74+ay+by/2, 13) 
 q(121+ax,70+ay, 125+ax,71+ay, 121+ax+bx/2,74+ay+by/2, 124+ax+bx/2,74+ay+by/2, 13)  
 q(125+ax,71+ay, 129+ax,72+ay, 124+ax+bx/2,74+ay+by/2, 127+ax+bx/2,77+ay+by/2, 13)   
 q(129+ax,72+ay, 133+ax,74+ay, 127+ax+bx/2,77+ay+by/2, 130+ax+bx/2,81+ay+by/2, 13)    

 q(109+ax+bx/2,81+ay+by/2, 112+ax+bx/2,77+ay+by/2, 108+ax+bx,88+ay+by, 111+ax+bx,87+ay+by, 13)
 q(112+ax+bx/2,77+ay+by/2, 115+ax+bx/2,75+ay+by/2, 111+ax+bx,87+ay+by, 115+ax+bx,86+ay+by, 12)
 q(115+ax+bx/2,75+ay+by/2, 118+ax+bx/2,74+ay+by/2, 115+ax+bx,86+ay+by, 118+ax+bx,86+ay+by, 12) 
 q(118+ax+bx/2,74+ay+by/2, 121+ax+bx/2,74+ay+by/2, 118+ax+bx,86+ay+by, 121+ax+bx,86+ay+by, 12) 
 q(121+ax+bx/2,74+ay+by/2, 124+ax+bx/2,74+ay+by/2, 121+ax+bx,86+ay+by, 124+ax+bx,86+ay+by, 12)  
 q(124+ax+bx/2,74+ay+by/2, 127+ax+bx/2,77+ay+by/2, 124+ax+bx,86+ay+by, 129+ax+bx,87+ay+by, 12)   
 q(127+ax+bx/2,77+ay+by/2, 130+ax+bx/2,81+ay+by/2, 129+ax+bx,87+ay+by, 132+ax+bx,88+ay+by, 13)    
end

function lowerbody(ax,ay,bx,by)
-- panties
 q(108+ax,88+ay, 111+ax,87+ay, 105+ax*1.1,91+ay, 110+ax*1.1,94+ay, 2)
 q(111+ax,87+ay, 115+ax,86+ay, 110+ax*1.1,94+ay, 114+ax*1.1,96+ay, 2)
 q(115+ax,86+ay, 118+ax,86+ay, 114+ax*1.1,96+ay, 118+ax*1.1,98+ay, 2) 
 q(118+ax,86+ay, 121+ax,86+ay, 118+ax*1.1,98+ay, 121+ax*1.1,98+ay, 2) 
 q(121+ax,86+ay, 124+ax,86+ay, 121+ax*1.1,98+ay, 125+ax*1.1,96+ay, 2)  
 q(124+ax,86+ay, 129+ax,87+ay, 125+ax*1.1,96+ay, 129+ax*1.1,94+ay, 2)   
 q(129+ax,87+ay, 132+ax,88+ay, 129+ax*1.1,94+ay, 134+ax*1.1,91+ay, 2)    

 q(105+ax*1.1,91+ay, 110+ax*1.1,94+ay, 103+ax*1.1+bx*0.25,95+ay, 109+ax*1.1+bx*0.25,100+ay,1)
 q(110+ax*1.1,94+ay, 114+ax*1.1,96+ay, 109+ax*1.1+bx*0.25,100+ay,113+ax*1.1+bx*0.25,103+ay,1)
 q(114+ax*1.1,96+ay, 118+ax*1.1,98+ay, 113+ax*1.1+bx*0.25,103+ay,117+ax*1.1+bx*0.25,106+ay,1) 
 q(118+ax*1.1,98+ay, 121+ax*1.1,98+ay, 117+ax*1.1+bx*0.25,106+ay,122+ax*1.1+bx*0.25,106+ay,1) 
 q(121+ax*1.1,98+ay, 125+ax*1.1,96+ay, 122+ax*1.1+bx*0.25,106+ay,126+ax*1.1+bx*0.25,103+ay,1)  
 q(125+ax*1.1,96+ay, 129+ax*1.1,94+ay, 126+ax*1.1+bx*0.25,103+ay,130+ax*1.1+bx*0.25,100+ay,1)   
 q(129+ax*1.1,94+ay, 134+ax*1.1,91+ay, 130+ax*1.1+bx*0.25,100+ay,136+ax*1.1+bx*0.25,95+ay, 1)    
-- legs
 q(103+ax*1.1+bx*0.25,95+ay, 109+ax*1.1+bx*0.25,100+ay,98+ax+bx*0.25,106+ay+by,  103+ax+bx*0.25,109+ay+by, 13)
 q(109+ax*1.1+bx*0.25,100+ay,113+ax*1.1+bx*0.25,103+ay,103+ax+bx*0.25,109+ay+by, 111+ax+bx*0.25,113+ay+by, 12)
 q(113+ax*1.1+bx*0.25,103+ay,117+ax*1.1+bx*0.25,106+ay,111+ax+bx*0.25,113+ay+by, 117+ax+bx*0.25,113+ay+by, 12)
 q(98+ax+bx*0.25,106+ay+by,  103+ax+bx*0.25,109+ay+by,  98+ax+bx*0.5,114+ay+by,103+ax+bx*0.5,116+ay+by, 13)
 q(103+ax+bx*0.25,109+ay+by, 111+ax+bx*0.25,113+ay+by, 103+ax+bx*0.5,116+ay+by,111+ax+bx*0.5,118+ay+by, 12)
 q(111+ax+bx*0.25,113+ay+by, 117+ax+bx*0.25,113+ay+by, 111+ax+bx*0.5,118+ay+by,118+ax+bx*0.5,118+ay+by, 12)
 q(98+ax+bx*0.5,114+ay+by, 103+ax+bx*0.5,116+ay+by,  99+ax+bx*0.75,123+ay+by,104+ax+bx*0.75,125+ay+by, 13)
 q(103+ax+bx*0.5,116+ay+by,111+ax+bx*0.5,118+ay+by, 104+ax+bx*0.75,125+ay+by,111+ax+bx*0.75,125+ay+by, 12)
 q(111+ax+bx*0.5,118+ay+by,118+ax+bx*0.5,118+ay+by, 111+ax+bx*0.75,125+ay+by,118+ax+bx*0.75,125+ay+by, 12)
 q( 99+ax+bx*0.75,123+ay+by,104+ax+bx*0.75,125+ay+by, 104+ax+bx,136,107+ax+bx,136, 13)
 q(104+ax+bx*0.75,125+ay+by,111+ax+bx*0.75,125+ay+by, 107+ax+bx,136,111+ax+bx,136, 12)
 q(111+ax+bx*0.75,125+ay+by,118+ax+bx*0.75,125+ay+by, 111+ax+bx,136,117+ax+bx,136, 12)
  
 q(136+ax*1.1+bx*0.25,95+ay, 130+ax*1.1+bx*0.25,100+ay,141+ax+bx*0.25,106+ay+by, 136+ax+bx*0.25,109+ay+by, 13)
 q(130+ax*1.1+bx*0.25,100+ay,126+ax*1.1+bx*0.25,103+ay,136+ax+bx*0.25,109+ay+by, 128+ax+bx*0.25,113+ay+by, 12)
 q(126+ax*1.1+bx*0.25,103+ay,122+ax*1.1+bx*0.25,106+ay,128+ax+bx*0.25,113+ay+by, 122+ax+bx*0.25,113+ay+by, 12)
 q(141+ax+bx*0.25,106+ay+by, 136+ax+bx*0.25,109+ay+by, 141+ax+bx*0.5,114+ay+by,136+ax+bx*0.5,116+ay+by, 13)
 q(136+ax+bx*0.25,109+ay+by, 128+ax+bx*0.25,113+ay+by, 136+ax+bx*0.5,116+ay+by,128+ax+bx*0.5,118+ay+by, 12)
 q(128+ax+bx*0.25,113+ay+by, 122+ax+bx*0.25,113+ay+by, 128+ax+bx*0.5,118+ay+by,121+ax+bx*0.5,118+ay+by, 12)
 q(141+ax+bx*0.5,114+ay+by, 136+ax+bx*0.5,116+ay+by, 140+ax+bx*0.75,123+ay+by,135+ax+bx*0.75,125+ay+by, 13)
 q(136+ax+bx*0.5,116+ay+by, 128+ax+bx*0.5,118+ay+by, 135+ax+bx*0.75,125+ay+by,128+ax+bx*0.75,125+ay+by, 12)
 q(128+ax+bx*0.5,118+ay+by, 121+ax+bx*0.5,118+ay+by, 128+ax+bx*0.75,125+ay+by,121+ax+bx*0.75,125+ay+by, 12)
 q(140+ax+bx*0.75,123+ay+by,135+ax+bx*0.75,125+ay+by, 135+ax+bx,136,132+ax+bx,136, 13)
 q(135+ax+bx*0.75,125+ay+by,128+ax+bx*0.75,125+ay+by, 132+ax+bx,136,128+ax+bx,136, 12)
 q(128+ax+bx*0.75,125+ay+by,121+ax+bx*0.75,125+ay+by, 128+ax+bx,136,122+ax+bx,136, 12) 
end

function drawarm(x,y,ax,ay,rot,m)
 ox=x+ax
 oy=y+ay
 q(ox+-4*m*cos(rot)-2*sin(rot),oy+-4*m*sin(rot)+2*cos(rot),
   ox+4*m*cos(rot)-3*sin(rot) ,oy+4*m*sin(rot)+3*cos(rot),
   ox-1*m*cos(rot)-5*sin(rot) ,oy-1*m*sin(rot)+5*cos(rot),
   ox-2*m*cos(rot)-5*sin(rot) ,oy-2*m*sin(rot)+5*cos(rot),13)
 q(ox-5*m*cos(rot)+4*sin(rot) ,oy-5*m*sin(rot)-4*cos(rot),
   ox+4*m*cos(rot)-1*sin(rot) ,oy+4*m*sin(rot)+1*cos(rot),
   ox-4*m*cos(rot)-2*sin(rot) ,oy-4*m*sin(rot)+2*cos(rot),
   ox+4*m*cos(rot)-3*sin(rot) ,oy+4*m*sin(rot)+3*cos(rot),12)
 q(ox-4*m*cos(rot)+10*sin(rot),oy-5*m*sin(rot)-10*cos(rot),
   ox+4*m*cos(rot)+5*sin(rot) ,oy+4*m*sin(rot)-5*cos(rot),
   ox-5*m*cos(rot)+4*sin(rot) ,oy-5*m*sin(rot)-4*cos(rot),
   ox+4*m*cos(rot)-1*sin(rot) ,oy+4*m*sin(rot)+1*cos(rot),12)
 q(ox+0*m*cos(rot)+23*sin(rot),oy-0*m*sin(rot)-23*cos(rot),
   ox+4*m*cos(rot)+21*sin(rot),oy+4*m*sin(rot)-21*cos(rot),
   ox-4*m*cos(rot)+10*sin(rot),oy-5*m*sin(rot)-10*cos(rot),
   ox+4*m*cos(rot)+5*sin(rot) ,oy+4*m*sin(rot)-5*cos(rot),12)

 q(ox+0*m*cos(rot)+26*sin(rot),oy-0*m*sin(rot)-26*cos(rot),
   ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+0*m*cos(rot)+23*sin(rot),oy-0*m*sin(rot)-23*cos(rot),
   ox+4*m*cos(rot)+21*sin(rot),oy+4*m*sin(rot)-21*cos(rot),12)   
 q(ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),
   ox+4*m*cos(rot)+21*sin(rot),oy+4*m*sin(rot)-21*cos(rot),
   ox+8*m*cos(rot)+22*sin(rot),oy+8*m*sin(rot)-22*cos(rot),12)   
 q(ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),
   ox+9*m*cos(rot)+27*sin(rot),oy+9*m*sin(rot)-27*cos(rot),
   ox+8*m*cos(rot)+22*sin(rot),oy+8*m*sin(rot)-22*cos(rot),
   ox+11*m*cos(rot)+24*sin(rot),oy+11*m*sin(rot)-24*cos(rot),12)   

 q(ox+0*m*cos(rot)+32*sin(rot),oy-0*m*sin(rot)-32*cos(rot),
   ox+4*m*cos(rot)+33*sin(rot),oy+4*m*sin(rot)-33*cos(rot),
   ox+0*m*cos(rot)+26*sin(rot),oy-0*m*sin(rot)-26*cos(rot),
   ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),12)   
 q(ox+4*m*cos(rot)+33*sin(rot),oy+4*m*sin(rot)-33*cos(rot),
   ox+7*m*cos(rot)+32*sin(rot),oy+7*m*sin(rot)-32*cos(rot),
   ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),12)   
 q(ox+7*m*cos(rot)+32*sin(rot),oy+7*m*sin(rot)-32*cos(rot),
   ox+9*m*cos(rot)+30*sin(rot),oy+9*m*sin(rot)-30*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),
   ox+9*m*cos(rot)+27*sin(rot),oy+9*m*sin(rot)-27*cos(rot),12)   

 l(ox+7*m*cos(rot)+32*sin(rot),oy+7*m*sin(rot)-32*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),13)
 l(ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),
   ox+9*m*cos(rot)+27*sin(rot),oy+9*m*sin(rot)-27*cos(rot),13)   
 l(ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),13)         
 l(ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+6*m*cos(rot)+27*sin(rot),oy+6*m*sin(rot)-27*cos(rot),13)         
 l(ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+2*m*cos(rot)+27*sin(rot),oy+2*m*sin(rot)-27*cos(rot),13)     
 l(ox+4*m*cos(rot)+33*sin(rot),oy+4*m*sin(rot)-33*cos(rot),   
   ox+2*m*cos(rot)+27*sin(rot),oy+2*m*sin(rot)-27*cos(rot),13)   
 l(ox+2*m*cos(rot)+27*sin(rot),oy+2*m*sin(rot)-27*cos(rot),  
   ox+0*m*cos(rot)+26*sin(rot),oy-0*m*sin(rot)-26*cos(rot),13)
 l(ox+4*m*cos(rot)+27*sin(rot),oy+4*m*sin(rot)-27*cos(rot),
   ox+2*m*cos(rot)+24*sin(rot),oy+2*m*sin(rot)-24*cos(rot),13)
 l(ox+3*m*cos(rot)+23*sin(rot),oy+3*m*sin(rot)-23*cos(rot),
   ox+2*m*cos(rot)+24*sin(rot),oy+2*m*sin(rot)-24*cos(rot),13)
 l(ox+3*m*cos(rot)+23*sin(rot),oy+3*m*sin(rot)-23*cos(rot),
   ox+6*m*cos(rot)+24*sin(rot),oy+6*m*sin(rot)-24*cos(rot),13)
end

function arms(ax,ay,bx,by)
-- elli(103+ax,59+ay,5,5,13)
-- elli(137+ax,59+ay,5,5,13) 
 elli(90+bx,70+by,4,4,13)
 elli(150+bx,70+by,4,4,13)
 q(100+ax,54+ay,105+ax,62+ay,89+bx,64+by,95+bx,72+by,13) 
 q(135+ax,62+ay,140+ax,54+ay,145+bx,72+by,151+bx,64+by,13)
end

function tail(x,y,ax,ay,rot)
 ox=x+ax
 oy=y+ay
 q(ox-2*cos(rot)-0*sin(rot) ,oy-2*sin(rot)+0*cos(rot),
   ox+0*cos(rot)-0*sin(rot) ,oy+0*sin(rot)+0*cos(rot),
   ox-7*cos(rot)-10*sin(rot),oy-7*sin(rot)+10*cos(rot),
   ox-0*cos(rot)-12*sin(rot),oy-0*sin(rot)+12*cos(rot),13)
 q(ox+2*cos(rot)-0*sin(rot) ,oy+2*sin(rot)+0*cos(rot),
   ox+0*cos(rot)-0*sin(rot) ,oy+0*sin(rot)+0*cos(rot),
   ox+7*cos(rot)-10*sin(rot),oy+7*sin(rot)+10*cos(rot),
   ox-0*cos(rot)-12*sin(rot),oy-0*sin(rot)+12*cos(rot),13)
   
 q(ox-7*cos(rot)-10*sin(rot),oy-7*sin(rot)+10*cos(rot),
   ox-0*cos(rot)-12*sin(rot),oy-0*sin(rot)+12*cos(rot),
   ox-9*cos(rot)-16*sin(rot),oy-9*sin(rot)+16*cos(rot),
   ox+0*cos(rot)-19*sin(rot) ,oy+0*sin(rot)+19*cos(rot),13)
 q(ox+7*cos(rot)-10*sin(rot),oy+7*sin(rot)+10*cos(rot),
   ox+0*cos(rot)-12*sin(rot),oy+0*sin(rot)+12*cos(rot),
   ox+9*cos(rot)-16*sin(rot),oy+9*sin(rot)+16*cos(rot),
   ox+0*cos(rot)-19*sin(rot) ,oy+0*sin(rot)+19*cos(rot),13)

 q(ox-9*cos(rot)-16*sin(rot),oy-9*sin(rot)+16*cos(rot),
   ox+0*cos(rot)-19*sin(rot) ,oy+0*sin(rot)+19*cos(rot),
   ox-10*cos(1.1*rot)-23*sin(1.1*rot),oy-10*sin(1.1*rot)+23*cos(1.1*rot),
   ox-0*cos(1.1*rot)-25*sin(1.1*rot),oy-0*sin(1.1*rot)+25*cos(1.1*rot),14)
 q(ox+9*cos(rot)-16*sin(rot),oy+9*sin(rot)+16*cos(rot),
   ox+0*cos(rot)-19*sin(rot) ,oy+0*sin(rot)+19*cos(rot),
   ox+10*cos(1.1*rot)-23*sin(1.1*rot),oy+10*sin(1.1*rot)+23*cos(1.1*rot),
   ox+0*cos(1.1*rot)-25*sin(1.1*rot),oy+0*sin(1.1*rot)+25*cos(1.1*rot),14)

 q(ox-10*cos(1.1*rot)-23*sin(1.1*rot),oy-10*sin(1.1*rot)+23*cos(1.1*rot),
   ox-0*cos(1.1*rot)-25*sin(1.1*rot),oy-0*sin(1.1*rot)+25*cos(1.1*rot),
   ox-9*cos(1.2*rot)-30*sin(1.2*rot),oy-9*sin(1.2*rot)+30*cos(1.2*rot),
   ox+0*cos(1.2*rot)-31*sin(1.2*rot),oy+0*sin(1.2*rot)+31*cos(1.2*rot),14)
 q(ox+10*cos(1.1*rot)-23*sin(1.1*rot),oy+10*sin(1.1*rot)+23*cos(1.1*rot),
   ox+0*cos(1.1*rot)-25*sin(1.1*rot), oy+0*sin(1.1*rot)+25*cos(1.1*rot),
   ox+8*cos(1.2*rot)-30*sin(1.2*rot),oy+8*sin(1.2*rot)+30*cos(1.2*rot),
   ox+0*cos(1.2*rot)-31*sin(1.2*rot),oy+0*sin(1.2*rot)+31*cos(1.2*rot),14)

 q(ox-8*cos(1.2*rot)-30*sin(1.2*rot),oy-8*sin(1.2*rot)+30*cos(1.2*rot),
   ox+0*cos(1.2*rot)-31*sin(1.2*rot),oy+0*sin(1.2*rot)+31*cos(1.2*rot),
   ox-6*cos(1.3*rot)-37*sin(1.3*rot),oy-6*sin(1.3*rot)+37*cos(1.3*rot),
   ox-0*cos(1.3*rot)-35*sin(1.3*rot),oy-0*sin(1.3*rot)+35*cos(1.3*rot),14)
 q(ox+8*cos(1.2*rot)-30*sin(1.2*rot),oy+8*sin(1.2*rot)+30*cos(1.2*rot),
   ox+0*cos(1.2*rot)-31*sin(1.2*rot),oy+0*sin(1.2*rot)+31*cos(1.2*rot),
   ox+6*cos(1.3*rot)-37*sin(1.3*rot),oy+6*sin(1.3*rot)+37*cos(1.3*rot),
   ox+0*cos(1.3*rot)-35*sin(1.3*rot),oy+0*sin(1.3*rot)+35*cos(1.3*rot),14)

 q(ox-6*cos(1.3*rot)-37*sin(1.3*rot),oy-6*sin(1.3*rot)+37*cos(1.3*rot),
   ox-0*cos(1.3*rot)-35*sin(1.3*rot),oy-0*sin(1.3*rot)+35*cos(1.3*rot),
   ox-4*cos(1.35*rot)-39*sin(1.35*rot),oy-4*sin(1.35*rot)+39*cos(1.35*rot),
   ox-0*cos(1.35*rot)-50*sin(1.35*rot),oy-0*sin(1.35*rot)+50*cos(1.35*rot),14)
 q(ox+6*cos(1.3*rot)-37*sin(1.3*rot),oy+6*sin(1.3*rot)+37*cos(1.3*rot),
   ox+0*cos(1.3*rot)-35*sin(1.3*rot),oy+0*sin(1.3*rot)+35*cos(1.3*rot),
   ox+4*cos(1.35*rot)-39*sin(1.35*rot),oy+4*sin(1.35*rot)+39*cos(1.35*rot),
   ox+0*cos(1.35*rot)-50*sin(1.35*rot),oy+0*sin(1.35*rot)+50*cos(1.35*rot),14)
end


function drawbg()
 for i=1,22 do
  circles[i]=circles[i]+1
  circ(120,50,circles[22-i],circlec[22-i])
 end
 if circles[22] > 440 then
  rem(circles,22)
  ins(circles,1,0)
  col=circlec[22]
  rem(circlec,22)
  ins(circlec,1,col)
 end
 for i=1,23 do
  circ(i*10,-50+(200-8*((t+6*sin(i*40))%20)),i%4+i//6,i%3+9)
  circ(i*5,-50+(200-8*((t+16*sin(i*40))%20)),4*sin(i*50),i%3+9)
 end 
end

function TIC()
 t=time()//60
 local bncx1=10*sin(t/10)
 local bncx2=2*sin(t/10)
 local bncx3=bncx1+bncx2
 local bncx4=-4*sin(t/10)
 local bncx5=bncx1-4*sin(t/10)
 local bncy1=abs(4*sin(t/20))
 local bncy2=5*cos(t/5)
 local rot1=clmp(pi*(abs(sin(t/20*pi))*0.8-0.2),0,pi/2)
 local rot2=clmp(-pi*(abs(sin((t+10)/20*pi)*0.8)-0.2),-pi/2,0)
 local rot3=pi*(0.25*sin(t/10))
 vbank(0)
 cls(3)
 drawbg()
 vbank(1)
 cls(0)
 tail(120,98,bncx3,bncy1,rot3)
 head(120,35,bncx1,bncy1,1,0)
 upperbody(bncx1,bncy1,bncx2,0)
 lowerbody(bncx3,bncy1,bncx4,0)
 arms(bncx1,bncy1,bncx5,bncy2)
 drawarm(90,70,bncx5,bncy2,rot1,1)
 drawarm(150,70,bncx5,bncy2,rot2,-1)
end
