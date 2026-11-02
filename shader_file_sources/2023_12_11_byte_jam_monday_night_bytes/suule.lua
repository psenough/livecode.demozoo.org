-- Greetings to Alia, Gigabates, 
-- Pellicus, Aldroid 
--& people in the chat

sin=math.sin
cos=math.cos
abs=math.abs
ran=math.random

pal1={
0,0,0,
177,62,83,
255,205,117,
239,125,87,
220,198,178,
185,157,133,
128,97,71,
70,54,41,
41,54,111,
59,93,201,
65,166,246,
115,239,247,
244,244,244,
148,176,194,
85,108,134,
51,60,87}

pal2={
0,0,0,
177,62,83,
255,205,117,
239,125,87,
220,198,178,
185,157,133,
128,97,71,
70,54,41,
41,54,111,
59,93,201,
65,166,246,
115,239,247,
244,244,244,
148,176,194,
85,108,134,
51,60,87}

snowcover={}
snowcovermax={}
homes={}

function writepal(pal)
 for i=1,48 do
  poke(0x3fbf+i,pal[i])
 end 
end

function BOOT()
 for i=0,240 do 
  snowcover[i]=136
  snowcovermax[i]=20+abs(110*sin(i/240*math.pi))-ran(4) 
 end
 for i=0,30 do
  homes[i*2]=ran(240)
  homes[i*2+1]=ran(20)  
 end
 vbank(0)
 writepal(pal1)
 vbank(1)
-- writepal(pal2) 
 vbank(0) 
end

--Time for snow
function createsnow()
 vbank(1)
 for i=1,2 do
  circ(ran(244)-2,1,1,10+ran(2))
  pix(ran(244)-2,0,10+ran(2))
 end
 vbank(0)
end

function movesnow()
-- I'm stupid, forgot about vbanks...
 vbank(1)
 for i=0,136 do
  a=136-i
  for j=0,240 do
   pcol=pix(j,a)
   if (pcol==11 or pcol==12) and a < snowcover[j] then
    if a+1==snowcover[j] then
     if snowcover[j]>snowcovermax[j] then
      snowcover[j]=snowcover[j]-1
     end 
    else
     pix(j,a,0)pix(j,a+1,pcol)
    end 
   end
  end
 end
 vbank(0) 
end

-- TIME FOR FUN PART!S!
-- YOU KNOW WHAT QUADS MEAN!

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c) 
 tri(x2,y2,x3,y3,x4,y4,c)
end

function mane(ax,ay,bx,by)
-- Horn 1
 q(157+ax,0,165+ax,0,149+ax,8+by,155+ax,10+by,13)
 q(165+ax,0,170+ax,0,155+ax,10+by,160+ax,11+by,14) 
 q(149+ax,8+by,155+ax,10+by,142+ax,24+ay,148+ax,22+ay,13)
 q(155+ax,10+by,160+ax,11+by,148+ax,22+ay,155+ax,20+ay,14) 
