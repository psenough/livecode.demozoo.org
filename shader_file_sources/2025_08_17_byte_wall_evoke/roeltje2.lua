W,H=240,136
W2,H2=120,68
sin,cos=math.sin,math.cos
rnd=math.random

stars={}
for i=0,50 do
 stars[i]={x=rnd(0,W),y=rnd(0,H2)}
end

function TIC()
 cls() 
 t=time()/1000
 
 for i=1,#stars do
  s=stars[i]
  s.x=s.x-.13
  s.x=s.x%W
  pix(s.x,s.y,12)
 end
 
 
 uy=43+(sin(t*6)^30*5)+sin(t*2)*5

 elli(W2,uy,14,10,9)
 elli(W2,uy,18,5,9)
 
 num=6
 for i=1,num do
  o=36/num
     circ((W2-18)+(t*10+i*o)%36,uy,1,(i)%4+2)
 end

 for y=0,H2 do for x=0,W do
     c=pix(x+rnd(0,10),y)
        if pix(x,y)==0 and c==9 then
            pix(x,y,c)
        end
    end end


    for y=H2,H do for x=0,W do
     c=pix(x+sin(y*2+t)*4,H2-(y-H2))
        if c==0 then c=8 end
        pix(x,y,c)
    end end

print("ufo danceparty",10,10+sin(t*6)^30*5,12)

end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>