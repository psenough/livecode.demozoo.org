-- I hope you'll all have a great time today
sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi
ran=math.random
flr=math.floor
cel=math.ceil

local beakrot=0

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c)
 tri(x2,y2,x3,y3,x4,y4,c)
end

function clmp(val,min,max)
 if val<min then return min end
 if val>max then return max else return val end
end

function rotp(ox,oy,dx,dy,rot)
 local sx=ox-dx 
 local sy=oy-dy
 local rx=sx*cos(rot/360*pi)-sy*sin(rot/360*pi)
 local ry=sx*sin(rot/360*pi)+sy*cos(rot/360*pi)
 return ox-rx,oy-ry
end

-- Today it's gonna be a massive animation! 
-- I hope I can finish it all today!

function drw_necc(xs,ys)
 q(195+xs,48+ys, 209+xs,55+ys, 198+xs,77+ys, 216+xs,66+ys, 1)
 q(198+xs,77+ys, 216+xs,66+ys, 192+xs,89+ys/2, 214+xs,87+ys, 2)
 q(192+xs,89+ys/2, 214+xs,87+ys, 180+xs,106+ys/2,209+xs,109+ys/2,2) 
 q(180+xs,106+ys/2,209+xs,109+ys/2,172+xs/2,136,216+xs/2,136,2)
 q(175+xs,121+ys/2,211+xs,121+ys/2,146+xs/2,136,236+xs/2,136,2) 
end

function drw_col(xs,ys)
 q(176+xs,111+ys, 184+xs,115+ys, 174+xs,122+ys, 183+xs,127+ys, 15)
 q(184+xs,115+ys, 194+xs,116+ys, 183+xs,127+ys, 196+xs,128+ys, 15) 
 q(194+xs,116+ys, 211+xs,112+ys, 196+xs,128+ys, 215+xs,123+ys, 15) 
 q(176+xs,113+ys, 184+xs,117+ys, 174+xs,120+ys, 183+xs,125+ys, 12)
 q(184+xs,117+ys, 194+xs,118+ys, 183+xs,125+ys, 196+xs,126+ys, 12) 
 q(194+xs,118+ys, 211+xs,114+ys, 196+xs,126+ys, 215+xs,121+ys, 12)  
 line(175+xs,116+ys,183+xs,121+ys,15)
 line(183+xs,121+ys,195+xs,122+ys,15) 
 line(195+xs,122+ys,213+xs,117+ys,15) 
 line(180+xs,114+ys,177+xs,122+ys,15)  
 line(184+xs,116+ys,182+xs,124+ys,15)   
 line(188+xs,116+ys,187+xs,125+ys,15)    
 line(194+xs,117+ys,193+xs,126+ys,15)     
 line(199+xs,117+ys,200+xs,126+ys,15)      
 line(205+xs,114+ys,207+xs,124+ys,15)       
 line(210+xs,114+ys,213+xs,122+ys,15)        
end

function drw_hair(xs, ys, bnc)
 q(177+xs,18+ys, 187+xs-ys/4,20+ys/2, 171+xs,35+ys, 186+xs,28+ys, 2)
 q(191+xs+ys/4,4-ys/4,  203+xs+ys/4,14-ys/4, 177+xs,18+ys, 187+xs-ys/4,20+ys/2, 2)
 q(213+xs+ys/2,0-ys/2,  219+xs+ys,10-ys/2, 191+xs+ys/4,4-ys/4,  203+xs+ys/4,14-ys/4, 2)
 q(230+xs+ys,4-2*ys,  239+xs+ys,9-2*ys,  213+xs+ys/2,0-ys/2,  219+xs+ys,10-ys/2, 2)

 q(198+xs+ys/4,17+ys-ys/2, 203+xs+ys/4,25+ys-ys/2, 186+xs,27+ys, 201+xs,31+ys, 2)
 q(198+xs+ys/4,17+ys-ys/2, 203+xs+ys/4,25+ys-ys/2, 213+xs+ys/4,15+ys-ys, 213+xs,23+ys-1.5*ys, 2) 
 q(213+xs+ys/4,15+ys-ys, 213+xs,23+ys-1.5*ys, 226+xs+ys,18+ys-1.5*ys, 221+xs+ys,26+ys-1.5*ys, 2)  
 q(226+xs+ys,18+ys-1.5*ys, 232+xs+ys,22+ys-2*ys, 221+xs+ys,26+ys-1.5*ys, 238+xs+1.5*ys,31+ys-2*ys, 2)

 q(200+xs,31+ys, 209+xs+ys/4,29+ys-ys/2, 204+xs,36+ys, 210+xs+ys/4,36+ys-ys/2, 2) 
 q(209+xs+ys/4,29+ys-ys/2, 226+xs+ys,36+ys-ys, 210+xs+ys/4,36+ys-ys/2, 223+xs+ys*1.5,42+ys-ys, 2)  
 q(226+xs+ys,36+ys-ys, 233+xs+ys*1.25,40+ys-ys*1.5, 223+xs+ys*1.5,42+ys-ys, 235+xs+ys*2,50+ys-ys*1.5, 2)  

 q(226+xs+ys,36+ys-ys, 233+xs+ys*1.25,40+ys-ys*1.5, 223+xs+ys*1.5,42+ys-ys, 235+xs+ys*2,50+ys-ys*1.5, 2)   
