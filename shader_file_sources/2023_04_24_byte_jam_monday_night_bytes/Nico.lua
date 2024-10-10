-- hi it's nico
-- vibe time
-- got some specific things in mind for tonight 
-- might not get anywhere with them
-- but I'm here anyway
-- greets to Aldroid and the rest of the fieldfx crew, 
-- Synesthesia, Alia, Gasman, and Gigabates!

-- this looked a lot cooler in my head...

s = math.sin
c = math.cos

rand = math.random

dc=06

names = {"Aldroid",
"Gasman","Synesthesia",
"fieldfx","Alia","Gigabates",
"hoffman","demoscene","crypt","FTG","tic80",
"nesbox","starchaser","tobach"}
-- sorry the text render can't deal with the diacritics :(
-- here's an ^ for you

displaytext = ""
char = 1
px = 10
py = 20

t=0

function BOOT() 
cls()
end
function TIC()
-- greets thing
	rectb(5,5,80,125,dc)
	clip(5,5,80,125)

	print("GREETZ",10,10,dc)
	if #displaytext <= char then
		displaytext = displaytext .. names[rand(#names)] .. " "
	end
	
	
	if (t%4) > 2 then
			rect(px,py,6,6,dc)
	end
	
	if (t%4)==0 then
		rect(px,py,6,6,0)
		print(displaytext:sub(char,char),px,py,dc)

	
		char = char + 1
		px = px + 6
		if (char % 12) == 11 then
			px = 10
			py = py + 6
		end
		if py > 120 then
			px = 10
			py = 20
			cls()
		end	
		end
	clip()
-- screw it!
	rectb(90,5,150,50,dc)
	clip(90,5,150,50)
	rect(91,6,140,50,0)
	
	for x=0,20 do
		rect((x*8)+90,-fft(x)*80+55,8,8,dc)
	end
	clip()
	-- time for the uhh 3rd window!!!!!!
	-- yes I did only just discover clip() making this
	rectb(90,60,150,70,dc)
	clip(90,60,150,70)
	
	if (t%150)==0 then
		rect(91,61,149,69,0)
	end
	
	for i=0,20,2 do
		pix((t%150)+90,s(t/8+i)*10+80+i,dc)
		-- lol as if I'd break monochrome
		pix((t%150)+90,s(t/8)*10+80+i,dc)
	end
	
	print("SCANNING...",120,120,dc)
	clip()
	
	t = t + 1 -- ooh, the bad way of doing time!!!
	-- yes I don't care
end


-- an attempt at noise
-- can't get it looking right
function OVR()
	for i=0,100 do
	pix(rand(240),rand(138),12)
		pix(rand(240),rand(138),14)
			pix(rand(240),rand(138),15)
	end
end

function SCN(l)
	bop = fft(1)+fft(2)+fft(3)+fft(4)+fft(5) -- make this easier pls
	poke(0x3FF9,s(l)*(bop*1)+(l%(s(t/8)*5)))
end