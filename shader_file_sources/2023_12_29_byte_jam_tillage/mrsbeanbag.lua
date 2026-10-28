-- Mrs Beanbag
q=0
e=0
t=0
function fft(x)
return math.random()/x
end
function TIC()
c=(time()//1000)*73
for i=-40,239 do
k=(i//20)&1
line(i,0,i+40,134,k~=0 and 12 or c)
end
elli(100,50,20,30,0)
elli(140,50,20,30,0)
elli(100,50,15,25,12)
elli(140,50,15,25,12)
e=e*.9+fft(1)
circ(105,60-e,8,0)
circ(135,60-e,8,0)
q=q*.8+fft(20)*.2
for i=80,160 do
 y=1-((i-120)/40)^2
 y1=85+y*30*(1-q*16)
 y2=90+y*30
 line(i,y1,i,y2,0)
 if y1+5 <= y2-5 then
  line(i,y1+5,i,y2-5,2)
 end
end
s=114+math.sin(time()/320)*10
rect(104,s,32,6,13)
rectb(104,s,32,6,0)
rect(100,s+5,40,80,4)
rectb(100,s+5,40,80,0)
for i=-1,1 do
for j=-1,1 do
print("T",108+i,12+j+s,1,1,4)
end
end
print("T",108,12+s,3,1,4)
n=.7t=t+1
cx=math.sin(t*.1)*8
cy=math.cos(t*.1)*8
for i=1,729 do
m=n
n=n*73%136-68
w=(i-t)/99%1
circ((m+cx)/w+120,(n+cy)/w+68,2,c-4*w)
end
end