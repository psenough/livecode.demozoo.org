-- pos: 0,0
-- Hey Instanssi. What's your favourite
-- game? Mine is driving in he desert
-- So let's do that!

-- Greetz to Aldroid, Muffintrap and
-- of course Violet! 

sin=math.sin
cos=math.cos
abs=math.abs
rand=math.random
pi=math.pi
flr=math.floor

pal0={}
pal1={26,28,44,
      93,39,93,
      177,62,83,
      244,88,88,
      202,156,118,
      128,89,57,
      60,39,22,
      221,171,86,
      251,210,141,
      59,93,201,
      65,166,246,
      115,239,247,
      244,244,244,
      148,176,194,
      85,108,134,
      51,60,87}

spr0={
4,11,2,1,1, 6,1,13,
1,11,3,1,3,2,1,13,
1,12,1,15,1,12,1,10,2,12,2,13,
1,12,2,15,1, 9,1,12,2,13,1,12,
3,13,2,6,1,13,2,12,
8,11,
8,11,
8,11}
spr16={
8,11,
4,11,4, 5,
2,11,3, 5,2, 4,1,13,
3, 5,3, 4,1,12,1,13,
2, 5,3, 4,3,13,
1, 5,2, 4,4,13,1,12,
2, 4,3,13,3,12,
4,13,4,12}
spr17={
8, 5,
1, 4,3,12,1, 4,3, 5,
1,12,1,13,3,12,2, 5,1,11,
1,13,4,12,1, 5,2,11,
4,12,1, 5,3,11,
3,12,2, 5,3,11,
2,12,1, 5,5,11,
1,12,1, 5,6,11}
spr32={
3,13,3,12,2, 5,
1,11,6, 5,1,11,
8,11,
8,11,
8,11,
8,11,
8,11,
8,11}
spr33={
1, 5,7,11,
8,11,
8,11,
8,11,
8,11,
8,11,
8,11,
8,11}

rn={}

function q(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x2,y2,x3,y3,x4,y4,col) 
end

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

function loadpal(pal)
 for i=1,48 do
  poke(0x3fc0+i-1,pal[i])
 end
end

-- Here comes two days of Precal :D
function car(ax,ay)
--back base
 q(-5+ax,112+ay,245+ax,112+ay,-5+ax,141+ay,245+ax,141+ay,5)
 line(-5+ax,112+ay,245+ax,112+ay,15)
 elli(174+ax,98+ay,8,5,4)
 elli(174+ax,101+ay,8,5,4)
 elli(174+ax,104+ay,8,5,4)
 elli(173+ax,107+ay,8,10,4) 
--
 q(85+ax,47+ay,93+ax,47+ay,
   83+ax,52+ay,88+ax,52+ay,14)
 q(83+ax,52+ay,88+ax,52+ay,
   67+ax,67+ay,70+ax,69+ay,14)
 q(67+ax,67+ay,70+ax,69+ay,
   52+ax,80+ay,54+ax,83+ay,14)
 q(52+ax,80+ay,54+ax,83+ay,
   42+ax,90+ay,46+ax,93+ay,14)
 q(42+ax,90+ay,46+ax,93+ay,
   34+ax,100+ay,39+ax,102+ay,14)
 q(34+ax,100+ay,39+ax,102+ay,
   26+ax,112+ay,34+ax,112+ay,14)

--dashboard
 q(22+ax,106+ay,27+ax,106+ay,
   15+ax,108+ay,26+ax,112+ay,6)
 q(27+ax,106+ay,36+ax,106+ay,
   26+ax,112+ay,34+ax,112+ay,6)
 q(36+ax,106+ay,42+ax,106+ay,
   34+ax,112+ay,39+ax,112+ay,6)
 q(42+ax,106+ay,51+ax,107+ay,
   39+ax,112+ay,43+ax,113+ay,6)
 q(51+ax,107+ay,59+ax,110+ay,
   43+ax,113+ay,61+ax,115+ay,6)
--base
 q(-5+ax,116+ay,245+ax,116+ay,-5+ax,141+ay,245+ax,141+ay,2)
-- reflections
 q( 4+ax,110+ay,8+ax,112+ay,
   -5+ax,111+ay,-5+ax,120+ay,3)
 q( 8+ax,112+ay,25+ax,115+ay,
   -5+ax,120+ay,20+ax,120+ay,3)
 q( 8+ax,112+ay,25+ax,115+ay,
   -5+ax,120+ay,20+ax,120+ay,3)
 q(25+ax,115+ay,45+ax,115+ay,
   20+ax,120+ay,52+ax,120+ay,3)
 q(45+ax,115+ay,61+ax,116+ay,
   52+ax,120+ay,61+ax,117.5+ay,3)
 q(61+ax,116+ay,94+ax,116+ay,
   61+ax,117.5+ay,94+ax,117.5+ay,3)
 q(94+ax,116+ay,185+ax,116+ay,
   94+ax,117.5+ay,187+ax,118.5+ay,3)
 q(187+ax,116+ay,245+ax,116+ay,
   189+ax,118.5+ay,245+ax,118.5+ay,3)
 q(189+ax,125+ay,245.5+ax,125+ay,
   189+ax,127.5+ay,245+ax,127.5+ay,3)
 q(-5+ax,122+ay,18+ax,122+ay,
   -5+ax,127.5+ay,186+ax,127.5+ay,3)
 q(-5+ax,120+ay,20+ax,120+ay,
   -5+ax,122+ay,18+ax,122+ay,3)
 line(-5+ax,127.5+ay,245+ax,127.5+ay,3)
