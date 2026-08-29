# script:  python
from math import *
from random import random as rand

t=0
width=240
height=136

def pR(x,y,a):
 x2=x*cos(a)+y*sin(a)
 y2=y*cos(a)-x*sin(a)
 return x2,y2

class A:
 def __init__(self,i=0):
  self.x=int(rand()*width)
  self.y=int(rand()*height)
  self.r=int(rand()*5)+8
  self.i=i
  self.v=2.0,0.0
 def paint(self):
  r=int(self.r+sin(t*0.1+self.i)*4)
  circ(self.x,self.y,r,0)
  for i in range(8):
   a=(i/8.0)*pi*2.0+t*0.05
   dx=int(cos(a)*r)
   dy=int(sin(a)*r)
   circ(self.x+dx,self.y+dy,
    3+int(sin(t*0.3+i*2)*2),
    3-(i%2)*2)
 def tick(self):
  self.x+=int(self.v[0])
  self.y+=int(self.v[1])
  self.v=pR(self.v[0],self.v[1],0.001*self.i)
  if self.x<0:self.x+=width
  if self.y<0:self.y+=height
  self.x%=width
  self.y%=height
  global agents
  c=None
  cd=None
  for a in agents:
   if a==self: continue
   dx=a.x-self.x
   dy=a.y-self.y
   d=dx*dx+dy*dy
   if cd is None or d<cd:
    cd=d
    c=a
  if c is not None:
   dx=c.x-self.x
   dy=c.y-self.y
   self.x-=int(dx*0.01)
   self.y-=int(dy*0.01)*4
   
agents = [A(i) for i in range(10)]

cd=[13]*(width*height)

def diff():
 global cd
 o=cd[:]
 for y in range(height):
  for x in range(width):
   s=0
   for dy in (-1,0,1):
    for dx in (-1,0,1):
     x2=(x+dx)%width
     y2=(y+dy)%height
     if x2<0:x2+=width
     if y2<0:y2+=height
     s+=o[x2+y2*width]
   cd[x+y*width]=s/9.0

def TIC():
 global t
 if t==0:
  cls(13)
 
 for y in range((t//4)%4,height,4):
  for x in range(t%4,width,4):
   dx=x-width*0.5
   dy=y-height*0.5
   f=sqrt(dx*dx+dy*dy)
   if f:
    f=1.0/f
   dx,dy=dy*f,-dx*f
   dx=int(dx*3)
   dy=int(dy*3)
   
   #dx=int(rand()*3)-1
   #dy=int(rand()*2)
   
   v=pix(x+dx,y+dy)
   #if t%4==0:
   if v<13:v+=1
   pix(x,y,v)
   #cd[x+y*width]=v
 
 #diff()
 #for y in range(height):
 # for x in range(width):
 #  pix(x,y,int(cd[x+y*width]))
    
 for a in agents:
  a.tick()
  a.paint()
 
 t+=1
 
 print("thank you for watching :)",64,64,t//2)
