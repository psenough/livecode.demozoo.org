-- twitch chat broke for me
-- all communication will go thru
-- comments. lol :3

function BDR(l)
 r=math.ceil((math.sin(l/(t/3))*4)+4)
 poke(0x03ff9,math.random(0,r))
end

function TIC()cls()t=time()/256

for i=1,64 do

 -- joke's on you i dont actually
 -- know any maths
 -- i'm just a cat lmao

 x=((math.cos((t/3)+(i*3))*96)+(240/2))
 y=((math.sin((t/8)+(i*4))*80)+(136/2))
 k=i*4
 aminal(x,y,k)
end

end

function OVR()
text()
end

function aminal(x,y,k)

-- draw an aminal
-- it is a very cute aminal ok
-- don't hurt it's feelings
-- or mine for that matter
-- i'm trying my bestest ;-;

elli(x,y,18,18,0)
elli(x-10,y-12,8,18,0)
elli(x+10,y-12,8,18,0)


elli(x,y,16,16,k)
elli(x-10,y-12,6,16,k)
elli(x+10,y-12,6,16,k)

elli(x-6,y-3,4,4,0)
elli(x+6,y-3,4,4,0)
elli(x-6,y-3,2,2,2)
elli(x+6,y-3,2,2,2)
end

function text()
txt="it all worked out"
txt2="in the end, didn't it?"
s=1
x=240-((string.len(txt)*(s*6)))
y=136-((s*7))

print(txt,x+1,(y+1)-(s*8),15,true,s)
print(txt,x,y -(s*8),12,true,s)

s=1
x=240-((string.len(txt2)*(s*6)))
y=136-((s*7))

print(txt2,x+1,y+1,15,true,s)
print(txt2,x,y,12,true,s)
end