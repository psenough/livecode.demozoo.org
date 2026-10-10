-- elloelloello das ist merlock :P
-- let's frakin do dis!!!

s=math.sin

function TIC()
t=time()/32
cls()
for y=0,136,2 do
for x=0,240,2 do
rect(x,y,2,2,y/24*4+x/8/2+t/32)
end
end
end

function OVR()
print("bebn d/v beb bleh buh",72+s(t/12/4)*32,62+s(2+t/8/4)*32,2,false,1)
print("MERLOCK SHOLMES WAS HEREEE YEHEH",65+s(t/24)*12,68+s(t/16)*12,12,false,1,true)
-- and one more thing...
print("papryka papryki papryke halapeno :)))",24,68,t/2)
end

function SCN(row)
poke(0x3ffa,s(row/8+t/32)*8-row%4)
poke(0x3fc7,s(row/2+t/2)*4)
poke(0x3fca,s(row/2+t/2)*4)
poke(0x3fc4,s(row/2+t/2)*4)
end