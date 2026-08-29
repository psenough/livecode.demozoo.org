-- Greetz to all people at Inercia!
-- Hi to aldroid, gasman, jtruk, mantratronic
-- nusan, superogue and tobach!
-- Let's do something wicked today

sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs
ins=table.insert
rem=table.remove
l=line

-- Some functions I tend to use a lot...

function clmp(par,r1,r2)
 if par < p1 then return p1 end
 if par > p2 then return p2 else return par end
end

-- Quads rule and so should you

function q(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x2,y2,x3,y3,x4,y4,col) 
end

-- Hey have you seen this hack? I can't
-- use the sprite editor, but let's get
-- some sprites going, shall we? :)

sprite1={
8,0,
8,0,
8,0,
8,0,
8,0,
7,0,1,12,
6,0,2,12,
4,0,1,13,2,12,1,13}
sprite2={
8,0,
8,0,
5,0,3,12,
1,0,7,12,
8,12,
8,12,
1,13,7,12,
8,12}
sprite3={
8,0,
1,0,5,12,2,0,
7,12,1,0,
8,12,
8,12,
7,12,1,13,
6,12,2,13,
6,12,1,13,1,0}
sprite16={
4,0,1,13,1,12,1,13,1,12,
3,0,1,13,1,12,2,13,1,12,
2,0,1,13,1,14,1,13,3,12,
1,0,1,13,1,14,2,13,2,12,1,13,
1,13,2,14,1,13,3,12,1,13,
2,14,1,13,3,12,1,13,1,0,
2,14,1,13,2,12,3,0,
1,0,2,13,1,12,1,13,3,0}
sprite17={
3,12,5,13,
2,12,3,13,3,0,
2,13,5,0,1,13,
5,0,2,13,1,12,
5,0,1,13,2,12,
4,0,1,13,3,12,
4,0,1,13,1,12,2,13,
4,0,3,13,1,0}
sprite18={
6,12,1,13,1,0,
1,13,4,12,1,13,2,0,
3,12,2,13,3,0,
3,12,1,13,4,0,
2,12,1,13,5,0,
2,13,6,0,
8,0,
8,0
}

-- Well well well, now what if we just
-- put those arrays into memory?

function readsprite(sprarr,id)
 local con=0
 for i=0,#sprarr//2-1 do
  local rep=sprarr[i*2+1]
  local col=sprarr[i*2+2]
  for j=1,rep do
   poke4(0x8000+con+id*64,col)
   con=con+1
  end
 end
end

function BOOT()
 readsprite(sprite1,0)
 readsprite(sprite2,1)
 readsprite(sprite3,2) 
 readsprite(sprite16,16)  
 readsprite(sprite17,17)   
 readsprite(sprite18,18)    
end

-- Excuse the 10k of pre-calculated code
-- I just wanted something cool to show
-- off for the good folks at Inercia!

