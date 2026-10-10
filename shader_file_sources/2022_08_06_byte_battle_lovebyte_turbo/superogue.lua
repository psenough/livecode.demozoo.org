--good luck blossom!
t=0
function TIC()t=t+1
for y=0,136 do for x=0,240 do
X=x-y
Y=x+y
q=t//64+2
pix(x,y,(t+X|Y)//q%8-3)
end end end