-- superogue here...
-- welcome everone! <3
T={
"   demos & intros",
"  streaming music",
"   tracked music",
"     alternative",
"      tiny intros",
"freestyle graphics",
"     ansi & ascii",
"   pixel graphics",
"       animation",
"     interactive"
}
t=1x=1y=1
function TIC()
f=.008+(fft(0)/39)
cls()z=119
for i=0,136,2 do
line(0,i,240,i,15+math.sin(i+t/9)*9%1.7)
end
for i=0,571,1 do 
x=math.sin(t+x*y+f)
y=math.sin(t*9+x+y+x)-math.sin(t+x+i)
circb(x*z*1.5+80,y*z+68,(y*y*z/39)*5+1,8+((t+i/19)%3))
circb(160-(x*z*1.5),y*z+68,(y*y*z/39)*5+1,8+((t+i/19)%3))
end
print("get your ass to",80,33,0)
print("get your ass to",79,32,10)
print("evoke 2023",34,59,0,2,3)
print("evoke 2023",32,57,12+(t*7%4),2,3)
print(T[1+(t//.3%10)],73,96,0)
print(T[1+(t//.3%10)],72,95,10)
print("www.evoke.eu",98,129,0,1,1,1)
print("www.evoke.eu",98,128,12,1,1,1)
print("5711",225,3,0,1,1,1,1)
print("5711",224,2,14,1,1,1,1)
print("5711",2,3,0,1,1,1,1)
print("5711",1,2,14,1,1,1,1)
print("5711",225,128,0,1,1,1,1)
print("5711",224,129,14,1,1,1,1)
print("5711",2,128,0,1,1,1,1)
print("5711",1,129,14,1,1,1,1)
t=t+f
end