-- windshield 
 q(92+ax,53+ay,95+ax,53+ay,
   92+ax,62+ay,95+ax,63+ay,14)
 q(95+ax,53+ay,100+ax,53+ay,
   95+ax,63+ay,100+ax,64+ay,13)
 q(85+ax,47+ay,89+ax,44+ay,
   91+ax,47+ay,96+ax,43+ay,3)
 q(91+ax,47+ay,96+ax,43+ay,
   92+ax,49+ay,102+ax,43+ay,3)
 q(92+ax,49+ay,102+ax,43+ay,
   94+ax,49+ay,108+ax,43+ay,3)
 q(94+ax,49+ay,108+ax,43+ay,
   96+ax,49+ay,110+ax,45+ay,3)
 q(96+ax,49+ay,110+ax,45+ay,
   96+ax,51+ay,110+ax,49+ay,2)
 q(96+ax,51+ay,110+ax,49+ay,
   94+ax,53+ay,108+ax,51+ay,2)
 q(92+ax,48+ay,94+ax,49+ay,
   68+ax,71+ay,69+ax,74+ay,13)
 q(68+ax,71+ay,69+ax,74+ay,
   54+ax,85+ay,57+ax,87+ay,13)
 q(54+ax,85+ay,57+ax,87+ay,
   45+ax,96+ay,48+ax,98+ay,13)
 q(45+ax,96+ay,48+ax,98+ay,
   39+ax,104+ay,42+ax,106+ay,13)
 q(39+ax,104+ay,42+ax,106+ay,
   34+ax,112+ay,39+ax,112+ay,13)
 q(94+ax,49+ay,96+ax,49+ay,
   94+ax,53+ay,96+ax,51+ay,14)
 q(94+ax,49+ay,94+ax,53+ay,
   69+ax,74+ay,71+ax,76+ay,14)
 q(69+ax,74+ay,71+ax,76+ay,
   57+ax,87+ay,59+ax,89+ay,14)
 q(57+ax,87+ay,59+ax,89+ay,
   48+ax,98+ay,51+ax,100+ay,14)
 q(48+ax,98+ay,51+ax,100+ay,
   42+ax,106+ay,46+ax,108+ay,14)
 q(42+ax,106+ay,46+ax,108+ay,
   39+ax,112+ay,43+ax,113+ay,14)
 line(92+ax,48+ay,68+ax,71+ay,12)
 line(68+ax,71+ay,54+ax,85+ay,12)
 line(54+ax,85+ay,45+ax,96+ay,12)
 line(45+ax,96+ay,39+ax,104+ay,12)
 line(39+ax,104+ay,34+ax,112+ay,12)
 line(92+ax,48+ay,102+ax,43+ay,12)
 line(102+ax,43+ay,108+ax,43+ay,12) 
 line(85+ax,47+ay,12+ax,105+ay,12)
-- metal
 q(12+ax,105+ay,15+ax,108+ay,
   4+ax,110+ay,8+ax,112+ay,13)
 q(15+ax,108+ay,26+ax,112+ay,
   8+ax,112+ay,25+ax,115+ay,13)
 q(26+ax,112+ay,34+ax,112+ay,
   25+ax,115+ay,32+ax,115+ay,13)
 q(34+ax,112+ay,39+ax,112+ay,
   32+ax,115+ay,38+ax,115+ay,13)
 q(39+ax,112+ay,43+ax,113+ay,
   32+ax,115+ay,45+ax,115+ay,13)
 q(43+ax,113+ay,61+ax,115+ay,
   45+ax,115+ay,61+ax,116+ay,13)
-- details
 line(61+ax,116+ay,245+ax,116+ay,13)
 line(23+ax,113+ay,14+ax,122+ay,13)
 line(24+ax,113+ay,15+ax,122+ay,1)
 line(25+ax,113+ay,16+ax,122+ay,13)
 line(14+ax,122+ay,12+ax,126+ay,13)
 line(15+ax,122+ay,13+ax,126+ay,1)
 line(16+ax,122+ay,14+ax,126+ay,13)
 line(12+ax,126+ay,12+ax,145+ay,13)
 line(13+ax,126+ay,13+ax,145+ay,1)
 line(14+ax,126+ay,14+ax,145+ay,13)
 line(184+ax,116+ay,186+ax,118+ay,13)
 line(185+ax,116+ay,187+ax,118+ay,1)
 line(186+ax,116+ay,188+ax,118+ay,13)
 line(186+ax,118+ay,186+ax,145+ay,13)
 line(187+ax,118+ay,187+ax,145+ay,1)
 line(188+ax,118+ay,188+ax,145+ay,13)
 line(1+ax,119+ay,15+ax,119+ay,13)
 line(21+ax,120+ay,60+ax,120+ay,12)
 line(60+ax,120+ay,72+ax,120+ay,3)
 line(72+ax,120+ay,182+ax,120+ay,13) 
