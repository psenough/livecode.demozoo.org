sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi
flr=math.floor
l=line

pal={0,0,0,
     135,33,3,
     210,69,27,
     248,121,53,
     40,10,0,
     86,15,0,
     120,32,14,
     255,163,0,
     41,54,111,
     59,93,201,
     65,166,246,
     115,239,247,
     244,244,244,
     148,176,194,
     85,108,134,
     51,60,87}

function clmp(val,min,max)
 if val > min then
  if val < max then
   return val
  else
   return max
  end 
 else
  return min
 end 
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

function q(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x2,y2,x3,y3,x4,y4,col) 
end

function qr(x1,y1,x2,y2,x3,y3,x4,y4,col,ox,oy,r)
 tri(ox+x1*cos(r)-y1*sin(r),
     oy+x1*sin(r)+y1*cos(r),
     ox+x2*cos(r)-y2*sin(r),
     oy+x2*sin(r)+y2*cos(r),
     ox+x3*cos(r)-y3*sin(r),
     oy+x3*sin(r)+y3*cos(r),
     col)
 tri(ox+x2*cos(r)-y2*sin(r),
     oy+x2*sin(r)+y2*cos(r),
     ox+x3*cos(r)-y3*sin(r),
     oy+x3*sin(r)+y3*cos(r),
     ox+x4*cos(r)-y4*sin(r),
     oy+x4*sin(r)+y4*cos(r),     
     col)
end

function lr(x1,y1,x2,y2,col,ox,oy,r)
 line(ox+x1*cos(r)-y1*sin(r),
     oy+x1*sin(r)+y1*cos(r),
     ox+x2*cos(r)-y2*sin(r),
     oy+x2*sin(r)+y2*cos(r),col)
end

function BOOT()
 vbank(1)
 loadpal(pal)
 poke(0x3ff8,7)
 vbank(0)
end 

function leg1(ax,ay)
 q(133+ax,116+ay, 145+ax,116+ay,
   131+ax,129+ay, 145+ax,125+ay,5)
 q(124+ax,115+ay, 133+ax,116+ay,
   124+ax,129+ay, 131+ax,129+ay,1)
 q(123+ax,115+ay, 124+ax,115+ay,
   121+ax,123+ay, 124+ax,129+ay,1)
 q(113+ax,117+ay, 123+ax,115+ay,
   116+ax,123+ay, 121+ax,123+ay,6)
 q(112+ax,118+ay, 114+ax,117+ay,
   113+ax,121+ay, 116+ax,123+ay,6)
 q(109+ax,119+ay, 112+ax,118+ay,
   110+ax,122+ay, 113+ax,121+ay,6)
 q(103+ax,121+ay, 109+ax,119+ay,
   104+ax,123+ay, 110+ax,122+ay,6)
 q(116+ax,122+ay, 121+ax,122+ay,
   117+ax,128+ay, 119+ax,128+ay,6)
 q( 91+ax,121+ay,  97+ax,121+ay,
    89+ax,126+ay,  99+ax,126+ay,6)
 q( 89+ax,126+ay,  99+ax,126+ay,
    91+ax,131+ay,  98+ax,131+ay,6)
 q( 79+ax,118+ay,  87+ax,121+ay,
    77+ax,126+ay,  86+ax,126+ay,6)
 q( 77+ax,126+ay,  86+ax,126+ay,
    78+ax,131+ay,  83+ax,131+ay,6)
 
 q(113+ax,121+ay, 116+ax,123+ay,
   116+ax,131+ay, 117+ax,128+ay,5)
 q(117+ax,128+ay, 119+ax,128+ay,
   116+ax,131+ay, 120+ax,131+ay,5)
 q(119+ax,128+ay, 121+ax,123+ay,
   120+ax,131+ay, 121+ax,127+ay,5)
 q(121+ax,123+ay, 124+ax,129+ay,
   121+ax,127+ay, 122+ax,130+ay,5)
 q(122+ax,130+ay, 124+ax,129+ay,
   123+ax,131+ay, 127+ax,132+ay,5)
 q(124+ax,129+ay, 131+ax,129+ay,
   127+ax,132+ay, 136+ax,132+ay,5)
 q(131+ax,129+ay, 145+ax,125+ay,
   136+ax,132+ay, 149+ax,130+ay,5)
 q(110+ax,122+ay, 113+ax,121+ay,
   103+ax,128+ay, 116+ax,131+ay,5)
 q(104+ax,123+ay, 110+ax,122+ay,
   102+ax,126+ay, 103+ax,128+ay,5)
 q( 98+ax,120+ay, 101+ax,120+ay,
    99+ax,126+ay, 102+ax,126+ay,5)
 q( 99+ax,126+ay, 102+ax,126+ay,
    98+ax,131+ay, 103+ax,128+ay,5)
 q( 98+ax,131+ay, 103+ax,128+ay,
    97+ax,133+ay, 101+ax,133+ay,5)
 q( 91+ax,131+ay,  98+ax,131+ay,
    91+ax,133+ay,  97+ax,133+ay,5)
 q( 97+ax,119+ay,  98+ax,120+ay,
    97+ax,121+ay,  99+ax,126+ay,5)
 q( 92+ax,119+ay,  97+ax,119+ay,
    91+ax,121+ay,  97+ax,121+ay,5)
 q( 88+ax,119+ay,  92+ax,120+ay,
    87+ax,121+ay,  91+ax,121+ay,5)
 q( 82+ax,116+ay,  88+ax,119+ay,
    79+ax,118+ay,  87+ax,121+ay,5)
 q( 87+ax,121+ay,  91+ax,121+ay,
    86+ax,126+ay,  89+ax,126+ay,5)
 q( 86+ax,126+ay,  89+ax,126+ay,
    83+ax,131+ay,  91+ax,131+ay,5)
 q( 83+ax,131+ay,  91+ax,131+ay,
    83+ax,133+ay,  91+ax,133+ay,5)
 q( 78+ax,131+ay,  83+ax,131+ay,
    78+ax,133+ay,  83+ax,133+ay,5)
    
 q(101+ax,120+ay, 103+ax,121+ay,
   102+ax,126+ay, 104+ax,123+ay,4)
 q(103+ax,128+ay, 116+ax,131+ay,
   101+ax,133+ay, 116+ax,133+ay,4)
 q(116+ax,131+ay, 120+ax,131+ay,
   116+ax,133+ay, 120+ax,133+ay,4)
 q(120+ax,131+ay, 123+ax,131+ay,
   120+ax,133+ay, 122+ax,133+ay,4)
 q(121+ax,127+ay, 122+ax,130+ay,
   120+ax,131+ay, 123+ax,131+ay,4)
 q(123+ax,131+ay, 127+ax,132+ay,
   122+ax,133+ay, 126+ax,133+ay,4)
 q(127+ax,132+ay, 136+ax,132+ay,
   126+ax,133+ay, 137+ax,133+ay,4) 
 q(136+ax,132+ay, 149+ax,130+ay,
   137+ax,133+ay, 154+ax,133+ay,4)
