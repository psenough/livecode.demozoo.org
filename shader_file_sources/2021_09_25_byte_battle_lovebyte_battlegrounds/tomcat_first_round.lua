for i=0,47 do t=0m=32640poke(16367-i,i*5)end
function TIC()t=t+.2T=3*math.cos(t)for o=0,m
do u=o%240/136-.9v=o/m-.5l=3i=0repeat
X=l*u-T*3Y=T*T-l*v-4Z=l+T*T-19
g=math.min((X*X+Y*Y+Z*Z)^.5-5,5-T*T/7-l*v)l=l+g
i=i+1until i>14or g<.05or l>16poke4(o,i)end
end