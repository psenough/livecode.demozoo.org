min=math.min
max=math.max
log=math.log
abs=math.abs

f={}
for i=0,23 do f[i]=0 end
b={x=120,y=80,vx=0,vy=-1,s=1,c=12,r=10}

t=0
function TIC()
  t=t+1
  cls()
  -- fft
  for i=0,23 do
    if t>30 then
      f[i] = min(fft(i*42,i*42+41)*log(i+2)*12, 60)
    end
    line(i*10, 135-f[i], i*10+9, 135-f[i], i%13+2)
  end
  -- ball
  b.x = b.x+b.vx*b.s
  b.y = b.y+b.vy*b.s
  circ(b.x, 136-b.y, b.r, (b.x//10)%13+2)
  circ(b.x+4, 136-b.y-4, 1, 12)
  -- bounce
  fc = b.x//10
  fl = fc-1
  fr = fc+1
  hit = max(f[fl], f[fc], f[fr])
  if b.y-b.r < hit then
    b.y = min(b.y+hit+10, 100)
    if f[fl]>f[fc] and f[fl]>f[fr] then
      b.x = b.x+10
    elseif f[fr]>f[fc] and f[fr]>f[fl] then
      b.x = b.x-10
    end
  end
  -- reset
  if b.x>=230 or b.x<=10 then b.x=120 end
  if b.y<=0 then b.y=68 end
end