end

function drw_head(xs,ys)
 q(173+xs,32+ys, 189+xs,25+ys, 166+xs,40+ys, 200+xs,30+ys, 2)
 q(166+xs,40+ys, 200+xs,30+ys, 165+xs,55+ys, 212+xs,45+ys, 2)
 q(165+xs,55+ys, 212+xs,45+ys, 173+xs,69+ys, 209+xs,56+ys, 2)
 q(173+xs,69+ys, 209+xs,56+ys, 185+xs,74+ys, 208+xs,63+ys, 2)
end

function drw_eyes(xs,ys)
 q(179+xs,38+ys, 182+xs,37+ys, 178+xs,51+ys, 188+xs,52+ys, 12)
 q(182+xs,37+ys, 186+xs,39+ys, 188+xs,52+ys, 192+xs,48+ys, 12)
 q(166+xs,40+ys, 169+xs,39+ys, 165+xs,52+ys, 169+xs,51+ys, 12)
 circ(187+xs,47+ys,2,0)
 circ(168+xs,47+ys,2,0) 
 q(179+xs,38+ys, 182+xs,37+ys, 178+xs,50+ys, 185+xs,49+ys, 9)
 q(182+xs,37+ys, 186+xs,39+ys, 185+xs,48+ys, 191+xs,46+ys, 8)
 q(166+xs,40+ys, 169+xs,39+ys, 165+xs,48+ys, 169+xs,48+ys, 9) 
 q(166+xs,40+ys, 167+xs,39+ys, 165+xs,48+ys, 166+xs,48+ys, 8)
 q(181+xs,38+ys, 182+xs,37+ys, 183+xs,48+ys, 188+xs,47+ys, 10)
 q(169+xs,38+ys, 172+xs,38+ys, 169+xs,59+ys, 172+xs,59+ys, 2)   
end

function drw_mic(xs,ys)
-- Hand
 q(140+xs,100+ys, 152+xs,107+ys, 131+xs,107+ys, 149+xs,119+ys, 2)
 q(131+xs,107+ys, 149+xs,119+ys, 118+xs,118+ys, 141+xs,133+ys, 2) 
 q(118+xs,118+ys, 141+xs,133+ys, 125+xs+ys/4,136,  135+xs,136, 2)  
 q(136+xs,104+ys, 144+xs,105+ys, 132+xs,109+ys, 147+xs,115+ys, 1)
 q(132+xs,109+ys, 147+xs,115+ys, 122+xs,119+ys, 140+xs,122+ys, 1)
 q(122+xs,119+ys, 140+xs,122+ys, 127+xs,128+ys, 133+xs,128+ys, 1)  
-- Finger 1
 q(134+xs,104+ys, 143+xs,102+ys, 134+xs,92+ys,  142+xs,96+ys,  1) 
 q(134+xs,92+ys,  142+xs,96+ys,  136+xs,85+ys,  145+xs,79+ys,  2)  
-- Mic 
 circ(153+xs,98+ys,9,14)
 circ(148+xs,104+ys,6,15) 
 q(143+xs,101+ys, 154+xs,107+ys, 127+xs,121+ys, 132+xs,126+ys,15)
 circ(129+xs,123+ys,3,14) 
-- Thumb
 q(143+xs,112+ys, 149+xs,106+ys, 145+xs,116+ys, 153+xs,119+ys, 2)
 q(145+xs,116+ys, 153+xs,119+ys, 134+xs,126+ys, 141+xs,133+ys, 2) 
-- Finger 2
 q(121+xs,110+ys, 136+xs,98+ys,  145+xs,108+ys, 131+xs,106+ys, 1)
 q(121+xs,110+ys, 136+xs,98+ys,  141+xs,102+ys, 131+xs,106+ys, 2) 
 q(136+xs,98+ys,  145+xs,108+ys, 131+xs,106+ys, 140+xs,112+ys, 2) 
