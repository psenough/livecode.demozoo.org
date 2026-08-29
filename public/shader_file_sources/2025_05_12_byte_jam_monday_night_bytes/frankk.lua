sqrt=math.sqrt
floor=math.floor
ceil=math.ceil
rand=math.random
abs=math.abs
unpack = unpack or table.unpack


function round(n)
    return math.floor(n+0.5)
end

function normalize(x,y)
	len=sqrt(x*x+y*y)
	return x/len,y/len
end

palette = {
    {  40,  20,  10 },   
    {  80,  40,  20 },   
    { 120,  60,  25 },   
    { 160,  90,  40 },   
    { 190, 120,  60 },  
    { 215, 150,  80 },  
    { 230, 180, 110 },  
    { 240, 200, 130 },  
    { 220, 210, 190 },  
    { 160, 190, 180 },  
    { 120, 160, 160 },  
    {  90, 130, 140 },  
    {  70, 110, 120 },  
    {  55,  90, 110 },  
    {  40,  70,  90 },  
    {  30,  50,  70 },  
}


function SetPalette()
 for i = 0, 15 do
  	local r, g, b = unpack(palette[i+1])
   poke(0x3FC0 + i * 3 + 0, r)
   poke(0x3FC0 + i * 3 + 1, g)
   poke(0x3FC0 + i * 3 + 2, b)
 end
end

function round(n)
    return math.floor(n+0.5)
end

Fields = 
{
    [0] = function(x, y)
        return 0, 0  -- static zero field
    end,

    [1] = function(x, y)
        return -y, x  -- counter-clockwise vortex
    end,

    [2] = function(x, y)
        return math.atan2(y, x), 0  -- angle-only (spiral modulator)
    end,

    [3] = function(x, y)
        return 0, -y  -- up down
    end,

    [4] = function(x, y)
        return -x, -y  -- radial inward
    end,
    
    [5] = function(x, y)
        return y / (x * x + 1), x / (y * y + 1)  -- rational
    end,


			 [6] = function(x, y)
        return math.sin(y / 10), math.cos(x / 10)  -- wavy field
    end,

    [7] = function(x, y)
        return 0, y  -- up down
    end,

    [8] = function(x, y)
        return y, -x  -- clockwise vortex
    end,

			 [9] = function(x, y)
        return x * math.sin(y / 20), y * math.cos(x / 20)  -- warped radial
    end,

    [10] = function(x, y)
        return x, -y  -- saddle field
    end,

    [11] = function(x, y)
        return math.tan(y/50), -math.tan(x/50)  -- chaotic tangent field
    end,
}

frame=0
cleared=false
Field=Fields[0]
f_id=0
function TIC()

	SetPalette()
	if not cleared then
		cls()
		cleared=true
	end
		
	screenBuf={}
	
	frame=frame+1
		
	for y=10,125 do
		for x=10,230 do

				_x=(x-120)
				_y=(y-68)
		
				if frame%180==0 then
					f_id=frame//180%11
					Field=Fields[f_id]
				end

				border = ((x==10 or y==10 or x==225 or y==125) and x%5==0 and y%5==0)
				centerX = (x==120 and y%5==0)
				centerY = (y==68 and x%5==0)
				
				i = rand(1,1000)		
				
				if (border or centerX  or centerY) and i>200 then
					color = (frame+x)//20
					screenBuf[x+240*y]=color
				else
					vx,vy=normalize(Field(_x,_y))
					c=pix(round(x-vx),round(y-vy))
					screenBuf[x+240*y]=c
				end
		end
	end					
	
	for y=0,136 do
		for x=0,240 do
			pix(x,y,screenBuf[x+240*y])
		end
	end

	
	for y=1,135 do
		rect(fft(y/4-1,y/4)*4,y,fft(y/4-1,y/4)*14,1,y/4)	
		rect(239-fft(y/4-1,y/4)*14,y,fft(y/4-1,y/4)*10,1,y/4)
	end

end