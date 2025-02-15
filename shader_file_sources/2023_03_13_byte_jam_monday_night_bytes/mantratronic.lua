-- mantratronic here
-- gonna try some rubber         ^
-- greets to evilpaul jtruk and tobach
-- +reality and ash for the HARDCORE

m=math
pi=m.pi

w=12
h=94
lines={}
drawlines={}
numframes=120
frames={}
fftt={}

-- and heres something i prepared earlier
quips={"makes it possible",
"wears clogs",
"likes amiga",
"looks good in stripes",
"put a donk on it",
"pixels naked",
"offlines outlines",
"knocked out the power",
"hates > 160bpm",
"gets locked out of his own party",
"made the battles bangin",
"can combo maali and okkie",
"hates on stnicc animation ports",
"gets 400 copyright strikes in an hour",
"day bacons",
"lives in a windmill",
"drives sceners to airports at 2am",
"should be on livecode.demozoo.org",
"provides official fanta merchandise",
"needs to return to finland",
"made a demo about it",
"has scenecoins",
"can haka to mellow"
}


function BOOT()
 for y=1,h do
  ln={}
  bend= 1.5*w*m.exp((y/h)^2)--+w/5
  
  local k={cx=-bend,cy=y+(136-h)/2,r=-w/2}
  local l={cx=0,cy=y+(136-h)/2,r=-w/2}
  local o={cx=bend,cy=y+(136-h)/2,r=-w/2}
  table.insert(lines,k)
  table.insert(lines,l)
  table.insert(lines,o)
 end
 
 for j=1,numframes do
 drawlines={}
 a=j/numframes *2*pi
 for i=1,#lines do
  ln=lines[i]
  cx=ln.cx
  cy=ln.cy
  x=ln.r
  
  a1=m.sin(a)
  a2=m.sin(a+pi/2)
  a3=m.sin(a+pi)
  a4=m.sin(a+pi/2*3)
  
  ay=cx*m.sin(-a)
  
  x1=x*a1+ay
  x2=x*a2+ay
  x3=x*a3+ay
  x4=x*a4+ay
  
  if (x1<x2) then
   table.insert(drawlines,{x1,cy,x2,cy,4})
  end
  if (x2<x3) then
   table.insert(drawlines,{x2,cy,x3,cy,10})
  end
  if (x3<x4) then
   table.insert(drawlines,{x3,cy,x4,cy,6})
  end
  if (x4<x1) then
   table.insert(drawlines,{x4,cy,x1,cy,14})
  end
 end
 frames[j]=drawlines
 end

 for f=0,25 do
  fftt[f]=0
 end 
end

function BDR(l)
vbank(0)
ftt=fftt[2]/10
grader=m.sin(ftt*11/5+l/30)+1
gradeg=m.sin(ftt*11/3+l/30)+1
gradeb=m.sin(ftt*11/2+l/30)+1
for i=0,15 do
poke(0x3fc0+i*3,  m.max(0,m.min(255,i*16*(grader))))
poke(0x3fc0+i*3+1,m.max(0,m.min(255,i*16*(gradeg))))
poke(0x3fc0+i*3+2,m.max(0,m.min(255,i*16*(gradeb))))
end
end


tt=0
function TIC()t=time()//32
 cls(3)

 tt=1+tt

 for f=0,25 do
  for i=0,9 do
   fftt[f]=fftt[f]+fft(f*10 + i)
  end
 end

 bnc=m.sin(fft(1))*10
 for y=1,h do
  twist=numframes*(1+m.cos(t/10+.5*m.cos(fftt[0]/20)*y/50))/2
  dl=frames[twist//1%numframes+1]
  for i=1,#dl do
   ln=dl[i]
   if ln[2] == y then  
    line(72+ln[1],ln[2]+12+bnc,72+ln[3],ln[4]+12+bnc,ln[5])
   end
  end
 end
 print("H",0,50+bnc,15,true,8)
 print("V C",105,50+bnc,15,true,8)
 circ(173,69+bnc,20,15)
 circ(182,62+bnc,4,3)
 circ(164,62+bnc,4,3)
 for i=-10,10 do
  circ(173+10*m.sin(i/10),75+6*m.cos(i/10)+bnc,1,3)
 end
 print("only",0,30+bnc,15,true,1)
 str=quips[t//100%#quips+1]
 len=print(str,0,-10)
 print(str,239-len,108+bnc)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