end

function leg2(ax,ay,bx,by,cx,cy,dx,dy,tx,ty)
 q( 64+bx,115+by,  69+bx,118+by,
    60+ax,118+ay,  67+ax,123+ay,6)
 q( 56+ax,120+ay,  60+ax,118+ay,
    65+ax,127+ay,  67+ax,123+ay,6)
 q( 54+ax,121+ay,  56+ax,120+ay,
    61+ax,129+ay,  65+ax,127+ay,6)
 q( 51+ax,123+ay,  54+ax,121+ay,
    57+ax,129+ay,  61+ax,129+ay,6)
 q( 47+ax,125+ay,  51+ax,123+ay,
    49+ax,130+ay,  57+ax,129+ay,6)
 q( 40+ax,127+ay,  47+ax,125+ay,
    41+ax,130+ay,  49+ax,130+ay,6)
 q( 38+ax,128+ay,  40+ax,127+ay,
    39+ax,131+ay,  41+ax,130+ay,6)
 q( 36+tx,128+ty,  38+ax,128+ay,
    37+tx,131+ty,  39+ax,131+ay,6)
 q( 35+tx,129+ty,  36+tx,128+ty,
    34+tx,131+ty,  37+tx,131+ty,6)

 q( 69+bx,118+by,  72+bx,119+by,
    67+ax,123+ay,  73+ax,127+ay,5)
 q( 67+ax,123+ay,  73+ax,127+ay,
    65+ax,127+ay,  71+ax,130+ay,5)
 q( 65+ax,127+ay,  71+ax,130+ay,
    61+ax,129+ay,  68+ax,133+ay,5)
 q( 57+ax,129+ay,  61+ax,129+ay,
    57+ax,132+ay,  68+ax,133+ay,5)
 q( 49+ax,130+ay,  57+ax,129+ay,
    52+ax,133+ay,  57+ax,132+ay,5)
 q( 41+ax,130+ay,  49+ax,130+ay,
    43+ax,133+ay,  52+ax,133+ay,5)
 q( 39+ax,131+ay,  41+ax,130+ay,
    40+ax,132+ay,  43+ax,133+ay,5)
 q( 37+tx,131+ty,  39+ax,131+ay,
    38+tx,133+ty,  40+ax,132+ay,5)
 q( 34+tx,131+ty,  37+tx,131+ty,
    36+tx,133+ty,  38+tx,133+ty,5)

 q( 72+bx,119+by,  74+bx,120+by,
    73+ax,127+ay,  75+ax,128+ay,4)
 q( 73+ax,127+ay,  75+ax,128+ay,
    71+ax,130+ay,  73+ax,131+ay,4)
 q( 71+ax,130+ay,  73+ax,131+ay,
    68+ax,133+ay,  72+ax,133+ay,4)
 
 q( 64+bx,115+by,  74+bx,106+by,
    69+bx,118+by,  77+bx,109+by,6)
 q( 74+bx,106+by,  81+bx,100+by,
    77+bx,109+by,  87+bx,103+by,6)
 q( 81+bx,100+by,  93+bx, 88+by,
    87+bx,103+by,  98+bx, 95+by,6)
 q( 93+bx, 88+by,  99+bx, 83+by,
    98+bx, 95+by, 103+bx, 91+by,6)
 q( 99+bx, 83+by, 105+bx, 80+by,
   103+bx, 91+by, 108+bx, 88+by,6)
   
 q( 69+bx,118+by,  77+bx,109+by,
    72+bx,119+by,  80+bx,112+by,5)
 q( 77+bx,109+by,  87+bx,103+by,
    80+bx,112+by,  89+bx,107+by,5)
 q( 87+bx,103+by,  98+bx, 95+by,
    89+bx,107+by, 101+bx,102+by,5)
 q( 98+bx, 95+by, 103+bx, 91+by,
   101+bx,102+by, 106+bx, 97+by,5)
 q(103+bx, 91+by, 108+bx, 88+by,
   106+bx, 97+by, 109+bx, 93+by,5)

 q( 72+bx,119+by,  80+bx,112+by,
    74+bx,120+by,  81+bx,114+by,4)
 q( 80+bx,112+by,  89+bx,107+by,
    81+bx,114+by,  90+bx,110+by,4)
 q( 89+bx,107+by, 101+bx,102+by,
    90+bx,110+by, 102+bx,106+by,4)
 q(101+bx,102+by, 106+bx, 97+by,
   102+bx,106+by, 107+bx,101+by,4)
 q(106+bx, 97+by, 109+bx, 93+by,
   107+bx,101+by, 110+bx, 98+by,4)
   
 q(105+bx, 80+by, 109+cx, 78+cy,
   108+bx, 88+by, 113+cx, 85+cy,3)
 q(109+cx, 78+cy, 118+cx, 77+cy,
   113+cx, 85+cy, 118+cx, 86+cy,3)
 q(118+cx, 77+cy, 127+cx, 82+cy,
   118+cx, 86+cy, 127+cx, 91+cy,3)
 q(127+cx, 82+cy, 134+cx, 87+cy,
   127+cx, 91+cy, 132+cx, 94+cy,3)
 q(134+cx, 87+cy, 142+cx, 94+cy,
   132+cx, 94+cy, 140+cx, 99+cy,3)
 q(142+cx, 94+cy, 145+cx, 98+cy,
   140+cx, 99+cy, 143+cx,101+cy,3)
 q(145+cx, 98+cy, 148+cx,101+cy,
   143+cx,101+cy, 146+cx,104+cy,3)
 q(148+cx,101+cy, 152+cx,105+cy,
   146+cx,104+cy, 151+cx,107+cy,3)
 q(152+cx,105+cy, 154+cx,107+cy,
   151+cx,107+cy, 156+cx,111+cy,3)

 q(108+bx, 88+by, 113+cx, 85+cy,
   109+bx, 93+by, 112+cx, 94+cy,2)
 q(113+cx, 85+cy, 118+cx, 86+cy,
   112+cx, 94+cy, 119+cx,103+cy,2)
 q(118+cx, 86+cy, 127+cx, 91+cy,
   119+cx,103+cy, 126+cx,108+cy,2) 
 q(127+cx, 91+cy, 132+cx, 94+cy,
   126+cx,108+cy, 131+cx,112+cy,2)
 q(132+cx, 94+cy, 140+cx, 99+cy,
   131+cx,112+cy, 134+cx,115+cy,2)
 q(140+cx, 99+cy, 143+cx,101+cy,
   134+cx,115+cy, 141+dx,120+dy,2) 
 q(143+cx,101+cy, 146+cx,104+cy,
   141+dx,120+dy, 144+dx,126+dy,2)
 q(146+cx,104+cy, 151+cx,107+cy,
   144+dx,126+dy, 151+dx,129+dy,2)
 q(151+cx,107+cy, 156+cx,111+cy,
   151+dx,129+dy, 157+dx,127+dy,2)
 q(156+cx,111+cy, 160+dx,113+dy, 
   157+dx,127+dy, 161+dx,121+dy,2)
 q(160+dx,113+dy, 164+dx,115+dy,
   161+dx,121+dy, 163+dx,118+dy,2)

 q(109+bx, 93+by, 112+cx, 94+cy,
   110+bx, 98+by, 112+cx,101+cy,1)
 q(112+cx, 94+cy, 119+cx,103+cy,
   112+cx,101+cy, 117+cx,108+cy,1)
 q(119+cx,103+cy, 126+cx,108+cy,
   117+cx,108+cy, 124+cx,114+cy,1)
 q(126+cx,108+cy, 131+cx,112+cy,
   124+cx,114+cy, 131+cx,118+cy,1)
 q(131+cx,112+cy, 134+cx,115+cy,
   131+cx,118+cy, 133+dx,122+dy,1)
 q(134+cx,115+cy, 141+dx,120+dy,
   133+dx,122+dy, 138+dx,127+dy,1) 

 q(141+dx,120+dy, 144+dx,126+dy,
   138+dx,127+dy, 142+dx,131+dy,1)
 q(144+dx,126+dy, 151+dx,129+dy,
   142+dx,131+dy, 145+dx,133+dy,1)
 q(151+dx,129+dy, 157+dx,127+dy,
   145+dx,133+dy, 156+dx,133+dy,1)
 q(157+dx,127+dy, 161+dx,121+dy,
   156+dx,133+dy, 164+dx,127+dy,1)
 q(161+dx,121+dy, 163+dx,118+dy,
   164+dx,127+dy, 166+dx,122+dy,1)
 q(164+dx,115+dy, 166+dx,116+dy,
   163+dx,118+dy, 166+dx,122+dy,1)
