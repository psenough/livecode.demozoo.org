sin=math.sin
cos=math.cos
pi=math.pi
sqrt=math.sqrt
m=0
function TIC()t=time()//100
cls(8)
for i=1,50 do
 x=(i*i*i*7+t)%240
 y=(i*i*13)%136
 if i%2==0 then
  circ(x,y,1,12)
 else
  pix(x,y,12)
 end
end

x=t%240
y=40
circ(x,y,33,12)

for i=1,7 do
a=i/10+sin(t/10)
line(175,32,300*cos(a),300*sin(a),math.random()*6+2)
end
rect(170,30,10,200,14)

ellib(120,50,30,5,13)
ellib(120,54,30,5,13)
for i=1,11 do
 a=2*pi/11*i
 x=120+cos(a)*30
 y=50+sin(a)*5
 rect(x,y-5,2,5,14)
 circ(x+1,y-5-t%5,sin(t)*3+1,4)
end

for i=1,15 do
 x=(i*i*i*15)%240
 y=50+(i*20)%15+sin(t+x)*5
 w=15+i*i*17%20
 h=30+i*i*30%20
 tri(x,y,x-w,y+h,x+w,y+h,2+i%5)
 tri(x,y+h-10,x-6,y+h,x+6,y+h,0)
end


-- how to lua?
-- oh
darker={}
darker[15]=0
darker[14]=15
darker[13]=14
darker[12]=13
darker[8]=0
darker[5]=4
darker[4]=3
darker[0]=0
darker[2]=1
darker[3]=2
darker[1]=0
darker[6]=7
darker[7]=15
h=90
for x=0,239 do
for y=h,135 do
c=pix(x+sin(y+t)*3,h-(y-h))
pix(x,y,darker[c])
end
end

print("MCH2022",40+3*cos(t),100+3*sin(t),0,false,4)
print("MCH2022",40,100,1+t%15,false,4)

m=mouse() -- piep!
m=m/240*150
print(m)
end