end

-- The Oryx

function rarm(ax,ay,bx,by)
 q(141+ax,91+ay,152+ax,91+ay,
   135+ax,97+ay,145+ax,98+ay,5)
 q(135+ax,97+ay,145+ax,98+ay,
   122+ax,107+ay,131+ax,111+ay,5)
 q(122+ax,107+ay,131+ax,111+ay,
   118+ax,112+ay,122+ax,115.5+ay,5)
 q(86+ax+bx,106+ay+by,118+ax,112+ay,
   85+ax+bx,110+ay+by,106+ax,115.5+ay,12)
 q(85+ax+bx,110+ay+by,106+ax,115.5+ay,
   84+ax+bx,114+ay+by,92+ax,115.5+ay,13)

 --Hand
 q(60+ax,100+ay,62+ax,103+ay,
   55+ax,102+ay,59+ax,105+ay,6)
 q(72+ax,97+ay,73+ax,102+ay,
   66+ax,100+ay,68+ax,103+ay,12)
 q(72+ax,97+ay,76+ax,98+ay,
   73+ax,102+ay,80+ax,101+ay,12) 
 q(73+ax,102+ay,80+ax,101+ay,
   79+ax,109+ay,86+ax+bx,106+ay+by,12)
 q(79+ax,109+ay,86+ax+bx,106+ay+by,
   81+ax,111+ay,85+ax+bx,110+ay+by,12)
 q(81+ax,111+ay,85+ax+bx,110+ay+by,
   83+ax,114+ay,92+ax,115.5+ay,13)
 line(81+ax,105+ay,78+ax,107+ay,14)    
 
 q(75+ax,108+ay,78+ax,107+ay,
   75+ax,111+ay,81+ax,111+ay,12)
 q(75+ax,111+ay,81+ax,111+ay,
   75+ax,113+ay,83+ax,114+ay,13)
 q(68+ax,104+ay,73+ax,102+ay,
   72+ax,115.5+ay,80+ax,115.5+ay,6)
 q(76+ax,110+ay,74+ax,106+ay,
   74+ax,115.5+ay,78+ax,115.5+ay,2)
 
end

function larm(ax,ay)
 q(164+ax,93+ay,167+ax,94+ay,
   167+ax,97+ay,170+ax,97+ay,5)
 q(167+ax,97+ay,170+ax,97+ay,
   170+ax,101+ay,172+ax,101+ay,5)
 q(170+ax,101+ay,172+ax,101+ay,
   164+ax,105+ay,177+ax,108+ay,6)
 q(164+ax,105+ay,177+ax,108+ay,
   166+ax,112+ay,179+ax,113+ay,6)
 q(166+ax,112+ay,179+ax,113+ay,
   164+ax,117+ay,176+ax,117+ay,6)
 q(164+ax,117+ay,176+ax,117+ay,
   164+ax,120+ay,170+ax,120+ay,6)

 q(158+ax,94+ay, 164+ax,93+ay,
   161+ax,98+ay, 167+ax,97+ay,4)
 q(161+ax,98+ay, 167+ax,97+ay,
   162+ax,101+ay, 170+ax,101+ay,4)
 q(153+ax,99+ay,158+ax,94+ay,
   153+ax,102+ay,161+ax,98+ay,4)
 q(153+ax,102+ay,161+ax,98+ay,
   156+ax,105+ay,162+ax,101+ay,4)
 q(162+ax,101+ay,170+ax,101+ay,
   156+ax,105+ay,164+ax,105+ay,6)
 q(156+ax,105+ay,164+ax,105+ay,
   154+ax,110+ay,166+ax,112+ay,12)
 q(154+ax,110+ay,166+ax,112+ay,
   154+ax,115+ay,164+ax,117+ay,12)
 q(154+ax,115+ay,164+ax,117+ay,
   154+ax,120+ay,164+ax,120+ay,13)

 q(152+ax,100+ay,153+ax,99+ay,
   152+ax,103+ay,153+ax,102+ay,5)
 q(152+ax,103+ay,153+ax,102+ay,
   154+ax,105+ay,156+ax,105+ay,5)
 q(154+ax,105+ay,156+ax,105+ay,
   151+ax,109+ay,154+ax,110+ay,12)
 q(151+ax,109+ay,154+ax,110+ay,
   150+ax,114+ay,154+ax,115+ay,12)
 q(150+ax,114+ay,154+ax,115+ay,
   147+ax,119+ay,154+ax,120+ay,13)

 q(130+ax,107+ay,154+ax,105+ay,
   130+ax,109+ay,151+ax,109+ay,12)
 q(130+ax,109+ay,151+ax,109+ay,
   130+ax,112+ay,150+ax,114+ay,12)
 q(130+ax,112+ay,150+ax,114+ay,
   131+ax,116+ay,147+ax,119+ay,13)
   
 q(126+ax,107+ay,130+ax,107+ay,
   125+ax,109+ay,130+ax,109+ay,12)
 q(125+ax,109+ay,130+ax,109+ay,
   126+ax,112+ay,130+ax,112+ay,12)
 q(126+ax,112+ay,130+ax,112+ay,
   130+ax,114+ay,131+ax,116+ay,13)
 q(126+ax,112+ay,130+ax,114+ay,
   126+ax,115.5+ay,131+ax,116+ay,14)
 
 q(122+ax,105+ay,126+ax,107+ay,
   123+ax,109+ay,125+ax,109+ay,13)
 q(123+ax,109+ay,125+ax,109+ay,
   122+ax,112+ay,126+ax,112+ay,13)
 q(122+ax,112+ay,126+ax,112+ay,
   115+ax,115.5+ay,126+ax,115.5+ay,14)   
 
 q(117+ax,104+ay,122+ax,105+ay,
   119+ax,107+ay,123+ax,109+ay,13)
 q(119+ax,107+ay,123+ax,109+ay,
   116+ax,112+ay,121+ax,110+ay,12)
 q(121+ax,110+ay,123+ax,109+ay,
   116+ax,112+ay,122+ax,112+ay,13)
 q(116+ax,112+ay,122+ax,112+ay,
   109+ax,115.5+ay,115+ax,115.5+ay,13)
 
 q(110+ax,105+ay,117+ax,104+ay,
   106+ax,107+ay,119+ax,107+ay,12)
 q(106+ax,107+ay,119+ax,107+ay,
   101+ax,109+ay,116+ax,112+ay,12)
 q(101+ax,109+ay,116+ax,112+ay,
   96+ax,115.5+ay,109+ax,115.5+ay,12)
 
 line(104+ax,109+ay,98+ax,115+ay,14)
 line(104+ax,109+ay,107+ax,108+ay,14) 
 line(109+ax,110+ay,102+ax,115+ay,14) 
 line(126+ax,107+ay,130+ax,107+ay,13)
 line(130+ax,107+ay,154+ax,105+ay,13)
 line(154+ax,105+ay,156+ax,105+ay,13)