-- Mane
 q(133+ax,25+ay,138+ax,15+ay,134+ax,33+ay,139+ax,28+ay,7)
 q(134+ax,33+ay,139+ax,28+ay,135+ax,40+ay,145+ax,36+ay,7)
 q(143+ax,18+ay,152+ax,17+ay,139+ax,28+ay,165+ax,19+ay,7)
 q(139+ax,28+ay,165+ax,19+ay,145+ax,36+ay,168+ax,24+ay,7)
 q(145+ax,36+ay,168+ax,24+ay,147+ax,41+ay,168+ax,30+ay,7)
 q(164+ax+bx,6+ay+by,166+ax,11+ay,152+ax,17+ay,165+ax,19+ay,7)
 q(166+ax,11+ay,180+ax+bx,2+ay+by,165+ax,19+ay,176+ax,14+ay,7)
 q(165+ax,19+ay,176+ax,14+ay,168+ax,24+ay,178+ax,19+ay,7)
 q(168+ax,24+ay,178+ax,19+ay,168+ax,30+ay,187+ax,28+ay,7)
 q(168+ax,30+ay,187+ax,28+ay,178+ax,38+ay,196+ax,40+ay,7)
 q(178+ax,38+ay,196+ax,40+ay,181+ax,47+ay,201+ax,53+ay,7)
 q(181+ax,47+ay,201+ax,53+ay,183+ax,59+ay,188+ax,63+ay,7) 
 q(177+ax,51+ay,181+ax,47+ay,177+ax,56+ay,183+ax,59+ay,7)  
 q(176+ax,14+ay,198+ax,13+ay,178+ax,19+ay,193+ax,17+ay,7)
 q(178+ax,19+ay,193+ax,17+ay,187+ax,28+ay,199+ax,30+ay,7) 
 q(187+ax,28+ay,199+ax,30+ay,196+ax,40+ay,206+ax,42+ay,7)  
 q(196+ax,40+ay,206+ax,42+ay,201+ax,53+ay,220+ax,62+ay,7)   
 q(201+ax,53+ay,220+ax,62+ay,188+ax,63+ay,229+ax,78+ay,7)    
 q(198+ax,13+ay,210+ax+bx,17+ay+by,193+ax,17+ay,214+ax+bx,20+ay+by,7)     
 q(193+ax,17+ay,213+ax+bx,25+ay+by,199+ax,30+ay,223+ax+bx,32+ay+by,7)
 q(199+ax,30+ay,230+ax+bx,39+ay+by,206+ax,42+ay,217+ax+bx,42+ay+by,7) 
 q(206+ax,42+ay,224+ax+bx,48+ay+by,220+ax,62+ay,239+ax+bx,56+ay+by,7)  
 q(188+ax,63+ay,229+ax,78+ay,181+ax,78+ay,233+ax,91+ay,7)    
 q(181+ax,78+ay,233+ax,91+ay,173+ax,85+ay,240,101+ay,7)     
 q(173+ax,85+ay,240,101+ay,160+ax,92+ay,240,116+ay,7)     
 q(160+ax,92+ay,240,116+ay,147+ax,104+ay,240,126+ay,7)      
 q(147+ax,104+ay,240,126+ay,145+ax,119+ay,240,136,7)       
 q(142+ax,127+ay,145+ax,119+ay,144+ax,136,240,136,7)        
 q(132+ax,106+ay,147+ax,104+ay,131+ax,116+ay,145+ax,119+ay,7)
 q(131+ax,116+ay,145+ax,119+ay,126+ax,126+ay,142+ax,127+ay,7) 
 q(126+ax,126+ay,142+ax,127+ay,129+ax,136,144+ax,136,7)
 q(126+ax,126+ay,142+ax,127+ay,129+ax,136,144+ax,136,7) 
 q(125+ax+bx,110+ay+by,132+ax,106+ay,120+ax+bx,115+ay+ay,131+ax,116+ay,7)
 q(119+ax+bx,120+ay+by,131+ax,116+ay,111+ax+bx,129+ay+ay,126+ax,126+ay,7) 
 q(114+ax+bx,131+ay+by,126+ax,126+ay,110+ax+bx,136,129+ax,136,7)  
-- Horn 2
 q(197+ax,0,208+ax,0,189+ax,5+ay,195+ax,8+ay,13)
 q(208+ax,0,215+ax,0,195+ax,8+ay,197+ax,14+ay,14) 
 q(189+ax,5+ay,195+ax,8+ay,182+ax,14+ay,189+ax,14+ay,13)
 q(195+ax,8+ay,197+ax,14+ay,189+ax,14+ay,194+ax,19+ay,14) 
 q(182+ax,14+ay,189+ax,14+ay,176+ax,23+ay,180+ax,27+ay,13)
 q(189+ax,14+ay,194+ax,19+ay,180+ax,27+ay,186+ax,30+ay,14) 
end

