SCX=240
SCY=135
M,T=math,table
TAU=2.0*M.pi
FSCALE=100.0

STREAKS={}
STREAKLEN=35
NEXTTIME=0
MAXSTREAKS=30
FFTLEVEL=0
FFTCUT=0.3
SCALESIDE=true

function clamp(x,xmin,xmax)
  if (x>xmax) then x=xmax end
  if (x<xmin) then x=xmin end
  return x
end

function dofft()
  local yprev=SCY-1
  for x=0,SCX do
    y=SCY-1-(fft(x)*FSCALE)
    --line(x-1,yprev,x,y,15)
    yprev=y
  end
  
  NFFT=10
  sum=0.0
  for i=0,NFFT-1 do
   sum=sum+fft(i)
  end
  sum=sum/NFFT
  FFTLEVEL=clamp(sum*1.5,0.0,1.0)
  y=SCY*(1-FFTLEVEL)
  --line(0,y,SCX-1,y,15)
end

function gettime()
  return time()/1000.0
end

function make_streak()
  
  local s = {
    x=M.random()*SCX,
    y=M.floor(M.random()*10)-50,
    doffset=M.random(4),
    state={},
    active=1,
    t0=gettime(),
    speed=5+M.random()*20,
    side=(M.random()>0.2),
  }
  
  for i=1,STREAKLEN do
    s.state[i]=0.0
  end
  NEXTTIME=gettime() + M.random()*0.2
  T.insert(STREAKS,s)
  
end



function do_palette()
  for i=0,8 do
    adr = 0x3fc0 + 3*i
    x=M.floor(i*255/8)
    
    poke(adr,0)
    poke(adr+1,x)
    poke(adr+2,0)
  end    
  for i=9,12 do
    adr = 0x3fc0 + 3*i
    x=M.floor((i-8)*255/4)
    
    poke(adr,x)
    poke(adr+1,255)
    poke(adr+2,x)
  end 
  for i=13,15 do
    adr = 0x3fc0 + 3*i
    x=M.floor((i-13)*255/2)
    
    poke(adr,255-x)
    poke(adr+1,0)
    poke(adr+2,x)
  end 

    i=15  
    x=M.floor(255*M.cos(gettime()*TAU))
    adr = 0x3fc0 + 3*i
   
    
    poke(adr,x)
    poke(adr+1,0)
    poke(adr+2,255-x)
  

end

function draw_streaks()
  local donks = {"D","O","N","K"}
  
  for i,s in pairs(STREAKS) do
    local x=s.x
    local y=s.y
    local state=s.state
    
    for i=1,#state do
      local scale=1.0
      if (FFTLEVEL>FFTCUT) and (s.side) then
        scale=2.0
      end
      local val=clamp(state[i]*scale,0,1)
      
      if i==s.active then
        c=12
      else
        c=M.floor(val*12)
      end
      
      local ix=(i+s.doffset-1)%(#donks)+1
      print(donks[ix],x,y,c)
      y=y+6
    end
  end
end

function update_streaks()
  speedup=1.0
  
  if (FFTLEVEL>FFTCUT) then
  speedup = 1.5
  end
  DECAY=0.01
  dfactor = 1.0-DECAY
  
  newstreaks={}
  
  for i,s in pairs(STREAKS) do
    alive=false
    
    elapsed = gettime()-s.t0
    s.active=1+M.floor(elapsed*s.speed*speedup)
    complete=false
    
    if (s.active>=STREAKLEN) then
      complete=true
    end
    
    for j=1,#s.state do
      s.state[j]=s.state[j]*dfactor
      
      if (complete) then
        if s.state[j]>0.1 then
          alive=true
        end
      else
        alive=true
      end
      if j==s.active then
        s.state[j]=1.0
      end
    end -- each state
    
    if alive then
      if (M.random()<0.1*speedup) then
        s.doffset=s.doffset+1
      end
      
      if (M.random()<0.1*speedup) then
      
        s.y=s.y+1
      end
      T.insert(newstreaks,s)
    end
  end -- each streak
  
  STREAKS=newstreaks
  
  if (gettime()>NEXTTIME) then
    if ((#STREAKS)<MAXSTREAKS) then
      make_streak()
    end
  end
end

function BOOT()
  do_palette()
  for i=1,5 do
  make_streak()
  end
end


function TIC()
  cls(0)
  if (FFTLEVEL>FFTCUT) then
  --  cls(2)
  end
 
  dofft()
  do_palette()
  update_streaks()
  draw_streaks()

  s=" "..FFTLEVEL
  print("DONK DONK NEO...",80-1,SCY/2-1,0)
  print("DONK DONK NEO...",80+1,SCY/2+1,0)

  print("DONK DONK NEO...",80,SCY/2,15)

  --print(s,0,0,15)
end

