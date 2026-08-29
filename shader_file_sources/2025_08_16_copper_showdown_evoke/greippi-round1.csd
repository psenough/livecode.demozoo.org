

num_frames=250

color(0,1)

push_pointer(COP1LCH,"hey1")
push(COPJMP1,1)


os=addr()

label("feed")


for a=1,10240 do

--push(math.random(100))
--x=math.floor(math.sin(a/math.cos(a)/10)*16)
---x=math.floor(math.sin(a/math.random(100)/30)*16)
x=math.floor(math.sin(a/12)*16)
push(1 << x)

end


    
    for a=1,num_frames do
    
    label("hey"..a)
    
    --push_pointer(BPL1PTH,os+a*a/2)
    
    for b=44,255 do
    
    push((b&255)<<8|1,0xfffe)
--    color(1,b+a*5)
    color(1,b+a*5+math.floor(math.cos(a)*30))
    
    
    end
    color(0,0)
    
if a<=num_frames-1 then
nextlist("hey"..a+1)
else
nextlist("hey1")
end



end

return resolve(), DMAF_RASTER