function earr(ax,ay,bx,by)
 q(129+ax+bx,30+ay+by,139+ax,32+ay,128+ax+bx,34+ax+by,137+ax,41+ay,6)
end

function earl(ax,ay,bx,by)
 q(184+ax,41+ay,195+ax+bx/2,37+ay+by/2,185+ax,45+ay,198+ax+bx/2,41+ay+by/2,5)
 q(185+ax,45+ay,198+ax+bx/2,41+ay+by/2,191+ax,50+ay,203+ax+bx/2,46+ay+by/2,6) 
 q(195+ax+bx/2,37+ay+by/2,212+ax+bx,34+ay+by,198+ax+bx/2,41+ay+by/2,212+ax+bx,35+ay+by,5)
 q(198+ax+bx/2,41+ay+by/2,212+ax+bx,35+ay+by,203+ax+bx/2,46+ay+by/2,213+ax+bx,38+ay+by,6) 
end

function face(ax,ay)
 --dark skin
 q(123+ax,97+ay,126+ax,97+ay,132+ax,106+ay,132+ax,101+ay,6)
 q(132+ax,101+ay,146+ax,99+ay,132+ax,106+ay,147+ax,104+ay,6) 
 q(146+ax,99+ay,159+ax,89+ay,147+ax,104+ay,160+ax,92+ay,6)  
 q(159+ax,89+ay,171+ax,81+ay,160+ax,92+ay,173+ax,85+ay,6)   
 q(171+ax,81+ay,175+ax,74+ay,173+ax,85+ay,181+ax,78+ay,6)
 q(175+ax,74+ay,183+ax,59+ay,181+ax,78+ay,188+ax,63+ay,6) 
 -- light skin
 q(135+ax,40+ay,145+ax,36+ay,133+ax,47+ay,147+ax,41+ay,5)
 q(168+ax,30+ay,178+ax,38+ay,147+ax,41+ay,181+ax,47+ay,5)
 q(147+ax,41+ay,181+ax,47+ay,133+ax,47+ay,177+ax,51+ay,5)
 q(133+ax,47+ay,177+ax,51+ay,134+ax,49+ay,177+ax,56+ay,5) 
 q(134+ax,49+ay,177+ax,56+ay,131+ax,56+ay,183+ax,59+ay,5) 
 q(131+ax,56+ay,183+ax,59+ay,126+ax,63+ay,175+ax,74+ay,5)  
 q(126+ax,63+ay,175+ax,74+ay,155+ax,78+ay,171+ax,81+ay,5) 
 q(120+ax,67+ay,126+ax,63+ay,149+ax,83+ay,157+ax,78+ay,5)
 q(149+ax,83+ay,157+ax,78+ay,159+ax,89+ay,171+ax,81+ay,5)
 q(120+ax,67+ay,149+ax,83+ay,126+ax,97+ay,159+ax,89+ay,5)
 q(116+ax,71+ay,120+ax,67+ay,123+ax,97+ay,126+ax,97+ay,5)
 q(126+ax,97+ay,159+ax,89+ay,132+ax,101+ay,146+ax,99+ay,5)
 q(114+ax,77+ay,116+ax,71+ay,114+ax,86+ay,123+ax,97+ay,5)
 --eyes
 q(155+ax,54+ay,175+ax,51+ay,159+ax,60+ay,165+ax,60+ay,6)
 q(152+ax,55+ay,155+ax,54+ay,149+ax,60+ay,155+ax,57+ay,6)
 q(155+ax,45+ay,158+ax,45+ay,152+ax,55+ay,155+ax,54+ay,6)
 q(158+ax,45+ay,170+ax,48+ay,155+ax,54+ay,175+ax,51+ay,6)
 q(158+ax,45+ay,170+ax,44+ay,170+ax,48+ay,175+ay,47+ay,6)
 q(156+ax,54+ay,172+ax,51+ay,159+ax,57+ay,170+ax,55+ay,2)
 q(159+ax,57+ay,170+ax,55+ay,161+ax,59+ay,163+ax,59+ay,2)
 tri(162+ax,52+ay,165+ax,52+ay,164+ax,59+ay,0)
 line(156+ax,54+ay,172+ax,51+ay,7)
 line(156+ax,54+ay,157+ax,49+ay,7)
 line(169+ax,47+ay,157+ax,49+ay,7)
 line(169+ax,47+ay,172+ax,51+ay,7) 
 
 q(133+ax,44+ay,142+ax,46+ay,133+ax,47+ay,142+ax,47+ay,6)
 q(133+ax,47+ay,142+ax,47+ay,134+ax,49+ay,142+ax,48+ay,6)
 q(134+ax,49+ay,142+ax,48+ay,131+ax,56+ay,139+ax,53+ay,6) 
 q(131+ax,56+ay,139+ax,53+ay,126+ax,63+ay,138+ax,57+ay,6)
 q(133+ax,52+ay,139+ax,52+ay,133+ax,56+ay,138+ax,58+ay,2)
 tri(136+ax,52+ay,138+ax,52+ay,136+ax,57+ay,0) 
 line(133+ax,52+ay,139+ax,52+ay,7)
 line(134+ax,48+ay,133+ax,52+ay,7)
 line(134+ax,48+ay,140+ax,50+ay,7)

