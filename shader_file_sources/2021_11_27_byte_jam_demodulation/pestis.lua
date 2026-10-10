function TIC()t=time()/199
    for j=.2,10,.03 do
    circb(120+s(j+t*5)*29,68+s(j+t*7)*29,299*j,0)
    for i=0,9 do 
    l=(t+5/j+i/9)//1,s(t)^2>1e-4or cls(15)
    r=s(l+i*2)+i+2
    w=l+i*4+s(s(t/19)*2+t/17)
    q=20*j
    for k=0,2 do
    m=(k+1)//2-q/2
    rect(s(w)*r*19*j+120+m,s(w+8)*r*19*j+68+m,q-k//2,q-k//2,2+k-.6/j)
    end
    end
    end
    for i=0,32639 do
    poke4(i,peek4(i)-s(i*i*t))
    end
    print("Greetings to Demodulation!!!!! pestis sends much love from Finland. Ran out of ideas so time to write scrollers... This wasn't going to fit 256b so whatever. Join us at lovebyte 2022!! 11-13.2.2022",240-t%199*20,68+s(t)*50,12,1,3)
    end
    s=math.sin