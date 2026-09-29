-- greetings from sunny Seattle~
function TIC()t=time()/512
cls()

--quick plasma barz?

for i=0,168 do
k=(math.sin((t/5)+(i/32))*3+1)
line(0,i,240,i,k)
end


text="merry christmas"
x=(math.sin(t)*32)+32
y=(math.cos(t/3)*48)+60
print(text,x,y,0,true,2)
print(text,x-1,y-1,12,true,2)


x=24
y=0
k=3

for i=0,32 do

    cos=(math.cos(t/8)*2)+4

    y=(math.sin(t+i+cos)*80)+70
    x=(math.cos(t+i*4)*32)+i*8
 pumpkin(k,x,y,i)
 
 if k<5 then k=k+1 else k=3 end
end

end


function pumpkin(k,x,y,i)
--shadow? outline? thing??
elli(x,y-8,2,13,0)
elli(x,y,11,13,0)
elli(x-8,y,9,13,0)
elli(x+8,y,9,13,0)
elli(x-14,y,9,13,0)
elli(x+14,y,9,13,0)
--body
elli(x,y-8,1,12,6)
elli(x,y,10,12,k)
elli(x-8,y,8,12,k)
elli(x+8,y,8,12,k)
elli(x-14,y,8,12,k)
elli(x+14,y,8,12,k)

--line stuff
ellib(x,y-8,1,12,0)
ellib(x,y,10,12,0)
ellib(x-8,y,8,12,0)
ellib(x+8,y,8,12,0)
ellib(x-14,y,8,12,0)
ellib(x+14,y,8,12,0)

--eyes

--give them some movement
a=(math.cos((t)/2+i)*1)
b=(math.sin((t)+i)*1)

circ(x-10,y-2,4,0)
circ(x+10,y-2,4,0)
circ(x-10+a,y-2+b,2,12)
circ(x+10+b,y-2+a,2,12)
circ(x-10+b,y-2+a,1,0)
circ(x+10+a,y-2+b,1,0)
--mouth
elli(x,y+5,8,2,0)
rect(x-4,y+1+2,9,2,k)
end