-- Finger 3
 q(121+xs,110+ys, 131+xs,107+ys, 118+xs,118+ys, 128+xs,116+ys, 2)
 q(131+xs,107+ys, 139+xs,114+ys, 128+xs,116+ys, 133+xs,119+ys, 2) 
end

function drw_beak(xs,ys,rot)
-- Beak Lower
 -- Origin point 186,65
 local sx1,sy1=rotp(186+xs,65+ys,163+xs,77+ys,rot)  
 local sx2,sy2=rotp(186+xs,65+ys,177+xs,62+ys,rot)  
 local sx3,sy3=rotp(186+xs,65+ys,164+xs,83+ys,rot)    
 q(sx1,sy1, sx2,sy2, sx3,sy3, 186+xs,65+ys, 13)  
 sx1,sy1=rotp(186+xs,65+ys,180+xs,81+ys,rot)  
 sx2,sy2=rotp(186+xs,65+ys,186+xs,73+ys,rot)  
 q(sx3,sy3, 186+xs,65+ys, sx1,sy1, sx2,sy2, 13)
 -- Origin point 183,66 
 sx1,sy1=rotp(183+xs,66+ys,165+xs,77+ys,rot)  
 sx2,sy2=rotp(183+xs,66+ys,177+xs,64+ys,rot)  
 sx3,sy3=rotp(183+xs,66+ys,165+xs,81+ys,rot)   
 q(sx1,sy1, sx2,sy2, sx3,sy3, 183+xs,66+ys, 14) 
 sx1,sy1=rotp(183+xs,66+ys,175+xs,79+ys,rot)  
 sx2,sy2=rotp(183+xs,66+ys,181+xs,71+ys,rot)  
 q(sx3,sy3, 183+xs,66+ys, sx1,sy1, sx2,sy2, 14)  
-- Beak Upper Start
 q(157+xs,62+ys, 163+xs,63+ys, 148+xs,72+ys, 155+xs,72+ys, 13)
 q(163+xs,63+ys, 169+xs,66+ys, 155+xs,72+ys, 161+xs,75+ys, 13)
 q(169+xs,66+ys, 178+xs,74+ys, 161+xs,75+ys, 165+xs,82+ys, 13)
 q(167+xs,52+ys, 173+xs,52+ys, 157+xs,62+ys, 163+xs,63+ys, 13)
 q(173+xs,52+ys, 180+xs,56+ys, 163+xs,63+ys, 169+xs,66+ys, 13)
 q(180+xs,56+ys, 184+xs,64+ys, 169+xs,66+ys, 178+xs,74+ys, 13)
-- Beak Upper End
 q(144+xs,81+ys, 154+xs,91+ys, 144+xs,95+ys, 146+xs,103+ys,15)
 q(148+xs,72+ys, 155+xs,72+ys, 144+xs,81+ys, 161+xs,75+ys, 15)
 q(144+xs,81+ys, 161+xs,75+ys, 154+xs,91+ys, 165+xs,82+ys, 15) 
end

function drw_stg()
 q(20,100,100,100,50,0,70,0,14)
 elli(60,100,40,2,13)
end

