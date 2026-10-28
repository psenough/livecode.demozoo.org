s=math.sin
function r(X,Y,A)return X*s(A-11)-Y*s(A)end
TIC=load't=time()/499 cls()for z=-3,3,.1 do for y=-3,3,.1 do for x=-3,3,.1 do q=s(t+y)%2 if z%2<q and y%2<q and x%2<q then X=r(x,z,t)Z=9+r(z,-x,t)Y=y rect(120+X*99/Z,68+Y*99/Z,3,3,X+t)end end end end'