-- Highlights
 q(154+ax,61+ay,165+ax,61+ay,167+ax,68+ay,174+ax,55+ay,4)
 q(120+ax,93+ay,114+ax,86+ay,117+ax,84+ay,114+ax,77+ay,4)
 q(116+ax,71+ay,118+ax,79+ay,114+ax,77+ay,117+ax,84+ay,4)
 q(116+ax,71+ay,120+ax,67+ay,118+ax,79+ay,123+ax,73+ay,4)
 q(118+ax,79+ay,123+ax,73+ay,120+ax,82+ay,123+ax,80+ay,4) 
 q(120+ax,82+ay,123+ax,80+ay,125+ax,92+ay,127+ax,92+ay,4)
 q(120+ax,67+ay,126+ax,63+ay,123+ax,73+ay,127+ax,67+ay,4) 
 q(123+ax,73+ay,127+ax,67+ay,123+ax,80+ay,133+ax,73+ay,4)  
 q(126+ax,63+ay,135+ax,59+ay,127+ax,67+ay,136+ax,60+ay,4)   
 q(135+ax,59+ay,139+ax,53+ay,136+ax,60+ay,144+ax,59+ay,4)
 q(141+ax,48+ay,143+ax,52+ay,139+ax,53+ay,144+ax,59+ay,4)   
 q(141+ax,48+ay,143+ax,52+ay,141+ax,45+ay,144+ax,48+ay,4)
 q(145+ax,41+ay,147+ax,42+ay,141+ax,45+ay,144+ax,48+ay,4)
 q(149+ax,41+ay,155+ax,43+ay,150+ax,45+ay,155+ax,45+ay,4)
-- Brow
 q(154+ax,41+ay,169+ax,36+ay,157+ax,46+ay,174+ax,39+ay,7)
 q(135+ax,38+ay,139+ax,39+ay,134+ax,42+ay,136+ax,45+ay,7)
 q(139+ax,39+ay,143+ax,42+ay,136+ax,45+ay,141+ax,45+ay,7)

