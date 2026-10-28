function bg(x1,y1,x2,y2,dx,dy,o,fftv)

  for y=y1,y2 do
   for x=x1,x2 do
    pix(x,y,o+(dx*x+dy*y+t+fftv))
   end
  end
end

function fft_vu_text()

text="Welcome to my first jam ever, greetz"

  for i=1, #text do
   c = text:sub(i,i)
      x = i*6+5
      fftv = fft(i*6)*i
      y = fftv*20+10
      print(c,x,y)
  end
end

function fft_circle(x,y,from,to,scale)
  
  fftv = 0
  for i=from,to do
      fftv = fftv + fft(i)*i
  end
  
  r = fftv*scale
  
  minR = 7
  if r<minR then
      r = minR
  end
  
  distEyeX = .4*r
  distEyeY = .4*r
  noseSizeX = .2*r
  noseSizeY = .6*r
  distMouthY = 1.2*r
  sizeMouthX = 1*r
  sizeMouthY = .2*r
  
  circ(x,y,r,0)
  circ(x+distEyeX,y-distEyeY,r*.3,3)
  circ(x-distEyeX,y-distEyeY,r*.3,3)
  circ(x+distEyeX,y-distEyeY,r*.1,0)
  circ(x-distEyeX,y-distEyeY,r*.1,0)
  rect(x-noseSizeX//2,y-noseSizeY//2,noseSizeX,noseSizeY,3)
  rect(x-sizeMouthX//2,y+distMouthY//2,sizeMouthX,sizeMouthY,3)
  circ(x+.9*r,y-.8*r,.3*r,0)
  circ(x-.9*r,y-.8*r,.3*r,0)
  circ(x+.9*r,y-.8*r,.1*r,13)
  circ(x-.9*r,y-.8*r,.1*r,13)    
end

function TIC()

  t=time()//32
  fftvalue=0
   
  bStart=0
  bStop=4

  for i=bStart,bStop do
      fftvalue = fftvalue + fft(i)*i
  end

  fftvalue = fftvalue*4
  cls()
  bg(0,0,120,68,1,1,0,fftvalue)
  bg(121,0,240,68,-1,1,0,fftvalue)
  bg(0,68,120,136,1,-1,8,fftvalue)
  bg(121,69,240,136,-1,-1,-8,fftvalue)
  fft_vu_text(fftvalue)
  fft_circle(40,68,0,2,10)
  fft_circle(120,110,30,60,.3)
  fft_circle(200,68,80,105,.2)
  
end


-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>