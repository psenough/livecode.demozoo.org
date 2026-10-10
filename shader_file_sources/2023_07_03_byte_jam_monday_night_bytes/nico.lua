-- hi it's nico coming to you live
-- from the cramped corner of my room
-- that is not full of junk!
-- been a while since I did one of
-- these monday night jams,
-- let's see what I come up with
-- greets to everybody cool
-- (everybody here is cool)

s = math.sin
c = math.cos
t = 0

resetpoint = 0

width = 30
-- let's start with a plasma
function TIC()t=time()/260-resetpoint

width = 40
vbank(0)
for y=0,136 do for x=0,240 do
pix(x,y,
(s(x/16+t)+s((y+t)/(16/s(t/2)))+t)%4+(c(t/32)*16)+((y//width)%16)*4)
end end

vbank(1)

pix((t*8)%240,s(t)*(136/2)+(136/2)+2+1,15)
pix((t*8)%240,c(t)*(136/2)+(136/2)+2+1,15)

pix((t*8)%240,s(t)*(136/2)+(136/2)+2,12)
pix((t*8)%240,c(t)*(136/2)+(136/2)+2,12)
_,_,click,_,_,_,_ = mouse()

if t>100 then
    cls()
    resetpoint = resetpoint + t
end

vbank(0)


end

-- was surprised that just worked.
-- first time using blackhole on new laptop

function SCN(l)
    bop = fft(0)+fft(1)+fft(2)+fft(3)+fft(4)
    if l%width*2 == 0 then
        poke(0x3FF9,l//width*(bop*50))
    else
        poke(0x3FF9,-l//width*(bop*50))
    end
end