function drw_rab(xs,ys)
 -- legs
 q(65,96,  71,100,  62,100,  71,101, 15)
 q(59+xs/2,90+ys/4, 63+xs/2,88+ys/4,  62,100,  65,96,  15)
 q(57+xs,81+ys/2, 61+xs,78+ys/2, 59+xs/2,90+ys/4, 63+xs/2,88+ys/4,  15) 
 q(45,98,  49,98,  45,101,  52,101, 15)
 q(50+xs/2,88+ys/4,53+xs/2,90+ys/4, 45,98,  49,98, 15)
 q(51+xs,77+ys/2, 55+xs,81+ys/2, 50+xs/2,88+ys/4,53+xs/2,90+ys/4, 15)
 -- body
 q(51+xs,77+ys/2, 61+xs,78+ys/2, 55+xs,81+ys/2, 57+xs,81+ys/2, 15)
 q(53+xs,65+ys/2, 63+xs,68+ys/2, 51+xs,77+ys/2, 61+xs,78+ys/2, 15)
 q(52+xs,59+ys/2, 61+xs,61+ys/2, 53+xs,65+ys/2, 63+xs,68+ys/2, 15)
 q(56+xs,57+ys/2, 59+xs,58+ys/2, 52+xs,59+ys/2, 61+xs,61+ys/2, 15)
 --head
 q(57+xs,45+ys/2, 61+xs,56+ys/2,  56+xs,57+ys/2, 59+xs,58+ys/2, 15)
 q(57+xs,45+ys/2, 63+xs,49+ys/2,  61+xs,56+ys/2, 64+xs,56+ys/2, 15)
 q(61+xs,56+ys/2, 64+xs,56+ys/2,  62+xs,61+ys/2, 64+xs,61+ys/2, 15)
 q(52+xs,51+ys/2, 57+xs,45+ys/2,  53+xs,57+ys/2, 61+xs,56+ys/2, 15) 
 q(51+xs,55+ys/2, 52+xs,51+ys/2,  50+xs,58+ys/2, 53+xs,57+ys/2, 15)  
 --ears
 q(57+xs,36+ys/2, 60+xs,33+ys/2,  57+xs,45+ys/2, 59+xs,47+ys/2, 15)
 q(63+xs,35+ys/2, 64+xs,40+ys/2,  60+xs,47+ys/2, 62+xs,49+ys/2, 15)
 --outline
 line(65,96, 63+xs/2,88+ys/4, 13)
 line(61+xs,78+ys/2, 63+xs/2,88+ys/4,13)
 line(63+xs,68+ys/2, 61+xs,78+ys/2, 13)
 line(45,98,50+xs/2,88+ys/4,13)
 line(50+xs/2,88+ys/4,51+xs,77+ys/2,13)
 line(51+xs,77+ys/2,53+xs,65+ys/2,13)
 line(63+xs,35+ys/2, 60+xs,47+ys/2,13)
 line(57+xs,36+ys/2, 60+xs,33+ys/2,13)
 line(57+xs,36+ys/2, 57+xs,45+ys/2,13)
 line(57+xs,45+ys/2, 52+xs,51+ys/2,13)
 line(52+xs,51+ys/2, 50+xs,58+ys/2,13)
 line(63+xs,49+ys/2, 64+xs,56+ys/2,13)
end

function drw_gut(xs,ys,fftx)
 -- neck
 q(73+xs,62+ys/2, 76+xs,58+ys/2, 74+xs,64+ys/2, 78+xs,62+ys/2, 15)
 q(50+xs,70+ys/2, 73+xs,62+ys/2, 59+xs,71+ys/2, 74+xs,64+ys/2, 15)
 line(73+xs,62+ys/2, 76+xs,58+ys/2,  13)
 line(50+xs,70+ys/2, 73+xs,62+ys/2, 13)
  q(48+xs,69+ys/2, 57+xs,65+ys/2, 49+xs,76+ys/2, 59+xs,75+ys/2, 15)  
 -- hand
 q(52+xs,59+ys/2, 54+xs,63+ys/2, 44+xs,69+ys/2, 49+xs,69+ys/2, 15)
 line(52+xs,59+ys/2, 44+xs,69+ys/2, 13)   
 q(44+xs,69+ys/2, 49+xs,69+ys/2, 45+xs,73+ys/2, 49+xs,70+ys/2, 15)   
 q(49+xs,70+ys/2, 55+xs,72+ys/2, 45+xs,73+ys/2, 55+xs,74+ys/2, 15)
 circ(70+xs,65+ys/2,2,15)    
end

function drawfft()
 vbank(0)
 for i=0,240 do
  pix(i,68+60*fft(i),1+i%15)
 end 
end

function calcbeakrot(inp)
 local fftsum = clmp((fft(12)+fft(16)+fft(20)+fft(24)+fft(28)+fft(32))/6*500,0,50)
 trace(fftsum) 
 if inp > 5-fftsum then return inp-1 else return 5-fftsum end
end 
 
function osc(fac,tim,div)
 return fac*sin(tim/div*pi)
end
 
 
function TIC()
 t=time()/60
 vbank(0)
 cls(0)
 drw_stg()
 drawfft()
 vbank(1)
 cls(0)
 beakrot=calcbeakrot(beakrot)
 drw_rab(osc(1,t,15),-abs(osc(4,t,15)))
 drw_gut(osc(1,t,15),-abs(osc(4,t,15)),2)
 drw_necc(osc(4,t,15),-abs(osc(2,t,15)))
 drw_col(osc(4,t,15),-abs(osc(2,t,15)))
 drw_hair(osc(4,t,15),-abs(osc(2,t,15)))
 drw_head(osc(6,t,15),-abs(osc(4,t,15)))
 drw_eyes(osc(6,t,15),-abs(osc(4,t,15)))
 drw_mic(osc(6,t,15),-abs(osc(4,t,15)))
 drw_beak(osc(6,t,15),-abs(osc(4,t,15)),beakrot)
end
