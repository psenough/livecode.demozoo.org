SCX,SCY=240,136
M,T=math,table

function draw_octave(x0,y0,b0,sc)
  --rect(x0,y0,x0+12*sc,y0+5*sc,12)
  --rectb(x0,y0,x0+12*sc,y0+5*sc,15)
  
  local keys = {
    {0  , 1.5,  1.0, 0,  0},
    {1.5, 3.5,  1.0, 2,0},
    {3.5, 5.0,  1.0, 4,0},
    {5.0, 6.5,  1.0, 5,0},
    {6.5, 8.5,  1.0, 7,0},
    {8.5, 10.5, 1.0, 9,0},
    {10.5,12 ,  1.0, 11,0},
    
    {1.0, 2.0,  0.75, 1 ,1},
    {3.0, 4.0,  0.75, 3 ,1},
    {6.0, 7.0,  0.75, 6 ,1},
    {8.0, 9.0,  0.75, 8 ,1},
    {10.0, 11.0,  0.75, 10,1 },
    
  }
  local pmaps = {
    {12,2,3,4},
    {15,7,6,5},
  }
  for i,kdesc in pairs(keys) do
    local x1=kdesc[1] * sc
    local x2=kdesc[2] * sc
    local w = x2-x1
    local h =kdesc[3] * 5*sc
    local bucket = b0+kdesc[4]
    local bval = 5*vqt(bucket)
    
    if bval>1 then bval=1 end
    if bval<0 then bval=0 end
    local ix = 1+M.floor(4*bval)
    if ix<1 then ix=1 end
    if ix>4 then ix=4 end
    c=pmaps[kdesc[5]+1][ix]
  
    rect(x0+x1,y0,w,h,c)
    rectb(x0+x1,y0,w,h,15)
   
  end

end

function TIC()
  cls()
  for i=1,127 do
    pix(i*2,SCY*(1-vqt(i)),5)
  end

  for i=0,3 do
    draw_octave(12*5*i,5,i*12,5)
  end
  for i=0,3 do
    draw_octave(12*5*i,3*12,3*12+i*12,5)
  end
  for i=0,3 do
    draw_octave(12*5*i,6*12,6*12+i*12,5)
  end
  
  print("long keyboard is looooooooooong",32,100)
end

