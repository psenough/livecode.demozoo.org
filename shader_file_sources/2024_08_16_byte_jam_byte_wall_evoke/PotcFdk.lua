-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

local X,Y = 240,136

local SPc={
	{0,-0.8},
	{-1,0.8},
	{1,0.8}
}
function SP(color,iter, oX, oY, scale, rot)
	local cX, cY = SPc[1][1], SPc[1][2]
	for i=1,iter do
		local rX, rY = math.cos(rot)*cX-math.sin(rot)*cY, math.sin(rot)*cX+math.cos(rot)*cY
		pix(oX+rX, oY+rY, color)
		local n = math.floor(math.random()*3)+1
		local nX, nY = SPc[n][1]*scale, SPc[n][2]*scale
		cX = (cX+nX)/2
		cY = (cY+nY)/2
	end
end

function C (s, i)
	return string.sub(s,i,i)
end

function scroller(s, p, t, c, oX, oY)
	local sl = string.len(s)
	for i=1,sl do
		print(C(s,i),(-p*2)+oX+i*16,oY+math.sin(i/2-t*3)*10,c,true,3)
	end 
end

local tx = "Evoke! Halt! Don't move! Look at this! I am sitting next to Roeltje and he told me how2tic80! Nice! Now you read my scroller. Why is it so long? Shit. Stop. Stop now. Help.                  You thought it was over? Yes. Yes, it was."

function cls2()
	for x=0,X do
		for y=0,Y do
			local c = pix(x+2,y)
			if math.random()>0.15 then
				pix(x,y,math.max(0,c-1))
			end
		end
	end
end

function star(y)
	pix(math.random()*X,y,12) 
end

cls()

function TIC()
 vbank(0)
	local t=time()*.001
	cls2()
	
	for i=1,5 do
	star(math.random()*Y)
	end
	
	SP(11,3000, 100+math.sin(t*5.142612)*10, 50+math.cos(t*3.7162)*12, math.sin(t*1.41735723/2.5)*50+50, t%360)
	SP(3,3000, 110+math.cos(t*3.191281+800)*30, 80+math.sin(t*3.8122+4)*math.sin((t+2)*1.10001)*58*2, math.sin((t+801)*4.41735723/2.5)*50+50, (t*3*1.00003816+124)%360)


 scroller(tx,(t*50)%2200, t, 15, X+41, 112)
 scroller(tx,(t*50)%2200, t, 12, X+40, 110)
 
 vbank(1)
 cls()
 print("PotcFdk", 
 	6+math.sin(t*math.abs(math.sin(t*1))*20)*0.02,
 	6+math.cos(t*math.abs(math.sin(t*1.112))*23)*0.019,
  12)
end