end

function head(ax,ay,bx,by)
 q(156+ax, 37+ay, 157+ax, 38+ay,
   156+ax, 41+ay, 158+ax, 42+ay,12)
 q(157+ax, 38+ay, 158+ax, 38+ay,
   158+ax, 42+ay, 159+ax, 44+ay,12)
 q(158+ax, 38+ay, 160+ax, 37+ay,
   159+ax, 44+ay, 160+ax, 47+ay,12)
 q(160+ax, 37+ay, 166+ax, 39+ay,
   160+ax, 47+ay, 167+ax, 49+ay,12)
 q(166+ax, 39+ay, 172+ax, 41+ay,
   167+ax, 49+ay, 172+ax, 51+ay,12)
 q(172+ax, 41+ay, 176+ax, 42+ay,
   172+ax, 51+ay, 175+ax, 52+ay,12)
 q(175+ax, 40+ay, 182+ax, 42+ay,
   176+ax, 42+ay, 182+ax, 43+ay,12)
 q(176+ax, 42+ay, 182+ax, 43+ay,
   175+ax, 52+ay, 181+ax, 54+ay,12)
 q(182+ax, 43+ay, 185+ax, 43+ay,
   181+ax, 54+ay, 186+ax, 55+ay,12)
 q(182+ax, 42+ay, 186+ax, 42+ay,
   182+ax, 43+ay, 185+ax, 43+ay,12)
 q(185+ax, 43+ay, 188+ax, 44+ay,
   186+ax, 55+ay, 188+ax, 49+ay,12)
 q(188+ax, 44+ay, 191+ax, 46+ay,
   188+ax, 49+ay, 191+ax, 50+ay,12)
 q(191+ax, 46+ay, 193+ax, 48+ay,
   191+ax, 50+ay, 193+ax, 49+ay,12)
 q(188+ax, 49+ay, 191+ax, 50+ay,
   185+ax, 55+ay, 190+ax, 55+ay,12)
 q(191+ax, 50+ay, 192+ax, 52+ay,
   190+ax, 55+ay, 192+ax, 54+ay,12)

 q(199+ax, 33+ay, 206+ax, 35+ay,
   194+ax, 35+ay, 203+ax, 38+ay,2)
 q(206+ax, 35+ay, 211+ax+bx, 41+ay+by,
   203+ax, 38+ay, 208+ax, 40+ay,2)
 q(194+ax, 35+ay, 203+ax, 38+ay,
   194+ax, 38+ay, 203+ax, 41+ay,2)
 q(203+ax, 38+ay, 206+ax+bx, 42+ay+by,
   203+ax, 41+ay, 206+ax+bx, 44+ay+by,2)
 q(203+ax, 41+ay, 206+ax+bx, 44+ay+by,
   202+ax, 45+ay, 207+ax+bx, 49+ay+by,2)
 q(202+ax, 45+ay, 207+ax+bx, 49+ay+by,
   201+ax, 48+ay, 204+ax+bx, 50+ay+by,1)
 q(204+ax+bx, 50+ay+by, 207+ax+bx, 49+ay+by,
   206+ax+by, 52+ay+by, 207+ax+by, 54+ay+by,1)
 q(194+ax, 38+ay, 203+ax, 41+ay,
   193+ax, 40+ay, 202+ax, 45+ay,2)
 q(193+ax, 40+ay, 202+ax, 45+ay,
   193+ax, 43+ay, 201+ax, 48+ay,2)
 q(193+ax, 43+ay, 201+ax, 48+ay,
   195+ax, 48+ay, 200+ax, 50+ay,2)
 q(195+ax, 48+ay, 200+ax, 50+ay,
   195+ax, 52+ay, 200+ax, 53+ay,2)
 q(195+ax, 52+ay, 200+ax, 53+ay,
   194+ax, 56+ay, 197+ax, 56+ay,2)
 q(197+ax, 56+ay, 200+ax, 53+ay,
   197+ax, 61+ay, 199+ax, 58+ay,2)
 
 q(163+ax, 33+ay, 168+ax, 35+ay,
   162+ax, 35+ay, 167+ax, 36+ay,3)
 q(162+ax, 35+ay, 167+ax, 36+ay,
   160+ax, 37+ay, 166+ax, 39+ay,3)
 q(168+ax, 35+ay, 174+ax, 36+ay,
   167+ax, 36+ay, 173+ax, 37+ay,3)
 q(167+ax, 36+ay, 173+ax, 37+ay,
   166+ax, 39+ay, 172+ax, 41+ay,3)  
 q(173+ax, 37+ay, 175+ax, 40+ay,
   172+ax, 41+ay, 176+ax, 42+ay,3)
 q(173+ax, 37+ay, 179+ax, 37+ay,
   175+ax, 40+ay, 182+ax, 42+ay,3)
 q(179+ax, 37+ay, 187+ax, 39+ay,
   182+ax, 42+ay, 186+ax, 42+ay,3)
 q(180+ax, 33+ay, 183+ax, 32+ay,
   181+ax, 34+ay, 184+ax, 34+ay,3)
 q(183+ax, 32+ay, 186+ax, 31+ay,
   184+ax, 34+ay, 191+ax, 32+ay,3)
 q(184+ax, 34+ay, 191+ax, 32+ay,
   187+ax, 37+ay, 190+ax, 37+ay,3)
 q(187+ax, 37+ay, 190+ax, 37+ay,
   187+ax, 39+ay, 190+ax, 39+ay,3)
 q(187+ax, 39+ay, 190+ax, 39+ay,
   186+ax, 42+ay, 189+ax, 42+ay,3)
 q(186+ax, 42+ay, 189+ax, 42+ay,
   185+ax, 43+ay, 188+ax, 44+ay,3)
 q(191+ax, 32+ay, 194+ax, 35+ay,
   190+ax, 37+ay, 194+ax, 38+ay,3)
 q(190+ax, 37+ay, 194+ax, 38+ay,
   190+ax, 39+ay, 193+ax, 40+ay,3)
 q(190+ax, 39+ay, 193+ax, 40+ay,
   189+ax, 42+ay, 193+ax, 43+ay,3)
 q(189+ax, 42+ay, 193+ax, 43+ay,
   188+ax, 44+ay, 191+ax, 46+ay,3)
 q(187+ax, 24+ay, 191+ax, 28+ay,
   186+ax, 31+ay, 191+ax, 32+ay,3)
 q(191+ax, 28+ay, 199+ax, 33+ay,
   191+ax, 32+ay, 194+ax, 35+ay,3)
 q(183+ax, 23+ay, 187+ax, 24+ay,
   182+ax, 28+ay, 186+ax, 31+ay,3)
 q(177+ax, 23+ay, 183+ax, 23+ay,
   179+ax, 25+ay, 182+ax, 28+ay,3)
 q(180+ax, 33+ay, 181+ax, 34+ay,
   174+ax, 36+ay, 180+ax, 35+ay,2)
 q(193+ax, 43+ay, 195+ax, 48+ay, 
   191+ax, 46+ay, 193+ax, 48+ay,3)
 q(193+ax, 48+ay, 195+ax, 48+ay,
   193+ax, 49+ay, 195+ax, 52+ay,3)
 q(193+ax, 49+ay, 195+ax, 52+ay,
   191+ax, 50+ay, 192+ax, 52+ay,3)
 q(192+ax, 52+ay, 195+ax, 52+ay,
   192+ax, 55+ay, 194+ax, 56+ay,3)
 q(192+ax, 54+ay, 194+ax, 56+ay,
   191+ax, 57+ay, 193+ax, 59+ay,2)
 q(190+ax, 55+ay, 192+ax, 54+ay,
   189+ax, 57+ay, 191+ax, 57+ay,2)
 q(186+ax, 55+ay, 190+ax, 55+ay,
   187+ax, 56+ay, 189+ax, 57+ay,2)
 
 q(175+ax, 52+ay, 181+ax, 54+ay,
   178+ax, 55+ay, 183+ax, 56+ay,13)
 q(181+ax, 54+ay, 186+ax, 55+ay,
   183+ax, 56+ay, 187+ax, 56+ay,13)
 
 q(174+ax, 36+ay, 180+ax, 35+ay,
   173+ax, 37+ay, 179+ax, 37+ay,2)
   
 q(181+ax, 34+ay, 184+ax, 34+ay,
   180+ax, 35+ay, 187+ax, 37+ay,12)
 q(180+ax, 35+ay, 187+ax, 37+ay,
   179+ax, 37+ay, 187+ax, 39+ay,12)
  
 q(156+ax, 33+ay, 160+ax, 33+ay,
   156+ax, 37+ay, 160+ax, 37+ay,0)
 q(156+ax, 37+ay, 160+ax, 37+ay,
   157+ax, 38+ay, 158+ax, 38+ay,0)
 q(160+ax, 33+ay, 163+ax, 33+ay,
   160+ax, 37+ay, 162+ax, 35+ay,0) 
   
 q(197+bx, 18+ay, 197+bx, 21+ay,
   191+ax, 32+ay, 194+ax, 35+ay,12)
 q(197+bx, 18+ay, 197+bx, 21+ay,
   194+ax, 35+ay, 199+ax, 33+ay,5)
 
 l(156+ax, 33+ay, 160+ax, 33+ay,0)
 l(156+ax, 33+ay, 156+ax, 37+ay,0)
 l(156+ax, 37+ay, 156+ax, 41+ay,13)
 l(156+ax, 41+ay, 157+ax, 41+ay,13)
 l(157+ax, 41+ay, 160+ax, 47+ay,13)
 l(160+ax, 47+ay, 167+ax, 49+ay,13)
 l(167+ax, 49+ay, 172+ax, 51+ay,13)
 
 l(181+ax, 33+ay, 181+ax, 34+ay,15)
 l(181+ax, 34+ay, 184+ax, 34+ay,15)
 l(184+ax, 34+ay, 187+ax, 37+ay,15)
 l(187+ax, 37+ay, 187+ax, 39+ay,15)
 
 l(159+ax, 44+ay, 168+ax, 46+ay,13)
 l(168+ax, 46+ay, 172+ax, 45+ay,13)