function goathead(ax,ay)
 -- Horns
 q(176+ax,14+ay,177+ax,16+ay,163+ax,24+ay,167+ax,26+ay,4)
 q(177+ax,16+ay,178+ax,17+ay,167+ax,26+ay,169+ax,27+ay,3)
 q(176+ax,14+ay,189+ax, 9+ay,177+ax,16+ay,188+ax,10+ay,4)
 q(177+ax,16+ay,188+ax,10+ay,178+ax,17+ay,186+ax,12+ay,3)
 q(165+ax,12+ay,167+ax,13+ay,160+ax,19+ay,162+ax,21+ay,4)
 q(167+ax,13+ay,169+ax,14+ay,162+ax,21+ay,164+ax,23+ay,3)
 q(176+ax, 4+ay,176+ax, 4+ay,165+ax,12+ay,167+ax,13+ay,4)
 q(167+ax,13+ay,176+ax, 4+ay,169+ax,14+ay,176+ax, 4+ay,3)
 -- Deep shadow
 q(159+ax,49+ay,166+ax,47+ay,155+ax,53+ay,159+ax,51+ay,14)
 q(163+ax,46+ay,169+ax,45+ay,159+ax,49+ay,166+ax,47+ay,14)
 q(169+ax,45+ay,173+ax,43+ay,163+ax,46+ay,172+ax,46+ay,14)
 -- Shadow
 q(141+ax,50+ay,147+ax,53+ay,147+ax,55+ay,152+ax,55+ay,13)
 q(147+ax,53+ay,152+ax,52+ay,152+ax,55+ay,155+ax,53+ay,13)
 q(152+ax,52+ay,157+ax,47+ay,155+ax,53+ay,159+ax,49+ay,13)
 q(157+ax,47+ay,162+ax,43+ay,159+ax,49+ay,163+ax,46+ay,13)
 q(162+ax,43+ay,169+ax,42+ay,163+ax,46+ay,169+ax,45+ay,13)
 q(169+ax,42+ay,174+ax,34+ay,169+ax,45+ay,173+ax,43+ay,13)
 q(149+ax,28+ay,151+ax,27+ay,150+ax,30+ay,156+ax,27+ay,13)
 -- Head proper
 q(139+ax,44+ay,152+ax,52+ay,141+ax,50+ay,147+ax,53+ay,12)
 q(139+ax,44+ay,143+ax,39+ay,152+ax,52+ay,157+ax,47+ay,12)
 q(143+ax,39+ay,159+ax,40+ay,157+ax,47+ay,162+ax,43+ay,12)
 q(148+ax,33+ay,153+ax,34+ay,143+ax,39+ay,159+ax,40+ay,12)
 q(150+ax,30+ay,153+ax,31+ay,148+ax,33+ay,153+ax,34+ay,12)
 q(150+ax,30+ay,156+ax,27+ay,153+ax,31+ay,157+ax,29+ay,12)
 q(159+ax,40+ay,162+ax,40+ay,162+ax,43+ay,169+ax,42+ay,12)
 q(164+ax,38+ay,174+ax,34+ay,162+ax,40+ay,169+ax,42+ay,12)
 q(164+ax,33+ay,172+ax,27+ay,164+ax,38+ay,174+ax,34+ay,12)
 q(161+ax,30+ay,167+ax,24+ay,164+ax,33+ay,172+ax,27+ay,12)
 q(164+ax,21+ay,167+ax,24+ay,157+ax,29+ay,161+ax,30+ay,12)
 q(156+ax,27+ay,164+ax,21+ay,157+ax,29+ay,167+ax,24+ay,12)
 q(158+ax,21+ay,164+ax,21+ay,156+ax,27+ay,157+ax,29+ay,12)
 q(151+ax,21+ay,158+ax,21+ay,151+ax,27+ay,156+ax,27+ay,12)
 q(147+ax,23+ay,151+ax,21+ay,149+ax,28+ay,151+ax,27+ay,12)
 q(147+ax,23+ay,151+ax,21+ay,149+ax,28+ay,151+ax,27+ay,12)
 q(157+ax,17+ay,161+ax,18+ay,158+ax,21+ay,164+ax,21+ay,12)
 -- End of hair 
 q(144+ax,27+ay,147+ax,23+ay,142+ax,31+ay,149+ax,28+ay,12)
 q(149+ax,17+ay,157+ax,17+ay,155+ax,19+ay,158+ax,21+ay,12)
 -- Eye
 q(153+ax,34+ay,164+ax,38+ay,159+ax,40+ay,162+ax,40+ay,15)
 q(153+ax,31+ay,164+ax,33+ay,153+ax,34+ay,164+ax,38+ay,15)
 q(157+ax,29+ay,161+ax,30+ay,153+ax,31+ay,164+ax,33+ay,15)
 l(156+ax,34+ay,159+ax,34+ay,12)
 l(159+ax,34+ay,160+ax,35+ay,12) 
 -- Nose
 l(139+ax,44+ay,142+ax,47+ay,14)
 l(142+ax,45+ay,142+ax,47+ay,15)
 l(142+ax,45+ay,145+ax,42+ay,14)
 l(145+ax,42+ay,147+ax,42+ay,14)
 l(142+ax,47+ay,144+ax,50+ay,14)
 l(144+ax,50+ay,147+ax,50+ay,14)
 l(147+ax,50+ay,151+ax,46+ay,14)
 l(151+ax,45+ay,151+ax,46+ay,14) 