end 

function body(ax,ay)
 q(162+ax,71+ay,163+ax,66+ay,
   161+ax,74+ay,164+ax,76+ay,5)

 q(144+ax,80+ay,151+ax,79+ay,
   145+ax,83+ay,150+ax,83+ay,6)
 q(151+ax,79+ay,156+ax,76+ay,
   150+ax,83+ay,155+ax,82+ay,6)
 q(156+ax,76+ay,161+ax,74+ay,
   155+ax,82+ay,160+ax,80+ay,4)
 q(161+ax,74+ay,164+ax,76+ay,
   160+ax,80+ay,164+ax,80+ay,5)

 q(145+ax,83+ay,150+ax,83+ay,
   146+ax,85+ay,150+ax,86+ay,5)
 q(150+ax,83+ay,155+ax,82+ay,
   150+ax,86+ay,153+ax,86+ay,6)
 q(155+ax,82+ay,160+ax,80+ay,
   153+ax,86+ay,161+ax,86+ay,4)
 q(160+ax,80+ay,164+ax,80+ay,
   161+ax,86+ay,164+ax,85+ay,5)

 q(146+ax,85+ay,150+ax,86+ay,
   145+ax,89+ay,147+ax,89+ay,5)
 q(150+ax,86+ay,153+ax,86+ay,
   147+ax,89+ay,150+ax,89+ay,6)
 q(153+ax,86+ay,161+ax,86+ay,
   150+ax,89+ay,158+ax,89+ay,4)
 q(161+ax,86+ay,164+ax,85+ay,
   158+ax,89+ay,165+ax,90+ay,5)

 q(145+ax,89+ay,147+ax,89+ay,
   144+ax,90+ay,146+ax,91+ay,6)
 q(147+ax,89+ay,150+ax,89+ay,
   146+ax,91+ay,149+ax,91+ay,6)
 q(150+ax,89+ay,158+ax,89+ay,
   149+ax,91+ay,154+ax,92+ay,4)
 q(158+ax,89+ay,165+ax,90+ay,
   154+ax,92+ay,166+ax,92+ay,5)

 q(144+ax,90+ay,146+ax,91+ay,
   142+ax,92+ay,144+ax,92+ay,15)
 q(146+ax,91+ay,149+ax,91+ay,
   144+ax,92+ay,147+ax,93+ay,5)
 q(149+ax,91+ay,154+ax,92+ay,
   147+ax,93+ay,151+ax,95+ay,4)
 q(154+ax,92+ay,166+ax,92+ay,
   151+ax,95+ay,168+ax,95+ay,15)

 q(142+ax,92+ay,144+ax,92+ay,
   138+ax,96+ay,141+ax,96+ay,15)
 q(144+ax,92+ay,147+ax,93+ay,
   141+ax,96+ay,143+ax,96+ay,5)
 q(147+ax,93+ay,151+ax,95+ay,
   143+ax,96+ay,148+ax,98+ay,4)
 q(151+ax,95+ay,168+ax,95+ay,
   148+ax,98+ay,169+ax,99+ay,15)

 q(138+ax,96+ay,141+ax,96+ay,
   136+ax,99+ay,141+ax,98+ay,15)
 q(141+ax,96+ay,143+ax,96+ay,
   141+ax,98+ay,142+ax,99+ay,5)
 q(143+ax,96+ay,148+ax,98+ay,
   142+ax,99+ay,145+ax,100+ay,4)
 q(148+ax,98+ay,169+ax,99+ay,
   145+ax,100+ay,167+ax,107+ay,15)
   
 q(136+ax,99+ay,141+ax,98+ay,
   131+ax,102+ay,139+ax,102+ay,15)
 q(141+ax,98+ay,142+ax,99+ay,
   139+ax,102+ay,142+ax,105+ay,15)
 q(142+ax,99+ay,145+ax,100+ay,
   142+ax,105+ay,145+ax,107+ay,15 )
 q(145+ax,100+ay,167+ax,107+ay,
   145+ax,107+ay,167+ax,107+ay,15)

 q(131+ax,102+ay,139+ax,102+ay,
   124+ax,107+ay,138+ax,107+ay,15)
 q(139+ax,102+ay,142+ax,105+ay,
   138+ax,107+ay,145+ax,107+ay,15)