end   


function fantahand(ax,ay,rot)

 qr(-5,-9, 5,-9,
    -5, 7, 5, 7,1,ax,ay,rot)
 qr(-4,-9, 4,-9,
    -4, 7, 4, 7,2,ax,ay,rot)
 qr(-3,-9, 3,-9,
    -3, 7, 3, 7,3,ax,ay,rot)

 qr(-4,-11, -3,-11,
    -5,-9,-4,-9,14,ax,ay,rot)
 qr(-3,-11,  3,-11,
    -4,-9, 4,-9,13,ax,ay,rot)
 qr( 3,-11, 4,-11,
     4,-9, 5,-9,14,ax,ay,rot)
 
 qr(-5,7,-4,7,
    -4,9, -3,9,14,ax,ay,rot)
 qr(-4,7, 4,7,
    -3,9,  3,9,13,ax,ay,rot)
 qr(4,7, 5,7,
    3,9, 4,9,14,ax,ay,rot)

 qr(-1,-4, 2,-2,
    -1,-1, 1,-1,6,ax,ay,rot)
 qr(-1,-4, 2,-2,
     2,-7, 3,-3,6,ax,ay,rot)
 qr( 2,-7, 5,-7,
     3,-3, 8,-4,6,ax,ay,rot)
 qr( 3,-3, 8,-4,
     4, 0, 8,-1,6,ax,ay,rot)
 qr( 4, 0, 8,-1,
     5, 3, 8, 2,6,ax,ay,rot)
 qr( 5, 3, 8, 2,
     5, 5, 7, 4,6,ax,ay,rot)

 qr(-5,-7,-2,-6,  
    -5,-4,-2,-3,6,ax,ay,rot)
 qr(-8,-7,-5,-7,
    -9,-4,-5,-4,6,ax,ay,rot)
 qr(-9,-4,-5,-4,
    -9,-1,-5,-1,6,ax,ay,rot)
 qr(-5,-4,-2,-3,
    -5,-1,-1,-1,6,ax,ay,rot)
 qr(-9,-1,-5,-1,
    -8, 3,-5, 3,6,ax,ay,rot)
 qr(-5,-1,-1,-1,
    -5, 2,-2, 2,6,ax,ay,rot)
 qr(-8, 3,-5, 3,
    -7, 6,-4, 6,6,ax,ay,rot)
 qr(-5, 2,-2, 2,
    -4, 6,-3, 6,6,ax,ay,rot)
 lr(-9, 0,-5, 1,5,ax,ay,rot)
 lr(-9,-4,-5,-3,5,ax,ay,rot)
 lr(-8, 3,-5, 4,5,ax,ay,rot)
