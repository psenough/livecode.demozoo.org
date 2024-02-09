M,P=math,poke
T,S,C=0,M.sin,M.cos
TIC=cls
function BDR(n)
 P(16320,n)
 P(16324,n)
    sc=(n*.3-T*.03)%10
 for a=0,6.28,.01 do
  x=16*S(a)^3+S(n*.6)*20y=n+13*C(a)-5*C(2*a)-2*C(3*a)-C(4*a)+S(n*.9)*20pix(120+x/sc,68-y/sc,1,1)
 end
    T=T+0.01
end