end 

function headphones(ax,ay)
 q(176+ax,28+ay,179+ax,28+ay,175+ax,30+ay,180+ax,30+ay,15)
 q(178+ax,28+ay,179+ax,28+ay,177+ax,30+ay,180+ax,30+ay,14)
 q(177+ax,30+ay,180+ax,30+ay,175+ax,31+ay,175+ax,35+ay,14)
 circ(170+ax,36+ay,5,15)
 circ(172+ax,35+ay,5,14)
 circb(173+ax,35+ay,3,15)
end

function floppyears(ax,ay,bx,by)
 q(164+ax,29+ay,173+ax,29+ay,165+ax,33+ay,174+ax,33+ay,12)
 q(165+ax,33+ay,174+ax,33+ay,167+ax,37+ay,174+ax,37+ay,12)
 q(167+ax,37+ay,174+ax,37+ay,167+ax+bx/2,48+ay,176+ax+bx/2,44+ay,12)
 q(174+ax,33+ay,175+ax,33+ay,174+ax,37+ay,176+ax,37+ay,13)
 q(174+ax,37+ay,176+ax,37+ay,176+ax+bx/2,44+ay,179+ax+bx/2,48+ay,13)
 q(167+ax+bx/2,48+ay,176+ax+bx/2,44+ay,171+ax+bx,55+ay+by,176+ax+bx,56+ay+by,14)
 q(176+ax+bx/2,44+ay,179+ax+bx/2,48+ay,176+ax+bx,56+ay+by,179+ax+bx,53+ay+by,14)
 l(167+ax,37+ay,167+ax+bx/2,48+ay,13)
 l(165+ax,33+ay,167+ax,37+ay,13)
end

function necc(ax,ay,bx,by)
 q(159+ax,51+ay,166+ax,47+ay,160+ax,53+ay,165+ax,52+ay,14)
 q(160+ax,53+ay,165+ax,52+ay,157+bx,57+by,163+bx,56+by,13)
 q(166+ax,47+ay,172+ax,46+ay,165+ax,52+ay,172+ax,51+ay,12)
 q(165+ax,52+ay,172+ax,51+ay,163+bx,56+by,174+bx,55+by,12)
 q(158+ax,53+ay,159+ax,51+ay,157+bx,57+by,160+ax,53+ay,12)
end

function r_hand(ax,ay,bx,by)
 q(147+ax,62+ay,152+ax,63+ay,143+bx,85+by,148+bx,92+by,12)
 q(152+ax,63+ay,156+ax,66+ay,148+bx,92+by,151+bx,95+by,13)
 q(129+bx,102+by,143+bx,85+by,133+bx,105+by,148+bx,92+by,12)
 q(133+bx,105+by,148+bx,92+by,133+bx,107+by,151+bx,95+by,13)
 spr(0,110+bx,101+by,0,1,0,0,3,2)
end

function l_hand(ax,ay,bx,by)
-- Fur
 q(166+bx,23+by,168+bx,23+by,169+bx,35+by,174+bx,32+by,12)
 q(169+bx,35+by,174+bx,32+by,169+bx,39+by,175+bx,38+by,12)
 q(169+bx,39+by,175+bx,38+by,169+bx,41+by,174+bx,43+by,12)
 q(169+bx,41+by,174+bx,43+by,159+bx,61+by,172+bx,61+by,12)
 q(159+bx,61+by,172+bx,61+by,161+bx,64+by,168+bx,64+by,12) 
 q(174+bx,32+by,174+bx,29+by,175+bx,38+by,180+bx,38+by,12)
 q(175+bx,38+by,180+bx,38+by,174+bx,43+by,175+bx,43+by,12) 
 q(174+bx,58+by,185+bx,64+by,168+bx,64+by,183+bx,70+by,12)
 q(161+bx,64+by,168+bx,64+by,173+bx,72+by,183+bx,70+by,12) 