end

function arm1(ax,ay,bx,by,cx,cy,dy,dy)
 elli(150+bx,79+by,7,5,6)
 q(147+bx, 75+by, 173+ax, 60+ay,
   150+bx, 79+by, 171+ax, 66+ay,2)
 q(150+bx, 79+by, 171+ax, 66+ay,
   153+bx, 85+by, 171+ax, 75+ay,1)
 q(143+cx, 61+cy, 149+cx, 53+cy,
   143+bx, 79+by, 154+bx, 85+by,6)
end

function arm2(ax,ay,bx,by,cx,cy,dx,dy)
 q(187+ax, 62+ay, 191+ax, 62+ay,
   185+ax, 64+ay, 191+ax, 65+ay,3)
 q(185+ax, 64+ay, 191+ax, 65+ay,
   184+ax, 66+ay, 190+ax, 68+ay,3)
 q(184+ax, 66+ay, 190+ax, 68+ay,
   183+ax, 69+ay, 187+ax, 71+ay,3)
 q(183+ax, 69+ay, 187+ax, 71+ay,
   183+bx, 78+by, 186+bx, 78+by,3)
 q(183+bx, 78+by, 186+bx, 78+by,
   188+cx, 95+cy, 190+cx, 96+cy,3)
   
 q(191+ax, 62+ay, 193+ax, 62+ay,
   191+ax, 65+ay, 195+ax, 65+ay,2)
 q(191+ax, 65+ay, 195+ax, 65+ay,
   190+ax, 68+ay, 196+ax, 67+ay,2)
 q(190+ax, 68+ay, 196+ax, 67+ay,
   187+ax, 71+ay, 196+ax, 70+ay,2)
 q(187+ax, 71+ay, 196+ax, 70+ay,
   186+bx, 78+by, 196+bx, 76+by,2)
 q(186+bx, 78+by, 196+bx, 76+by,
   190+cx, 96+cy, 198+cx, 96+cy,2)

 q(188+cx, 95+cy, 190+cx, 96+cy,
   189+cx,100+cy, 191+cx, 98+cy,6)
 q(190+cx, 96+cy, 198+cx, 96+cy,
   191+cx, 98+cy, 198+cx, 97+cy,2)
 
 q(191+cx, 98+cy, 198+cx, 97+cy,
   193+dx,123+dy, 200+dx,124+dy,6)
 q(189+cx,100+cy, 191+cx, 98+cy,
   188+cx,110+cy, 193+dx,123+dy,6)
 
 q(193+dx,123+dy, 200+dx,124+dy,
   192+dx,128+dy, 196+dx,129+dy,6)
 q(192+dx,128+dy, 196+dx,129+dy,
   192+dx,131+dy, 195+dx,133+dy,6)
 q(199+dx,124+dy, 203+dx,126+dy,
   196+dx,129+dy, 206+dx,127+dy,6)
 q(196+dx,129+dy, 206+dx,127+dy,
   195+dx,133+dy, 206+dx,133+dy,6)
 q(206+dx,128+dy, 216+dx,130+dy,
   206+dx,133+dy, 216+dx,133+dy,6)
 
 l(199+dx,128+dy, 200+dx,129+dy,5)
 l(200+dx,129+dy, 207+dx,131+dy,5)
 l(207+dx,131+dy, 208+dx,132+dy,5)
