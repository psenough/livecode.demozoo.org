r=rect
h,i,j,k,l=220,21,0,-1,-1
function TIC()cls()for m=1,9 do
print("00",115,0,7)r(119,m*14,2,6,7)end
k=(i<20)and 1or(i>h)and -1or k
l=(j<20)and 1or(j>136)and -1or l
i=i+k*9*fft(2)j=j+l*9*fft(4)circ(i,j,5,6)s=(i-9)/h
r(9,j*(1-s),9,30,7)r(h,j*s,9,30,7)end