end


function head(ax,ay,st)
 q(126+ax,79+ay,137+ax,78+ay,
   128+ax,82+ay,136+ax,81+ay,12)
 q(128+ax,82+ay,136+ax,81+ay,
   130+ax,84+ay,138+ax,83+ay,13)
 q(130+ax,84+ay,138+ax,83+ay,
   132+ax,86+ay,139+ax,85+ay,14)
 line(137+ax,78+ay,133+ax,81+ay,14)
 line(133+ax,81+ay,128+ax,82+ay,14)
 
 q(198+ax,22+ay,198+ax,22+ay,
   185+ax,26+ay,188+ax,26+ay,14)
 q(198+ax,22+ay,198+ax,22+ay,
   188+ax,26+ay,189+ax,27+ay,15)
 q(185+ax,26+ay,188+ax,26+ay,
   170+ax,36+ay,172+ax,36+ay,14)
 q(188+ax,26+ay,189+ax,27+ay,
   172+ax,36+ay,175+ax,37+ay,15)
 q(170+ax,36+ay,172+ax,36+ay,
   156+ax,49+ay,158+ax,50+ay,14)
 q(172+ax,36+ay,175+ax,37+ay,
   158+ax,50+ay,162+ax,51+ay,15)


 q(121+ax,70+ay,124+ax,68+ay,
   125+ax,71+ay,128+ax,70+ay,12)
 q(123+ax,72+ay,125+ax,71+ay,
   121+ax,73+ay,127+ax,73+ay,12)
 q(125+ax,71+ay,128+ax,70+ay,
   127+ax,73+ay,131+ax,72+ay,12)
 q(121+ax,73+ay,127+ax,73+ay,
   122+ax,76+ay,128+ax,76+ay,12)
 q(127+ax,73+ay,131+ax,72+ay,
   128+ax,76+ay,133+ax,74+ay,12)
 q(122+ax,76+ay,128+ax,76+ay,
   125+ax,79+ay,130+ax,79+ay,12)
 q(128+ax,76+ay,133+ax,74+ay,
   128+ax,79+ay,135+ax,76+ay,12)
 q(128+ax,79+ay,135+ax,76+ay,
   131+ax,79+ay,135+ax,78+ay,12)
   
 q(119+ax,70+ay,121+ax,70+ay,
   119+ax,73+ay,121+ax,73+ay,6)
 q(121+ax,70+ay,125+ax,71+ay,
   121+ax,73+ay,123+ax,72+ay,6)
 q(119+ax,73+ay,121+ax,73+ay,
   120+ax,75+ay,122+ax,76+ay,6)
 line(125+ax,79+ay,131+ax,79+ay,13)   
 line(131+ax,79+ay,135+ax,78+ay,14)
 
 q(124+ax,68+ay,130+ax,66+ay,
   128+ax,70+ay,135+ax,68+ay,6)
 q(128+ax,70+ay,135+ax,68+ay,
   131+ax,72+ay,138+ax,75+ay,6)
 q(131+ax,72+ay,138+ax,75+ay,
   133+ax,74+ay,135+ax,76+ay,6)
 q(135+ax,76+ay,138+ax,75+ay,
   135+ax,78+ay,138+ax,80+ay,6)
 q(135+ax,78+ay,138+ax,80+ay,
   136+ax,81+ay,138+ax,83+ay,6)
   
 q(130+ax,66+ay,137+ax,63+ay,
   135+ax,68+ay,139+ax,65+ay,6)
 q(137+ax,63+ay,141+ax,61+ay,
   139+ax,65+ay,142+ax,63+ay,6)
 q(141+ax,61+ay,143+ax,58+ay,
   142+ax,63+ay,144+ax,61+ay,6)
 q(143+ax,58+ay,146+ax,55+ay,
   144+ax,61+ay,147+ax,59+ay,6)
 q(146+ax,55+ay,151+ax,53+ay,
   147+ax,62+ay,151+ax,59+ay,6)
 
 q(139+ax,65+ay,142+ax,63+ay,
   135+ax,68+ay,140+ax,68+ay,12)
 q(142+ax,63+ay,144+ax,61+ay,
   140+ax,68+ay,144+ax,65+ay,12)
 q(144+ax,61+ay,147+ax,59+ay,
   144+ax,65+ay,147+ax,62+ay,12)
 q(147+ax,59+ay,151+ax,56+ay,
   147+ax,62+ay,151+ax,59+ay,12)
 q(151+ax,56+ay,156+ax,53+ay,
   151+ax,59+ay,159+ax,55+ay,12)

 q(135+ax,68+ay,140+ax,68+ay,
   138+ax,75+ay,141+ax,72+ay,6)
 q(140+ax,68+ay,144+ax,65+ay,
   141+ax,72+ay,144+ax,69+ay,6)
 q(144+ax,65+ay,147+ax,62+ay,
   144+ax,69+ay,147+ax,65+ay,6)
 q(147+ax,62+ay,151+ax,59+ay,
   147+ax,65+ay,150+ax,62+ay,6)
 q(151+ax,59+ay,159+ax,55+ay,
   150+ax,62+ay,160+ax,57+ay,12)
 q(159+ax,55+ay,161+ax,55+ay,
   160+ax,57+ay,162+ax,56+ay,13)
   
 q(141+ax,72+ay,144+ax,69+ay,
   138+ax,75+ay,144+ax,73+ay,12)
 q(144+ax,69+ay,147+ax,65+ay,
   144+ax,73+ay,151+ax,69+ay,12)
 q(147+ax,65+ay,150+ax,62+ay,
   151+ax,69+ay,155+ax,66+ay,12)
 q(150+ax,62+ay,160+ax,57+ay,
   155+ax,66+ay,160+ax,63+ay,12)
 q(160+ax,57+ay,162+ax,56+ay,
   160+ax,63+ay,163+ax,61+ay,13)

 q(138+ax,75+ay,144+ax,73+ay,
   138+ax,80+ay,144+ax,78+ay,12)
 q(144+ax,73+ay,151+ax,69+ay,
   144+ax,78+ay,150+ax,75+ay,12)
 q(151+ax,69+ay,155+ax,66+ay,
   150+ax,75+ay,155+ax,72+ay,12)
 q(155+ax,66+ay,160+ax,63+ay,
   155+ax,72+ay,158+ax,70+ay,12)
 q(160+ax,63+ay,163+ax,61+ay,
   158+ax,70+ay,163+ay,66+ay,13)
   
 q(138+ax,80+ay,144+ax,78+ay,
   138+ax,83+ay,144+ax,80+ay,13)
 q(144+ax,78+ay,150+ax,75+ay,
   144+ax,80+ay,151+ax,79+ay,13)
 q(150+ax,75+ay,155+ax,72+ay,
   150+ax,82+ay,156+ax,78+ay,13)
 q(155+ax,72+ay,158+ax,70+ay,
   156+ax,78+ay,158+ay,76+ay,13)
 q(158+ax,70+ay,163+ay,66+ay,
   158+ay,76+ay,161+ax,74+ay,13)
 q(138+ax,83+ay,144+ax,80+ay,
   139+ax,85+ay,145+ax,81+ay,14)
 q(144+ax,80+ay,151+ax,79+ay,
   145+ax,81+ay,150+ax,82+ay,14)
 q(151+ax,79+ay,156+ax,76+ay,
   150+ax,82+ay,156+ax,78+ay,14)
 q(156+ax,76+ay,158+ax,74+ay,
   156+ax,78+ay,158+ay,76+ay,14)
 q(158+ax,74+ay,162+ax,71+ay,
   158+ay,76+ay,161+ax,74+ay,14)
 --eye
 spr(0,143+ax,60+ay,11,1,0,0,1,1)
 --ear
