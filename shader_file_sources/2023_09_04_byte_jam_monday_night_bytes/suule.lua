-- Hey! First time here! I hope
-- it will be a worthwhile one

flr=math.floor
sin=math.sin
cos=math.cos
pi=math.pi
rand=math.random

strx={}
stry={}
strz={}

-- Let's make some stars
function crtstrfld()
 for i=0,360 do
  strx[i]=flr(rand()*240)-120
  stry[i]=flr(rand()*136)-68
  strz[i]=flr(rand()*400)-100
 end
end


function strclr(a)
 if a < 150 then return 14 end
 if a < 300 then return 14 end
 if a < 400 then return 13 end
 return 12
end 
--360 stars, dst =600

function drwstrfld()
 for i=0,360 do
  local prs=600/(600-strz[i])
  local x=120-strx[i]*prs
  local y=68-stry[i]*prs
  pix(x,y,strclr(strz[i]))  
  strz[i]=strz[i]+4
  if strz[i]>600 then strz[i]=0 end

 end
end 

function quad(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x3,y3,x4,y4,x2,y2,col)
end 

function drwcockpit()
 -- Lower
 quad(0,104, 62,91, 0,136, 80,136,14)
 quad(177,91,240,104,159,136,240,136,14)
 quad(62,91,177,91,80,136,159,136,13)
 -- Upper
 quad(70,44, 72,44, 59,92, 61,92, 14)
 quad(20,30, 23,30, -2,103, 1,103, 13)
 quad(30,12, 75,35, 22,29, 72,44, 14)
 quad(0, 2, 30,12, 0,30, 22,29 ,13)
 quad(169,44, 167,44, 180,92, 178,92, 14)
 quad(219,30,216,30,241,103,238,103, 13)
 quad(209,12,164,35,217,29,167,44,14)
 quad(240,2, 209,12, 240,30, 217,29, 13)
 -- And now the bars
 quad(72,34,75,36,167,34,164,36,14)
 quad(24,10,32,13,215,10,207,13,13)
 quad(87,36,152,36,89,44,150,44,14)
end
 
-- Phew... now for the fun parts!

function drwHUD(t_mod)
 for i=0,9 do
  line(22+i,110+i*2,25+i,110+i*2,7)
  line(26+i,109+i*2,29+i,109+i*2,7)
  line(31+i,108+i*2,34+i,108+i*2,7)
  line(35+i,107+i*2,38+i,107+i*2,7)
  line(40+i,106+i*2,43+i,106+i*2,7)
  line(44+i,105+i*2,47+i,105+i*2,7)
 end
 local max=flr(20*fft(4))
 for c=0,max do
  if c>9 then i=0 else i=9-c end
  line(22+i,110+i*2,25+i,110+i*2,6)
  line(26+i,109+i*2,29+i,109+i*2,6)
 end
 local max=flr(20*fft(8))
 for c=0,max do
  if c>9 then i=0 else i=9-c end
  line(31+i,108+i*2,34+i,108+i*2,6)
  line(35+i,107+i*2,38+i,107+i*2,6)
 end
 local max=flr(20*fft(12))
 for c=0,max do
  if c>9 then i=0 else i=9-c end
  line(40+i,106+i*2,43+i,106+i*2,6)
  line(44+i,105+i*2,47+i,105+i*2,6)
 end
 for i=0,4 do
  elli(18+i*2,112+i*4,2,1,2)
 end 
 local max=flr(10*fft(1))
 for c=0,max do
  if c>4 then i=0 else i=4-c end
  elli(18+i*2,112+i*4,2,1,3)
 end 
 -- Radar 1 
 circ(85,106,8,0)
 line(85,106,85+flr(7*sin(t_mod/50*pi/2)),106+flr(7*cos(t_mod/50*pi/2)),4) 
 -- Radar 2 
 circ(155,106,8,0)
 circb(155,106,(t_mod/2)%8,4)
 circ(105,102,3,0)
 circ(135,102,3,0)
 circ(105,125,3,0)
 circ(135,125,3,0)
 rect(101,102,38,24,0)
 rect(105,98,30,32,0)
 rect(91,35,57,8,0)
print('NORDLICHT 2023',92,37,3, true,1,true)   
end  
 
function dsplytext(t_mod)
 local adj_t=t_mod/2%300
 if (adj_t>0) and (adj_t < 20) then print('GREETZ TO',102,108,6, true,1,true)end
 if (adj_t>19) and (adj_t < 40) then print('  ALIA  ',105,108,6, true,1,true)end
 if (adj_t>39) and (adj_t < 60) then print('  NICO  ',105,108,6, true,1,true)end
 if (adj_t>59) and (adj_t < 80) then print(' ALDROID',102,108,6, true,1,true)end
 if (adj_t>79) and (adj_t < 100) then print(' VIOLET ',105,108,6, true,1,true)end
 if (adj_t>99) and (adj_t < 120) then print('LYNNDRUMM',102,108,6, true,1,true)end
 if (adj_t>139) and (adj_t < 160) then print('SEE YA AT',102,108,6, true,1,true)end
 if (adj_t>159) and (adj_t < 180) then print('NORDLICHT',102,108,6, true,1,true)end
 if (adj_t>179) and (adj_t < 200) then print('  2023!! ',102,108,6, true,1,true)end 
 if (adj_t>239) and (adj_t < 260) then print(' HAVE A ',105,108,6, true,1,true)end
 if (adj_t>259) and (adj_t < 280) then print('GREAT DAY',102,108,6, true,1,true)end  
end
 
 
function TIC()
 t=time()/30
 if t<1 then crtstrfld() end
 cls(0)
 drwstrfld()
 drwcockpit()
 drwHUD(t)
 dsplytext(t)
end