-- Shade
 q(174+bx,43+by,175+bx,43+by,172+bx,61+by,174+bx,58+by,13)  
 q(173+bx,72+by,183+bx,70+by,178+ax,76+by,182+ax,75+by,13)
 q(183+bx,70+by,188+bx,69+by,180+bx,75+by,186+bx,73+by,13) 
 q(185+bx,64+by,188+bx,65+by,183+bx,70+by,188+bx,69+by,13) 
 q(185+bx,61+by,187+bx,63+by,185+bx,64+by,188+bx,65+by,13)  
 q(182+ax,59+ay,185+bx,61+by,182+ax,62+ay,185+bx,64+by,13)   
-- Accent 
 l(161+bx,64+by,173+bx,72+by,13)
 l(173+bx,58+by,168+bx,63+by,13)
 l(173+bx,58+by,185+bx,64+by,13)
 l(175+bx,32+by,170+bx,23+by,13) 
 l(174+bx,32+by,169+bx,23+by,12)
 l(168+bx,23+by,172+bx,32+by,13) 
 l(166+bx,25+by,168+bx,35+by,13) 
 l(169+bx,35+by,169+bx,40+by,13) 
 l(169+bx,41+by,171+bx,42+by,13)   
 l(169+bx,41+by,159+bx,61+by,13) 
 l(159+bx,61+by,161+bx,64+by,13)    
end

function body(ax,ay)
-- Fur
 q(150+ax,59+ay,157+ax,57+ay,147+ax,62+ay,157+ax,62+ay,12)
 q(157+ax,57+ay,163+ax,56+ay,157+ax,62+ay,164+ax,62+ay,12)
 q(163+ax,56+ay,174+ax,55+ay,164+ax,62+ay,174+ax,62+ay,12)
 q(174+ax,55+ay,178+ax,57+ay,174+ax,62+ay,181+ax,62+ay,12)
--
 q(147+ax,62+ay,157+ax,62+ay,145+ax,69+ay,157+ax,70+ay,12)
 q(157+ax,62+ay,164+ax,62+ay,157+ax,70+ay,165+ax,71+ay,12)
 q(164+ax,62+ay,174+ax,62+ay,165+ax,71+ay,174+ax,67+ay,12)
 q(174+ax,62+ay,181+ax,62+ay,174+ax,67+ay,182+ax,67+ay,12)
--
 q(145+ax,69+ay,157+ax,70+ay,144+ax,77+ay,157+ax,78+ay,12)
 q(157+ax,70+ay,165+ax,71+ay,157+ax,78+ay,165+ax,79+ay,12)
 q(165+ax,71+ay,174+ax,67+ay,165+ax,79+ay,176+ax,76+ay,12)
 q(174+ax,67+ay,182+ax,67+ay,176+ax,76+ay,180+ax,73+ay,12)
--
 q(144+ax,77+ay,157+ax,78+ay,146+ax,89+ay,156+ax,90+ay,12)
 q(157+ax,78+ay,165+ax,79+ay,156+ax,90+ay,165+ax,90+ay,12)
 q(165+ax,79+ay,176+ax,76+ay,165+ax,90+ay,173+ax,93+ay,12)
--
 q(146+ax,89+ay,156+ax,90+ay,149+ax,97+ay,157+ax,99+ay,12)
 q(156+ax,90+ay,165+ax,90+ay,157+ax,99+ay,165+ax,100+ay,12)
 q(165+ax,90+ay,173+ax,93+ay,165+ax,100+ay,175+ax,99+ay,12)
--
 q(149+ax,97+ay,157+ax,99+ay,149+ax,109+ay,157+ax,110+ay,12)
 q(157+ax,99+ay,165+ax,100+ay,157+ax,110+ay,165+ax,111+ay,12)
 q(165+ax,100+ay,175+ax,99+ay,165+ax,111+ay,174+ax,108+ay,12)
