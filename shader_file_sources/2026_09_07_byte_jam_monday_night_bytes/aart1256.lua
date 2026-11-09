Q=17
a={14,Q,Q,Q,31,Q,Q,Q,0}
A=math.abs

function TIC()
    T=time()
    for i=T%2,32640,1.9 do poke4(i,i/4e8+T%1) end
    for p=0,3 do
    t=T/1e3+p*7.4
    s=math.cos(t)*4
    c=math.sin(t)*4
    for y=63,0,-1 do for x=0,63 do
        M=A(math.sin(t*2))
        O,M=90-M*90,.6+M/2
        X,Y=(x-32)/32,(y-32)/32
        X,Y=X*s+Y*c+10.5,(X*c-Y*s+3.5)//1
        V=a[(Y&7)+1]+(math.random()*1.1//1)
        if (V>>(X//1&7))&1>0 and A(Y-3)<4 then
            X=(x+p*80-T/10)%304
            Y=y*M+O
            rect(X,Y,1,2,(Y)//1&1|6|(math.random()*2//1))
        end
    end end
    end
end