-- Long time listener...
-- First time Jammer!

-- Hi Mantratronic, Gasman, Visy
-- Lynn, EvilPaul, Lex, ToBach
-- & JTruk

s=math.sin
c=math.cos

precalc={}
cls()
width=print("HappyBday",0,0,1)

index=1 -- Thank you Lua!
for x=0,width do
	for y=0,7 do
		precalc[index]=pix(x,y)
		index=index+1
	end
end

stars_x={}
stars_y={}
stars_z={}
depth=40
nb_stars=150

for i=1,nb_stars do
	stars_x[i]=math.random(-400,400)
	stars_y[i]=math.random(-200,200)
	stars_z[i]=math.random(0,depth)
end

function TIC()
	t=time()//32
	off_x=120
	off_y=68

 -- Background AKA Sad Starfield :)
 vbank(0)
	cls()

	for i=1,nb_stars do
		x=stars_x[i]
		y=stars_y[i]
		z=depth-(1+stars_z[i]+t/3)%(depth-1)	-- Divide by zero is nasty

		sx=x/z
		sy=y/z

		circ(sx+off_x,sy+off_y,0.5,12)
	end

 -- Foreground
 vbank(1)
	cls()

	-- I'm blatently copying I saw
	-- aldroid do but I'll tweak it.
	--width=print("HappyBday",0,0,1)

	scale_x=4
	scale_y=4
	angle=t/30

	for i=0,1 do
		color=2
		if i==1 then
			color=1+(t)%15
		end

		index=0
		for x=0,width do
			for y=0,7 do
		 	if precalc[index]==1 then
					rel_x=x-(width/2)
					rel_y=y-4

			  scr_x=scale_x*rel_x*c(angle)-scale_y*rel_y*s(angle)
					scr_y=scale_y*rel_y*c(angle)+scale_x*rel_x*s(angle)

					circ(off_x+scr_x,
					     off_y+scr_y,
										3-i,
										color)
				end

				index=index+1
			end
		end
	end
end