-- 
 q(149+ax,109+ay,157+ax,110+ay,148+ax,114+ay,155+ax,119+ay,12)
 q(157+ax,110+ay,165+ax,111+ay,155+ax,119+ay,162+ax,120+ay,12)
 q(165+ax,111+ay,174+ax,108+ay,162+ax,120+ay,175+ax,115+ay,12)
-- 
 q(155+ax,119+ay,162+ax,120+ay,157+ax,125+ay,164+ax,126+ay,12)
-- Shade
 q(178+ax,57+ay,182+ax,59+ay,181+ax,62+ay,183+ax,62+ay,13)
 q(181+ax,62+ay,183+ax,62+ay,182+ax,67+ay,183+ax,67+ay,13)
 q(182+ax,67+ay,183+ax,67+ay,180+ax,73+ay,183+ax,73+ay,13)
 q(180+ax,73+ay,183+ax,73+ay,176+ax,76+ay,181+ax,82+ay,13)
 q(176+ax,76+ay,181+ax,82+ay,173+ax,93+ay,177+ax,91+ay,13)
 q(173+ax,93+ay,177+ax,91+ay,175+ax,99+ay,178+ax,99+ay,13)
 q(175+ax,99+ay,178+ax,99+ay,174+ax,108+ay,180+ax,106+ay,13)
 q(174+ax,108+ay,180+ax,106+ay,175+ax,115+ay,183+ax,110+ay,13)
-- Accent
 l(150+ax,59+ay,147+ax,62+ay,13)
 l(147+ax,62+ay,145+ax,69+ay,13)
 l(145+ax,69+ay,144+ax,77+ay,13)
 l(144+ax,77+ay,146+ax,89+ay,13)
 l(146+ax,89+ay,149+ax,97+ay,13)
 l(149+ax,97+ay,149+ax,109+ay,13)
 l(149+ax,109+ay,148+ax,114+ay,13)
-- Tone
 l(152+ax,60+ay,155+ax,61+ay,13)
 l(159+ax,61+ay,170+ax,57+ay,13)
 l(156+ax,63+ay,153+ax,70+ay,13)
 l(153+ax,70+ay,152+ax,75+ay,13)
 l(153+ax,77+ay,156+ax,80+ay,13)
 l(156+ax,80+ay,163+ax,80+ay,13)
 l(163+ax,80+ay,169+ax,77+ay,13)
 l(169+ax,77+ay,172+ax,74+ay,13)
 l(149+ax,79+ay,151+ax,77+ay,13)
 l(149+ax,79+ay,151+ax,77+ay,13)
 l(145+ax,79+ay,149+ax,79+ay,13)
 l(146+ax,89+ay,151+ax,86+ay,13)
 l(155+ax,86+ay,164+ax,90+ay,13)
 l(153+ax,91+ay,156+ax,104+ay,13)
 l(156+ax,104+ay,157+ax,114+ay,13)
end

