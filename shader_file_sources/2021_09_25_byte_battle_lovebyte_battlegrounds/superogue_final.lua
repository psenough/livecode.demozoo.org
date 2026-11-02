g=0 function TIC()cls(10)
    g=g+.01S=math.sin
    s=S(g)c=S(g-11)
    for y=-31,31 do for x=-31,31 do
    u=x*c-y*s
    v=x*s+y*c
    z=x//1~y//1
    w=(S(y/7)+S(x/5+g*6))*9
    X=u*8+s*32+120
    Y=v+w*2+160W=S(g*9)
    circ(u/3+120,W*9+v/5-z/6*W+40,1,-z/7)
    rect(X,Y+v,9,9,Y/4+7)
    end end end