end

function hairdraw(x,y,l,d,f,c)
 for i=1,l-1+d do
  line(d+x+l-i,y+(d+l-1)*(d+l-1)/f-i*i/f,
       d+x+l-i,y+(d+l-1)*(d+l-1)/f-(i+1)*(i+1)/f,c)
 end
end

function hair(ax,ay,h1,h2,h3,h4)
 q(140+ax,55+ay,141+ax,53+ay,
   141+ax,57+ay,142+ax,56+ay,7)
 q(141+ax,53+ay,142+ax,50+ay+h1/14,
   142+ax,56+ay,145+ax,56+ay,7)
 q(142+ax,50+ay+h1/14,149+ax+abs(h2/4),44+ay+h1/12,
   145+ax,56+ay,151+ax,59+ay,7)
 q(149+ax+abs(h2/4),44+ay+h1/12,156+ax,45+ay+h1/15,
   151+ax,59+ay,155+ax,59+ay,7)
 q(156+ax,45+ay+h1/15,165+ax,50+ay+h1/12,
   155+ax,59+ay,159+ax,60+ay,7)
 q(155+ax,59+ay,159+ax,60+ay,
   154+ax,65+ay,158+ax,70+ay,7)
 q(154+ax,65+ay,158+ax,70+ay,
   151+ax,69+ay,152+ax,72+ay,7)
 q(165+ax,50+ay+h1/12,174+ax,56+ay+h2/12,
   159+ax,60+ay,165+ax,62+ay,7)
 q(159+ax,60+ay,165+ax,62+ay,
   158+ax,70+ay,167+ax,67+ay,7)
 q(158+ax,70+ay,167+ax,67+ay,
   159+ax+h2/12,77+ay+h2/9,170+ax,72+ay,7)
 q(174+ax,56+ay+h2/12,184+ax,60+ay+h2/10,
   165+ax,62+ay,183+ax,69+ay+h2/10,7)
 q(184+ax,60+ay+h2/10,197+ax+h1/20,65+ay+h2/8,
   183+ax,69+ay+h2/10,194+ax+h1/20,71+ay+h2/8,7)
 q(197+ax+h1/20,65+ay+h2/8,207+ax+h1/15,68+ay+h2/4,
   194+ax+h1/20,71+ay+h2/8,204+ax+h1/15,73+ay+h2/4,7)
 q(207+ax+h1/15,68+ay+h2/4,220+ax+h1/10,69+ay+h2/2,
   204+ax+h1/15,73+ay+h2/4,212+ax+h1/10,72+ay+h2/2,7)
   
 q(170+ax,72+ay,174+ax+h2/10,77+ay+h2/8,
   159+ax+h2/12,77+ay+h2/9,164+ax+h2/10,82+ay+h2/8,7)
 q(174+ax+h2/10,77+ay+h2/8,181+ax+h2/8,81+ay+h2/6,
   164+ax+h2/10,82+ay+h2/8,175+ax+h2/8,89+ay+h2/6,7)
 q(181+ax+h2/8,81+ay+h2/6,196+ax+h2/6,85+ay+h2/5,
   175+ax+h2/8,89+ay+h2/6,196+ax+h2/6,93+ay+h2/5,7)
 q(196+ax+h2/6,85+ay+h2/5,215+ax+h2/6,85+ay+h2/4,
   196+ax+h2/6,93+ay+h2/5,218+ax+h2/6,92+ay+h2/4,7)
 q(215+ax+h2/6,85+ay+h2/4,224+ax+h2/6,87+ay+h2/2,
   218+ax+h2/6,92+ay+h2/4,228+ax+h2/6,90+ay+h2/2,7)
 q(173+ax,63+ay, 183+ax,69+ay+h3/16,
   170+ax,72+ay, 181+ax,76+ay+h3/16,7)
 q(183+ax,69+ay+h3/16, 193+ax,73+ay+h3/12,
   181+ax,76+ay+h3/16, 191+ax,79+ay+h3/12,7)
 q(193+ax,73+ay+h3/12,205+ax,77+ay+h3/8,
   191+ax,79+ay+h3/12,204+ax,81+ay+h3/8,7)
 q(205+ax,77+ay+h3/8,214+ax,78+ay+h3/4,
   204+ax,81+ay+h3/8,216+ax,82+ay+h3/4,7)
 q(214+ax,78+ay+h3/4,220+ax,80+ay+h3/2,
   216+ax,82+ay+h3/4,226+ax,84+ay+h3/2,7)
 q(165+ax,50+ay+h1/12,173+ax,63+ay, 
   155+ax,65+ay,170+ax,72+ay,7)
 line(143+ax,52+ay,150+ax,45+ay+h1/14,8)
 line(143+ax,52+ay,148+ax,45+ay+h1/14,8) 
 line(143+ax,52+ay,144+ax,47+ay+h1/12,8)  
 q(143+ax,52+ay,149+ax,48+ay,
   143+ax,53+ay,150+ax,50+ay,8)
 q(149+ax,48+ay,155+ax,46+ay,
   150+ax,50+ay,155+ax,48+ay,8)
 q(155+ax,46+ay,163+ax,50+ay+h1/12,
   155+ax,48+ay,163+ax,51+ay+h1/12,8)
 q(163+ax,50+ay+h1/12,172+ax,56+ay+h1/10,
   163+ax,51+ay+h1/12,172+ax,57+ay+h1/10,8)   
 q(152+ax,53+ay,158+ax,51+ay,
   153+ax,55+ay,158+ax,57+ay,8)

 hairdraw(156+ax,51+ay,65,0,250+h1*2,8)
 hairdraw(157+ax,53+ay,55,0,140+h1*3,8) 
 hairdraw(159+ax,67+ay,65,0,150+h3,5)
 hairdraw(159+ax,63+ay,65,0,150+h1,5)
 hairdraw(159+ax,64+ay,65,0,250+6*h2,7)
 hairdraw(159+ax,60+ay,74,0,140+h2,7)
 hairdraw(162+ax,64+ay,50,0,85+h3,7)
 hairdraw(177+ax,72+ay,47,0,121+h2,7)
 hairdraw(166+ax,62+ay,57,0,200+h4,7)
 hairdraw(156+ax,61+ay,57,0,100+h3,7)   
 hairdraw(176+ax,86+ay,40,0,100+h3,7)
 hairdraw(176+ax,87+ay,30,0,120+h2,7) 
 hairdraw(157+ax,54+ay,77,0,158+h4,7)  
 hairdraw(176+ax,89+ay+h2/4,30,0,120+h1,7)  
 hairdraw(158+ax,61+ay,65,0,150+h4,5)
 hairdraw(157+ax,67+ay,70,0,150+h1,8)
 hairdraw(157+ax,57+ay,77,0,158+h4,8) 
 hairdraw(157+ax,54+ay,65,0,178+h3*4,8)
 hairdraw(167+ax,77+ay,50,0,100+h1,8)
 hairdraw(162+ax,64+ay,50,0,85+h1,8)
 hairdraw(168+ax,68+ay,50,0,185+h1,8) 
 hairdraw(165+ax,84+ay+h2/12,50,0,185+h1*6,8)  
 hairdraw(159+ax,75+ay+h2/12,50,0,100+h2,8)
 hairdraw(168+ax,68+ay,50,0,85+h1,8) 
 hairdraw(156+ax,67+ay,57,0,100+h4,8)

 q(176+ax,40+ay,179+ax,41+ay,
   163+ax,52+ay,165+ax,54+ay,13)
 q(179+ax,41+ay,181+ax,42+ay,
   165+ax,54+ay,168+ax,56+ay,14)
 q(191+ax,30+ay,193+ax,31+ay,
   176+ax,40+ay,179+ax,41+ay,13)
 q(193+ax,31+ay,195+ax,32+ay,
   179+ax,41+ay,181+ax,42+ay,14)
 q(207+ax,24+ay,207+ax,24+ay,
   191+ax,30+ay,193+ax,31+ay,13)
 q(207+ax,24+ay,207+ax,24+ay,
   193+ax,31+ay,195+ax,32+ay,14)


 spr(16,156+ax,55+ay,11,1,0,0,2,2)