end

function torso(ax,ay,bx,by,cx,cy,dx,dy,ex,ey)
 q(178+ex, 51+ey, 182+ex, 52+ey,
   179+ex, 57+ey, 182+ex, 57+ey,13)
 q(182+ex, 52+ey, 187+ex, 52+ey,
   182+ex, 58+ey, 188+ex, 58+ey,2)
 q(187+ex, 52+ey, 193+ex, 52+ey,
   188+ex, 58+ey, 193+ex, 58+ey,1)
   
 q(179+ex, 57+ey, 182+ex, 57+ey,
   176+dx, 60+dy, 178+dx, 63+dy,13)
 q(176+dx, 60+dy, 178+dx, 63+dy,
   169+dx, 62+dy, 176+dx, 66+dy,12)
 q(169+dx, 62+dy, 176+dx, 66+dy,
   164+dx, 66+dy, 172+dx, 70+dy,12)
 q(164+dx, 66+dy, 172+dx, 70+dy,
   160+dx, 72+dy, 165+dx, 76+dy,12)
 q(160+dx, 72+dy, 165+dx, 76+dy,
   157+bx, 80+by, 162+bx, 83+by,12)
 q(157+bx, 80+by, 162+bx, 83+by,
   156+bx, 87+by, 159+bx, 89+by,12)
 q(156+bx, 87+by, 159+bx, 89+by,
   154+bx, 92+by, 157+bx, 94+by,12)
 q(154+bx, 92+by, 157+bx, 94+by,
   151+bx, 96+by, 154+bx, 98+by,12)
 q(151+bx, 96+by, 154+bx, 98+by,
   145+ax, 98+ay, 148+ax,101+ay,12)

 q(182+ex, 57+ey, 183+dx, 60+dy,
   178+dx, 63+dy, 184+dx, 63+dy,3)
 q(178+dx, 63+dy, 184+dx, 63+dy,
   176+dx, 66+dy, 183+dx, 67+dy,3)
 q(176+dx, 66+dy, 183+dx, 67+dy,
   172+dx, 70+dy, 179+dx, 72+dy,3)
 q(172+dx, 70+dy, 179+dx, 72+dy,
   165+dx, 76+dy, 171+dx, 79+dy,3)
 q(165+dx, 76+dy, 171+dx, 79+dy,
   162+bx, 83+by, 167+bx, 84+by,3)
 q(162+bx, 83+by, 167+bx, 84+by,
   159+bx, 89+by, 164+bx, 90+by,3)
 q(159+bx, 89+by, 164+bx, 90+by,
   157+bx, 94+by, 161+bx, 97+by,3)
 q(157+bx, 94+by, 161+bx, 97+by,
   154+bx, 98+by, 157+bx,100+by,3)
 q(154+bx, 98+by, 157+bx,100+by,
   148+ax,101+ay, 152+ax,105+ay,3)
 q(157+bx,100+by, 161+bx, 97+by,
   152+ax,105+ay, 154+ax,107+ay,3)
 
 q(182+ex, 57+ex, 188+ex, 57+ex,
   183+bx, 60+bx, 188+bx, 61+by,2)
 q(183+bx, 60+bx, 188+bx, 61+by,
   184+bx, 63+by, 188+bx, 64+by,2)
 q(184+bx, 63+by, 188+bx, 64+by,
   183+bx, 67+by, 187+bx, 69+by,2)
 q(183+bx, 67+by, 187+bx, 69+by,
   179+bx, 72+by, 185+bx, 75+by,2)
 q(179+bx, 72+by, 185+bx, 75+by,
   171+bx, 79+by, 176+bx, 87+by,2)
 q(171+bx, 79+by, 176+bx, 87+by,
   167+bx, 84+by, 172+bx, 94+by,2)
 q(167+bx, 84+by, 172+bx, 94+by,
   164+bx, 90+by, 168+bx,100+by,2)
 q(164+bx, 90+by, 168+bx,100+by,
   161+bx, 97+by, 165+bx,107+by,2)
 q(161+bx, 97+by, 165+bx,107+by,
   161+bx,106+by, 162+bx,107+by,2)
 q(161+bx, 97+by, 161+bx,106+by,
   154+ax,107+ay, 156+ax,111+ay,2)
 q(161+bx,106+by, 162+bx,107+by,
   156+ax,111+ay, 160+cx,113+cy,2)
 q(162+bx,107+by, 165+bx,107+by,
   160+cx,113+cy, 164+cx,115+cy,2)
   
 q(188+ex, 57+ey, 193+ex, 57+ey,
   188+bx, 61+by, 191+bx, 61+by,1)
 q(188+bx, 61+by, 191+bx, 61+by,
   188+bx, 64+by, 192+bx, 64+by,1)
 q(188+bx, 64+by, 192+bx, 64+by,
   187+bx, 69+by, 194+bx, 68+by,1)
 q(187+bx, 69+by, 194+bx, 68+by,
   184+bx, 75+by, 191+bx, 80+by,1)
 q(184+bx, 75+by, 191+bx, 80+by,
   176+bx, 87+by, 182+bx, 91+by,1)
 q(176+bx, 87+by, 182+bx, 91+by,
   172+bx, 94+by, 176+bx, 97+by,1)
 q(172+bx, 94+by, 176+bx, 97+by,
   168+bx,100+by, 171+bx,102+by,1)
 q(168+bx,100+by, 171+bx,102+by,
   165+bx,107+by, 167+bx,109+by,1)
 q(165+bx,107+by, 167+bx,109+by,
   164+cx,115+cy, 166+cx,116+cy,1)
