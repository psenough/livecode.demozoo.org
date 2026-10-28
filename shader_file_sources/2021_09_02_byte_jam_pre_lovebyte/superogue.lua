------------------------------------
-- Step into the ring with us as we 
-- go all out with an ultimate 
-- Byte Battle Ladder Tournament
-- Fantasy Console Competitions
-- Byte jams, Music Sets and more...
------------------------------------
-- September 25th/26th, 2021
-- http://battle.lovebyte.party
T={"         Lovebyte Battlegrounds","Byte Battle & Fantasy Console Demoparty","          September 25-26, 2021","      http://battle.lovebyte.party"}
function TIC()
cls()t=time()/99W=t//8
s=math.sin(t/9)c=math.cos(t/9)S=math.sin
--for i=0,47 do poke(16320+i,S(i/15)*192)end
for v=-64,80,4.1 do for u=-96,96,4.1 do
Z=(u*u+v*v)/4999+1
x=u/Z
y=v/Z
a=math.atan(x,y)*39
z=a/Z*S(t/49)*8
X=x*c-y*s
Y=x*s+y*c
circ(Y+120+Z*z*S(t/99),X*2+72,Y*Z/16+2,(x//8~y//8)+t)
end end 
print(T[1+(W//4&3)],4,64,t,1,1)
end