-- That smile
 q(151+ax,82+ay,160+ax,72+ay,159+ax,84+ay,153+ax,88+ay,6)
 q(151+ax,82+ay,160+ax,72+ay,159+ax,84+ay,153+ax,88+ay,6)
 q(145+ax,86+ay,151+ax,82+ay,146+ax,93+ay,159+ax,84+ay,6)
 q(134+ax,91+ay,145+ax,86+ay,138+ax,96+ay,146+ax,93+ay,6) 
 q(120+ax,91+ay,134+ax,91+ay,123+ax,96+ay,138+ax,96+ay,6)  
 q(119+ax,92+ay,134+ax,92+ay,123+ax,96+ay,138+ax,96+ay,12)
 q(134+ax,92+ay,145+ax,87+ay,138+ax,96+ay,146+ax,92+ay,12) 
 q(145+ax,87+ay,151+ax,83+ay,146+ax,92+ay,153+ax,86+ay,12)  
 q(151+ax,83+ay,158+ax,76+ay,153+ax,86+ay,157+ax,84+ay,12)   
 q(119+ax,92+ay,134+ax,92+ay,123+ax,94+ay,138+ax,94+ay,13)
 q(134+ax,92+ay,145+ax,87+ay,138+ax,94+ay,146+ax,89+ay,13) 
 q(145+ax,87+ay,151+ax,83+ay,146+ax,89+ay,153+ax,83+ay,13)  
 q(151+ax,83+ay,158+ax,76+ay,153+ax,83+ay,156+ax,79+ay,13)   
 line(158+ax,69+ay,161+ax,67+ay,6)
 line(163+ax,70+ay,161+ax,67+ay,6) 
-- Can someone do a spline() please?)
 line(115+ax,75+ay,117+ax,77+ay,6)
 line(117+ax,77+ay,121+ax,80+ay,7)
 line(121+ax,80+ay,128+ax,77+ay,7)
 line(128+ax,77+ay,130+ax,75+ay,6) 
 line(121+ax,80+ay,122+ax,84+ay,7) 
 line(122+ax,84+ay,123+ax,88+ay,7)  
 line(123+ax,88+ay,124+ax,90+ay,7)   
end

function armb(ax,ay)
 circ(126+ax,114+ay,22,6)
 circ(123+ax,118+ay,22,6) 
 circ(124+ax,118+ay,22,5)  
end 

function armf(ax,ay)
 circ(224+ax,112+ay,22,4)
 circ(229+ax,112+ay,22,6)
 circ(227+ax,113+ay,22,5)
 circ(228+ax,115+ay,22,5) 
 circ(229+ax,117+ay,22,5)  
 circ(230+ax,119+ay,22,5)   
 circ(231+ax,121+ay,22,5) 
 circ(217+ax,102+ay,9,4)      
 circ(219+ax,105+ay,10,5)       
end

function background()
 for i=0,30 do
  rect(-12+homes[2*i],100+homes[2*i+1],38,50,0)
  rect(-14+homes[2*i],90+homes[2*i+1],42,15,10) 
  rect(-14+homes[2*i],90+homes[2*i+1],42,12,11)  
  --rect(2+homes[2*i],95+homes[2*i+1],6,8,0)
  rect(-6+homes[2*i],108+homes[2*i+1],6,8,2)
--  rect(16+homes[2*i],118+homes[2*i+1],6,8,2) 
  rect(16+homes[2*i],108+homes[2*i+1],6,8,2)  
 end
end

function TIC()
 t=time()//60
 cls(8)
 vbank(0)
 background()
 print("Good boys and girls",5,9,0) 
 print("Good boys and girls",4,8,2)
 print("shouldn't use GOTO in",5,17,0) 
 print("shouldn't use GOTO in",4,16,2) 
 print("their code, or else",5,25,0) 
 print("their code, or else",4,24,2) 
 print("the Krampus will pay",5,33,0) 
 print("the Krampus will pay",4,32,2) 
 print("them a visit!",5,41,0) 
 print("them a visit!",4,40,2)  
 armb(0,15-abs(2*sin(t/20)))
 earr(0,-abs(2*sin(t/20)),sin(t/5),sin(t/5))
 mane(0,-abs(2*sin(t/20)),3*cos(t/20),3*cos(t/20))
 armf(0,15-abs(2*sin(t/20)))
 earl(0,-abs(2*sin(t/20)),sin(t/5),sin(t/5))
 face(0,-abs(2*sin(t/20)))
 if t%2==0 then createsnow() end
 movesnow()
end

