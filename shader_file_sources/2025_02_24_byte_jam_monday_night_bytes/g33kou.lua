-- looks like a 256b entry :)
f,t={
function() pix(x,y,x+y*ff/10) end,
function() pix(x,y,x*ff/10+y) end,
function() pix(x,y,3+(x*y*ff/10)%(10*ff)) end,
},0
TIC=load't=t+1 ff=fft(0,40) for i=0,32640 do x,y=i%240,i//240 if t%2==0 then f[t%3+1]() end end'