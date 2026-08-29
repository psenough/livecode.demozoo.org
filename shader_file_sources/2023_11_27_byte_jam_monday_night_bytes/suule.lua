--Hello there!
--Today it's time for sheep!
--But the cool kind ;)
--Greetz to Tobach, Alia and Mantra :D
sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs

local fft1={}

function quad(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x2,y2,x3,y3,x4,y4,col)
end

function clamp(x,r1,r2)
 if x > r2 then return r2 end
 if x < r1 then return r1 else return x end
end

function suit(bx,by,ax1,ay1,ax2,ay2)
-- arms
 circ(93+bx,101+by,10,3)
 circ(147+bx,101+by,10,3) 
 circ(68+bx+ax1,125+by+ay1,9,3)
 circ(172+bx+ax2,125+by+ay2,9,3) 
 quad(82+bx,98+by,102+bx,98+by,64+bx+ax1,116+by+ay1,76+bx+ax1,127+by+ay1,3)
 quad(138+bx,98+by,158+bx,98+by,164+bx+ax2,127+by+ay2,176+bx+ax2,116+by+ay2,3)
-- chest  
 quad(110+bx,75+by,129+bx,75+by,108+bx,86+by,131+bx,86+by,3)
 quad(110+bx,75+by,129+bx,75+by,108+bx,84+by,131+bx,84+by,2)
 quad(108+bx,86+by,132+bx,86+by,102+bx,136,138+bx,136,3)
 quad(85+bx,93+by,108+bx,86+by,96+bx,136,102+bx,136,3)
 quad(89+bx,108+by,97+bx,120+by,95+bx,136,99+bx,136,2)
 quad(155+bx,93+by,132+bx,86+by,144+bx,136,138+bx,136,3)
 quad(151+bx,108+by,143+bx,120+by,145+bx,136,141+bx,136,2)  

-- sheen
 quad(110+bx,86+by,84+bx,93+by,115+bx,112+by,100+bx,110+by,4)
 quad(130+bx,86+by,156+bx,92+by,125+bx,112+by,140+bx,110+by,4)
 quad(110+bx,86+by,130+bx,86+by,115+bx,112+by,125+bx,112+by,4) 
 quad(125+bx,88+by,151+bx,92+by,128+bx,99+by,144+bx,95+by,12)    
 quad(114+bx,88+by,89+bx,92+by,112+bx,99+by,96+bx,95+by,12)    
 
 quad(85+bx,93+by,90+bx,98+by,66+bx+ax1,116+by+ay1,72+bx+ax1,120+by+ay1,4)
 quad(85+bx,93+by,87+bx,99+by,69+bx+ax1,114+by+ay1,69+bx+ax1,118+by+ay1,12) 
 quad(155+bx,93+by,150+bx,98+by,174+bx+ax2,116+by+ay2,168+bx+ax2,120+by+ay2,4)
 quad(155+bx,93+by,153+bx,99+by,171+bx+ax2,114+by+ay2,171+bx+ax2,118+by+ay2,12) 
--
 quad(118+bx,75+by,120+bx,75+by,117+bx,86+by,121+bx,86+by,13)
 quad(117+bx,86+by,121+bx,86+by,117+bx,136,121+bx,136,13) 
 quad(119+bx,75+by,119+bx,75+by,118+bx,86+by,120+bx,86+by,14)
 quad(118+bx,86+by,120+bx,86+by,120+bx,136,119+bx,136,14)
end

