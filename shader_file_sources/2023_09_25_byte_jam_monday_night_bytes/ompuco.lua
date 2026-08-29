function TIC()t=time()/512

hresx = 120
hresy = 68

cls()

s = math.sin
c = math.cos

yoff=0

ff = 0

for i=0,128 do

f = 8

px1 = s(i/f+t)
py1 = c(i/f+t)

px2 = s((i+1)/f+t)
py2 = c((i+1)/f+t)


xoff =  c(i/40 + t-1)*32*(1+ff*.1)


px1 = px1 * 32 + hresx + xoff
py1 = py1 * 32 + hresy + yoff

ff =  fft((1+(i)/3.0+t)%10)*24
yoff =  s(i/40 + t-1)*32*(1+ff*.1)

yoff = yoff+ ff

px2 = px2 * 32 + hresx + xoff
py2 = py2 * 32 + hresy + yoff

j = (i/8+t*5) % 18 + 2

line(px1,py1,px2,py2,j)

print("HEHE")

end
end