end

function drawmirror(ax,ay)
 elli(66+ax,120+ay,6,4,13)
 elli(66+ax,120+ay,4,2,14) 
 elli(66+ax,120+ay,2,1,13)  
 q(62+ax,109+ay,64+ax,109+ay,
   64+ax,120+ay,67+ax,120+ay,13)
 q(61+ax,91+ay,68+ax,89+ay,
   61+ax,110+ay,68+ax,111+ay,14)
 q(68+ax,89+ay,76+ax,88+ay,
   68+ax,111+ay,76+ax,113+ay,13)
end

function drawdesert(tim)
cls(10)
for i=0,240 do
 line(i,60+1.6*sin((i-tim/600)/23)+0.9*sin((i-tim/600)/31+1)+2.1*sin((i-tim/6000)/60+.6),i,68,4)
end
rect(0,68,240,100,3)
rect(0,100,240,100,0)
rect((-30+tim/1.5)%1000,0,5,90,1)
elli((-30+tim/1.5)%1000+2,89,2,1,1)
 for i=1,480 do
  pix(-11+(tim/4+(i-1))%600,75+rn[i+7],7)
 end
 for i=1,240 do
  pix(-12+(tim/3+(i-1)*2)%600,77+rn[i+7],7)
 end
 for i=1,120 do
  circ(-10+(tim/2.5+(i-1)*5)%600,79+rn[i+24],(4-rn[i*2])/3,7)
 end
 for i=1,60 do
  circ(-10+(tim/2.25+(i-1)*10)%600,82+rn[i+24],(4-rn[i*2])/3,7)
 end
 for i=1,30 do
  elli(-15+(tim/2+(i-1)*30)%600,85+rn[i],(7-rn[i*2])/2,(3-rn[i])/2,7)
 end
 for i=1,20 do
  elli(-13+(tim/1.75+(i-1)*45)%600,89+rn[i]/2,(7-rn[i*2])/1.5,(3-rn[i])/1.5,7)
 end
 for i=1,15 do
  elli(-10+(tim/1.5+(i-1)*60)%600,92+rn[i],7-rn[i*2],2-rn[i]/2,7)
 end
 for i=1,24 do
  elli(((tim/1.5+(i-1)*60)%600)+rn[i+12],99,30-rn[i+27],1,14) 
  if rn[i]>1 then 
   elli(((tim/1.5+(i-1)*60)%600)+rn[i+23],99,16-rn[i+17],1,0)
  end
 end  
