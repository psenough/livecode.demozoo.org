t=0
x=0
y=0
centerx = 120
centery = 68  
function TIC()
cls() 
print("thanks superrogue")
--basic raycaster adapted from
--sizecoding discord 
for x=0,240,1 do
    for y=0,136,1 do 
        dx=x-centerx;
        dy=y-centery; 
        for d=-10,-300,-1 do
         --dy=dy+t%20
            --dx = dx+t//20%20 
            h=((d*d ~(d*dx)~(dy*d))//256 +4)&(d-t);
            if(h&8>0) then pix(x,y,(h-7 +((x&y)&1)))break
         end
        end        
 end
end 
t=t+1 
end