function shirt(ax,ay,bx,by)
 q(153+ax,57+ay,157+ax,56+ay,149+ax,62+ay,155+ax,62+ay,2)
 q(170+ax,55+ay,174+ax,55+ay,161+ax,62+ay,169+ax,63+ay,2) 

 q(149+ax,62+ay,155+ax,62+ay,144+ax,71+ay,155+ax,71+ay,2) 
 q(155+ax,62+ay,161+ax,62+ay,155+ax,71+ay,161+ax,71+ay,2)  
 q(161+ax,62+ay,169+ax,63+ay,161+ax,71+ay,167+ax,71+ay,2)
 
 q(144+ax,71+ay,155+ax,71+ay,143+ax,79+ay,155+ax,79+ay,2) 
 q(155+ax,71+ay,161+ax,71+ay,155+ax,79+ay,161+ax,79+ay,2)  
 q(161+ax,71+ay,167+ax,71+ay,161+ax,79+ay,171+ax,79+ay,2)

 q(143+ax,79+ay,155+ax,79+ay,145+ax,92+ay,155+ax,92+ay,2) 
 q(155+ax,79+ay,161+ax,79+ay,155+ax,92+ay,161+ax,92+ay,2)  
 q(161+ax,79+ay,171+ax,79+ay,161+ax,92+ay,172+ax,92+ay,2)

 q(145+ax,92+ay,155+ax,92+ay,145+ax,101+ay,155+ax,101+ay,2) 
 q(155+ax,92+ay,161+ax,92+ay,155+ax,101+ay,161+ax,101+ay,2)  
 q(161+ax,92+ay,172+ax,92+ay,161+ax,101+ay,171+ax,101+ay,2)

 q(145+ax,101+ay,155+ax,101+ay,142+ax,110+ay,155+ax,114+ay,2) 
 q(155+ax,101+ay,161+ax,101+ay,155+ax,114+ay,161+ax,114+ay,2)  
 q(161+ax,101+ay,171+ax,101+ay,161+ax,114+ay,168+ax,112+ay,2)

 q(182+ax,73+ay,183+ax,71+ay,178+ax,79+ay,183+ax,79+ay,1)
 q(171+ax,79+ay,178+ax,79+ay,172+ax,92+ay,178+ax,92+ay,1)
 q(178+ax,79+ay,183+ax,79+ay,178+ax,92+ay,180+ax,92+ay,1) 

 q(172+ax,92+ay,178+ax,92+ay,171+ax,101+ay,177+ax,101+ay,1)
 q(178+ax,92+ay,180+ax,92+ay,177+ax,101+ay,179+ax,101+ay,1) 
 
 q(171+ax,101+ay,177+ax,101+ay,168+ax,112+ay,177+ax,109+ay,1)
 q(177+ax,101+ay,179+ax,101+ay,177+ax,109+ay,184+ax,104+ay,1) 
end 

function pants(ax,ay)
 q(149+ax,105+ay,155+ax,106+ay,143+ax,119+ay,155+ax,123+ay,10)
 q(155+ax,106+ay,161+ax,106+ay,155+ax,123+ay,161+ax,124+ay,10) 
 q(161+ax,106+ay,173+ax,103+ay,161+ax,124+ay,177+ax,114+ay,10)  

 q(143+ax,119+ay,155+ax,123+ay,143+ax,128+ay,155+ax,128+ay,10)
 q(155+ax,123+ay,161+ax,124+ay,155+ax,128+ay,161+ax,128+ay,9) 
 q(161+ax,124+ay,177+ax,114+ay,161+ax,128+ay,178+ax,128+ay,10)  

 q(143+ax,128+ay,155+ax,128+ay,142+ax,136,156+ax,136,10)
 q(155+ax,128+ay,161+ax,128+ay,156+ax,136,161+ax,136,9) 
 q(161+ax,128+ay,178+ax,128+ay,161+ax,136,178+ax,136,10)  
 
 q(173+ax,103+ay,179+ax,102+ay,177+ax,114+ay,185+ax,113+ay,9)
 q(177+ax,114+ay,185+ax,113+ay,178+ax,128+ay,187+ax,129+ay,9) 
 q(178+ax,128+ay,187+ax,129+ay,178+ax,136,187+ax,136,9)  
 l(155+ax,123+ay,148+ax,118+ay,9)
 l(164+ax,118+ay,174+ax,114+ay,9) 
end

function piano()
 q(83,100,115,100,89,136,135,136,14)
 q(82,109,83,100,82,136,89,136,15) 
 q(99,105,117,105,110,136,135,136,12) 
 l(99,105,116,105,15)
 l(100,107,118,107,13)
 l(100,107,110,107,15)
 l(100,109,119,109,13)
 l(100,109,111,109,15)
 l(101,111,120,111,13)
 l(101,111,112,111,15)
 l(102,113,121,113,13)
 l(102,115,123,115,13)
 l(102,115,114,115,15)
 l(103,117,124,117,13)
 l(103,117,115,117,15)
 l(104,119,125,119,13) 
 l(105,121,126,121,13)
 l(105,121,117,121,15)
 l(105,123,127,123,13)
 l(105,123,118,123,15)
 l(106,125,128,125,13)
 l(106,125,119,125,15)
 l(107,127,129,127,13)
 l(108,129,131,129,13)
 l(108,129,121,129,15)
 l(108,131,132,131,13)
 l(108,131,122,131,15)
 l(109,133,133,133,13) 
 l(110,135,134,135,13)  
 l(110,135,124,135,15)   