end

function BDR(lin)
 vbank(0)
 
 if (lin > 68) and (lin%4==0) then
 poke(0x3fc9,228-(lin-68))
 poke(0x3fca,161-(lin-68)*2)
 poke(0x3fcb,104-(lin-68)*2.5)
 end
end 


function BOOT()
 for i=1,600 do
  rn[i]=rand(1,5)-1
 end
 vbank(0)
 vbank(1)
 loadpal(pal1)
 poke(0x3FF8,11)
 readsprite(spr0,0)
 readsprite(spr16,16) 
 readsprite(spr17,17)
 readsprite(spr32,32)
 readsprite(spr33,33)   
end

function TIC()
 pt=time()
 t=time()//60
 vbank(1)
 cls(11)
 vbank(0)
 drawdesert(pt)
 vbank(1)
 car(0,abs(1/4*sin(t)+sin(t/8)))
 rarm(0,abs(1/4*sin(t)+sin(t/8)),0,0)
 body(0,abs(1/4*sin(t)+sin(t/8)))
 head(0,abs(1/4*sin(t)+sin(t/8)),0)
 larm(0,abs(1/4*sin(t)+sin(t/8))) 
 hair(0,abs(1/4*sin(t)+sin(t/8)),10*cos(t/4),10*sin(t/4),7*cos(t/2),9*sin(t/2))
 drawmirror(0,abs(1/4*sin(t)+sin(t/8)))
 print("Remember to drive home safely!",20,20,0)
 print("Remember to drive home safely!",20,19,12) 
 print("See you @ Instanssi'25",30,30,0)
 print("See you @ Instanssi'25",30,29,12) 
end
 