-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon
cos=math.cos
for i=0,15 do
  poke(0x3fc0+3*i,cos(1+i/3)*127+127)
  poke(0x3fc1+3*i,cos(3+i/3)*127+127)
  poke(0x3fc2+3*i,cos(5+i/3)*127+127)
  --poke(0x3fc2+3*i,128)
  --poke(0x3fc2+3*i,i*i)
end

function TIC()
	local t=time()*.0005
	local i = 0
	sin=math.sin cos=math.cos
	for y=0,135,8 do
		for x=0,239,6 do
		 c=sin(x/31+t)+cos(y/27-t*.8)
			c=c+sin(x/42+t*2)+cos(y/17+t*1.4)
			c=c*2
			rect(x,y,6,8,7+c)
			i=math.floor(c%1*6)+1
			ch=(" evOKE"):sub(i,i)
			if y>126 and x<76 then
			  ch=("chordbug 2024"):sub(x/6+1,x/6+1)
			end
			print(ch,x+1,y+1,8+c,false,1)
		end
	end

end