end

function TIC()
 t=time()/60
 vbank(1)
 cls(7)
 leg1(-6,0)
-- leg1(0,0)
 arm1(sin(t/6),0,
      -2*clmp(3*sin(t/18),0,3),
      -2*abs(sin(t/6)+clmp(-36*sin(t/18),-15,0))/2,
      2*sin(t/6)+clmp(8*sin(t/18),0,6),
      sin(t/6)+clmp(-36*sin(t/18),-11,0))
 torso(sin(t/6),sin(t/6),
      sin(t/6),0,
      0,0,
      sin(t/6),0,
      2*sin(t/6),sin(t/6))
 fantahand(144+2*sin(t/6)+clmp(8*sin(t/18),0,6),
           61+sin(t/6)+clmp(-22*sin(t/18),-11,0),
           clmp(pi/2*sin(t/18),0,pi/4))
 head(2*sin(t/6),sin(t/6),
      0.5*sin(t/6)+1.5*sin(t/12),0.25*sin(t/6)+0.5*sin(t/12))
 arm2(sin(t/6),0,
      sin(t/6),sin(t/6),
      2*sin(t/6),0,
      0,0)
 leg2(0,0,
      sin(t/6),sin(t/6),
      sin(t/6),sin(t/6),
      0,0,
      0,0)
 vbank(0) 
	cls(9)
	rect(0,120,240,33,4)
 elli(128,132,90,2,3)
 elli(190,132,30,2,3)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