end

function effect1()
 for i=0,240 do
  pix(i,68+64*sin(t+i),i)
  pix(i,68+64*cos(t+i),i)
 end
 circ(t%260-20,30+40*sin(t/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t+60)%260-20,50+40*sin((t+30)/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t+145)%260-20,60+40*sin((t-20)/40),abs(5*sin(t/3)),3+(t/20)%3)
 circ((t-20)%260-20,80+40*sin((t+40)/40),abs(5*sin(t/3)),9+(t/20)%3) 
 circ((t+20)%260-20,50+40*sin(t/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t+90)%260-20,30+40*sin((t+30)/40),abs(5*sin(t/3)),9+(t/20)%3)
 circ((t+125)%260-20,65+40*sin((t-20)/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t-50)%260-20,80+40*sin((t+40)/40),abs(5*sin(t/3)),6+(t/20)%3)   
 circ((t+70)%260-20,70+40*sin(t/40),abs(5*sin(t/3)),8+(t/20)%3)
 circ((t+110)%260-20,40+40*sin((t+30)/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t+145)%260-20,60+40*sin((t-20)/40),abs(5*sin(t/3)),6+(t/20)%3)
 circ((t-40)%260-20,20+40*sin((t+40)/40),abs(5*sin(t/3)),3+(t/20)%3)   
 circ(t%260-20,30+40*cos(t/40),abs(5*cos(t/3)),1+(t/20)%3)
 circ((t+60)%260-20,50+40*cos((t+30)/40),abs(5*cos(t/3)),1+(t/20)%3)
 circ((t+145)%260-20,60+40*cos((t-20)/40),abs(5*cos(t/3)),3+(t/20)%3)
 circ((t-20)%260-20,80+40*cos((t+40)/40),abs(5*cos(t/3)),9+(t/20)%3) 
 circ((t+20)%260-20,50+40*cos(t/40),abs(5*sin(t/3)),1+(t/20)%3)
 circ((t+90)%260-20,30+40*cos((t+30)/40),abs(5*cos(t/3)),9+(t/20)%3)
 circ((t+125)%260-20,65+40*cos((t-20)/40),abs(5*cos(t/3)),1+(t/20)%3)
 circ((t-50)%260-20,80+40*cos((t+40)/40),abs(5*cos(t/3)),6+(t/20)%3)   
 circ((t+70)%260-20,70+40*cos(t/40),abs(5*cos(t/3)),8+(t/20)%3)
 circ((t+110)%260-20,40+40*cos((t+30)/40),abs(5*cos(t/3)),1+(t/20)%3)
 circ((t+145)%260-20,60+40*cos((t-20)/40),abs(5*cos(t/3)),6+(t/20)%3)
 circ((t-40)%260-20,20+40*cos((t+40)/40),abs(5*cos(t/3)),3+(t/20)%3)   
   
end


function TIC()
 t=time()//60
 vbank(0)
 cls(0)
 effect1()
 vbank(1)
 cls(0)
 piano()
 r_hand(0,0,6*sin(t/10),6*sin(t/10)+abs(2*sin(t/2)))
 necc(2*sin(t/50),0,0,0)
 body(0,0,0,0)
 pants(0,0)
 shirt(0,0) 
 goathead(2*sin(t/50),0)
 headphones(2*sin(t/50),0)
 floppyears(2*sin(t/50),0,4*sin(t/50),0)
 l_hand(0,0,2*sin(t/50),0)
end
