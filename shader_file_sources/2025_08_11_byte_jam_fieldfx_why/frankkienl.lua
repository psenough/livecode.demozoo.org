-- title:   Flappy TIC
-- author:  FrankkieNL @ Pixelbar Rotterdam
-- desc:    Flappy bird clone
-- site:    pixelbar.nl
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0
x=96
y=24
birdSize=12
birdColor=4 --yellow
score=0

screenWidth=240
screenHeight=136
tubex=screenWidth
tubey=screenHeight/2 -- middle of height
tubeColor=6
tubeWidth=16

function TIC()

	if btn(0) then y=y-1 end
	if btn(1) then y=y+1 end
	if btn(2) then x=x-1 end
	if btn(3) then x=x+1 end

	cls(13) -- clears screen with color
	
	-- Draw "bird" in code only
	circ(x,y,birdSize,birdColor)
	
	-- Move tube every 'tick'
	tubex = tubex - 4
	if tubex <= 0 then
		tubex=screenWidth
		tubey = math.random(25, screenHeight)
		score=score+1
	end
	
	-- Draw tube
	rect(tubex, tubey, tubeWidth, screenHeight, tubeColor)
	rect(tubex-4,tubey,tubeWidth+8,8,tubeColor)
	
	-- `..` = concatenate
	print("Flappy TIC; Score: " .. score,0,0)
	t=t+1
end