function ear1(bx,by,ay)
 quad(79+bx,57+by+ay,83+bx,56+by//2+ay,79+bx,60+by+ay,83+bx,61+by+ay//2,15)
 quad(83+bx,56+by+ay//2,94+bx,54+by+ay//4,83+bx,61+by+ay//2,94+bx,61+by+ay//4,15) 
 quad(94+bx,54+by+ay//4,98+bx,53+by,94+bx,61+by+ay//4,98+bx,57+by,15)  
end

function ear2(bx,by,ay)
 quad(159+bx,57+by+ay,155+bx,56+by+ay//2,159+bx,60+by+ay,155+bx,61+by+ay//2,15)
 quad(155+bx,56+by+ay//2,144+bx,54+by+ay//4,155+bx,61+by+ay//2,144+bx,61+by+ay//4,15) 
 quad(144+bx,54+by+ay//4,140+bx,53+by,144+bx,61+by+ay//4,140+bx,57+by,15)  
end

function woolbg(bx,by)
 circ(119+bx,39+by,6,14)
 circ(129+bx,41+by,5,14) 
 circ(109+bx,41+by,5,14)  
 circ(137+bx,45+by,4,14) 
 circ(101+bx,45+by,4,14)  
 circ(137+bx,53+by,6,14) 
 circ(101+bx,53+by,6,14)  
 circ(139+bx,58+by,5,14) 
 circ(99+bx,58+by,5,14)  
 circ(136+bx,65+by,7,14) 
 circ(102+bx,65+by,7,14)  
 circ(134+bx,71+by,7,14) 
 circ(104+bx,71+by,7,14)  
 circ(131+bx,78+by,6,14) 
 circ(107+bx,78+by,6,14)  
end 

function sheephead(bx,by)
 elli(119+bx,49+by,15,7,15)
 rect(103+bx,50+by,33,20,15)
 rect(111+bx,70+by,17,11,15) 
 elli(133+bx,63+by,4,6,15)
 elli(105+bx,63+by,4,6,15)
 elli(119+bx,80+by,6,2,15)
 tri(103+bx,69+by,111+bx,69+by,111+bx,80+by,15)
 tri(136+bx,69+by,128+bx,69+by,128+bx,80+by,15)
 rect(111+bx,69+by,18,11,15)  
 line(107+bx,69+by,112+bx,72+by,13) 
 line(131+bx,69+by,126+bx,72+by,13)
 line(112+bx,72+by,119+bx,69+by,12)  
 line(126+bx,72+by,119+bx,69+by,12)
 line(119+bx,63+by,119+bx,69+by,14)
 line(116+bx,63+by,122+bx,63+by,14) 
 line(113+bx,61+by,116+bx,63+by,14)  
 line(125+bx,61+by,122+bx,63+by,14) 
end

function woolfg(bx,by)
 circ(119+bx,36+by,6,13)
 circ(112+bx,37+by,4,13)
 circ(126+bx,37+by,4,13)
 circ(105+bx,42+by,4,13)
 circ(133+bx,42+by,4,13)
 circ(100+bx,44+by,4,13)
 circ(138+bx,44+by,4,13)
 circ(98+bx,51+by,3,13)
 circ(140+bx,51+by,3,13)
 circ(98+bx,54+by,4,13)
 circ(140+bx,54+by,4,13)
 circ(96+bx,57+by,3,13)
 circ(142+bx,57+by,3,13)
end   


function glasses(bx,by)
 line(114+bx,54+by,123+bx,54+by,13)
 line(114+bx,54+by,106+bx,57+by,13) 
 line(103+bx,59+by,106+bx,57+by,13) 
 line(123+bx,54+by,132+bx,57+by,13) 
 line(135+bx,59+by,132+bx,57+by,13) 
 line(113+bx,44+by,124+bx,44+by,12)
 line(113+bx,44+by,107+bx,47+by,12) 
 line(102+bx,51+by,107+bx,47+by,13) 
 line(124+bx,44+by,130+bx,47+by,12) 
 line(135+bx,51+by,130+bx,47+by,13) 
end

function drawglass(bx,by)
 for i=0,7 do
  pix(bx+i+119,by+52-clamp(30*fft(3*i),0,7),i)
  pix(bx-i+119,by+52-clamp(30*fft(3*i),0,7),i)  
 end
 for i=8,10 do
  pix(bx+i+119,by+53-clamp(30*fft(3*i),0,7),i)
  pix(bx-i+119,by+53-clamp(30*fft(3*i),0,7),i)  
 end
 for i=11,12 do
  pix(bx+i+119,by+54-clamp(30*fft(3*i),0,7),i)
  pix(bx-i+119,by+54-clamp(30*fft(3*i),0,7),i)  
 end
 for i=13,14 do
  pix(bx+i+119,by+55-clamp(30*fft(3*i),0,7),i)
  pix(bx-i+119,by+55-clamp(30*fft(3*i),0,7),i)  
 end
 for i=15,16 do
  pix(bx+i+119,by+56-clamp(30*fft(3*i),0,7),i)
  pix(bx-i+119,by+56-clamp(30*fft(3*i),0,7),i)  
 end
end

function arm1(bx,by,ax,ay)
 quad(60+bx,124+by,102+ax,115+ay,65+bx,135+by,102+ax,123+ay,3) 
 quad(63+bx,118+by,60+bx,124+by,87+ax,110+ay,102+ax,115+ay,4)
 quad(67+bx,118+by,62+bx,122+by,87+ax,110+ay,102+ax,112+ay,12)
 elli(93+ax,118+ay,11,9,4)
 elli(94+ax,117+ay,9,7,2)
 elli(94+ax,114+ay,6,2,15)
 elli(96+ax,113+ay,3,2,15) 
 elli(102+ax,113+ay,6,4,15) 
 elli(89+ax,117+ay,3,3,15)
 elli(90+ax,122+ay,3,5,15)
 elli(96+ax,119+ay,3,4,15)  
 elli(97+ax,123+ay,3,6,15)
 elli(102+ax,119+ay,3,4,15)  
 elli(103+ax,123+ay,3,6,15)
 elli(109+ax,118+ay,3,4,15)  
 elli(110+ax,123+ay,3,6,15)
 line(106+ax,119+ay,104+ax,116+ay,0) 
 line(107+ax,123+ay,106+ax,119+ay,0)
 line(107+ax,123+ay,107+ax,125+ay,0)
 line(99+ax,121+ay,97+ax,117+ay,0)
 line(99+ax,121+ay,99+ax,125+ay,0)
 line(92+ax,118+ay,94+ax,125+ay,0)   
end


function arm2(bx,by,ax,ay)
 quad(180+bx,124+by,138+ax,115+ay,175+bx,135+by,138+ax,123+ay,3) 
 quad(177+bx,118+by,180+bx,124+by,153+ax,110+ay,138+ax,115+ay,4)
 quad(173+bx,118+by,178+bx,122+by,153+ax,110+ay,138+ax,112+ay,12)
 elli(147+ax,118+ay,11,9,4)
 elli(146+ax,117+ay,9,7,2)
 elli(146+ax,114+ay,6,2,15)
 elli(144+ax,113+ay,3,2,15) 
 elli(138+ax,113+ay,6,4,15) 
 elli(151+ax,117+ay,3,3,15)
 elli(150+ax,122+ay,3,5,15)
 elli(144+ax,119+ay,3,4,15)  
 elli(143+ax,123+ay,3,6,15)
 elli(138+ax,119+ay,3,4,15)  
 elli(137+ax,123+ay,3,6,15)
 elli(131+ax,118+ay,3,4,15)  
 elli(130+ax,123+ay,3,6,15)
 line(134+ax,119+ay,136+ax,116+ay,0) 
 line(133+ax,123+ay,134+ax,119+ay,0)
 line(133+ax,123+ay,133+ax,125+ay,0)
 line(141+ax,121+ay,143+ax,117+ay,0)
 line(141+ax,121+ay,141+ax,125+ay,0)
 line(148+ax,118+ay,146+ax,125+ay,0)   
end


function circfft(x,y,r,tim,cshft)
 for i=0,360 do
  pix(x+(90*fft(i%90)+r)*sin((i+tim)/180*pi),y+(90*fft(i%90)+r)*cos((i+tim)/180*pi),cshft+i%4) 
 end 
end

function drawland(scale,w)
 for i=1,239 do
  line(120-(2*i*scale)-(i-1),100+scale*20-fft1[w][i]-((i-1)*(i-1)/50),120-(2*(i+1)*scale)-i,100+scale*20-fft1[w][i+1]-(i*i/50),5-1/scale)
  line(120+(2*i*scale)+(i-1),100+scale*20-fft1[w][i]-((i-1)*(i-1)/50),120+(2*(i+1)*scale)+i,100+scale*20-fft1[w][i+1]-(i*i/50),5-1/scale) 
 end
end

function computer()
 rect(24,130,206,8,14)
 rect(44,121,160,9,15)
 line(56,120,64,120,12)
 line(68,120,76,120,12) 
 print('TORG-8000',45,123,12,0,1,1) 
end

function gatherfft(w)
 for i=1,240 do
  fft1[w][i]=90*fft(i)
 end
end

function musicfield(tim)
 if tim%64==0 then  
  table.remove(fft1, 8)
  table.insert(fft1, 1, {})
  gatherfft(1)
 end
  
 for i=0,7 do
  drawland(2/(1+(tim+(7-i)*8)%64/10),i+1)
  
 end
end

function BOOT()
 for i=1,8 do
  fft1[i]={}
  gatherfft(i)  
 end
end


function TIC()
 t=time()//60
 sw1=2*sin(t/8)
 sw2=2*sin(t/4)
 sw3=7*sin(t/3.25/10)
 sw4=4*abs(sin(t/3.25))
 sw5=6*cos((t+6.5)/20)
 sw6=4*abs(sin((t+3)/3.25)) 
 vbank(0)
 cls(0)
 musicfield(t)
 circfft(119,50,20,t+30,5) 
 circfft(119,50,40,t,8)
 vbank(1)
 cls(0)
 woolbg(sw1,sw2)
 suit(sw1,sw2,sw3,sw4,0,0)
 ear1(sw1,sw2,2*sin(t/4))
 ear2(sw1,sw2,2*cos(t/4)) 
 sheephead(sw1,sw2)
 glasses(sw1,sw2)
 drawglass(sw1,sw2)
 woolfg(sw1,sw2)
 arm1(sw1,sw2,sw3-10,sw4-5)
 arm2(sw1,sw2,sw5+10,sw6-5)
 computer()
end


