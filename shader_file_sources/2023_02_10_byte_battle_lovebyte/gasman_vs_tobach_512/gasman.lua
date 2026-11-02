-- enjoy the party!
m=math
s=m.sin
c=m.cos
function TIC()t=time()for y=0,136 do for x=0,240 do
a=8*s(t/5000)S=10+5*s(t/1000)X=(x*c(a)+y*s(a))/S
Y=(y*c(a)-x*s(a))/S
pix(x,y,(X//1~Y//1)+t/100)
end end
b=85-fft(1)*10
m={"it looks like","you're writing","a rotozoomer.","want some help?"}
rect(100,8,90,42,4)tri(180,50,190,60,190,50,4)
for i=0,3 do
ellib(200+i,90,10,30,14)ellib(200+i,80,10,20,14)elli(190+15*(i//2),b,5,2,12)elli(190+15*(i//2),b,2,2,0)print(m[i+1],102+2*c(i+t/120),12+i*10+2*s(i+t/100),i)
end
end
