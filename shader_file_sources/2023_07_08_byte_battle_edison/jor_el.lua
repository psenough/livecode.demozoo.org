sin = math.sin
cos = math.cos

MAX_X = 200
cur_x = 0
function TIC()
t=time()
cls()
color = t*0.01
cur_x = cur_x + 1
cur_x = cur_x % MAX_X

text = "edison party!!!"

for i = 1, #text do
print(text:sub(i,i),-20+ cur_x+i*10,5*sin(t*0.01+i)+ 100+fft(1)*20, color)

end

--print(text, cur_x,5*sin(t*0.01)+ 100, color)


iter = 3
for i = -iter, iter do 
	grid(i,i,t,color)
end

end

function grid(x_off, y_off,t, col)
d = 10 *fft(0)
d2 = 30
iter = 3
for x = -iter, iter do
	for y = -iter,iter do
	if x%2 == 0 then
	rotation = rot(x,y,t)
	else
	rotation = fold(x,y,t)
	end
	--circ(x_off*d2+120+rotation[1]*d,50 +rotation[2]*d,1, col)
	pix(x_off*d2+120+rotation[1]*d,50 +rotation[2]*d, col+x_off)
	
	end 
end
end


function rot(x,y,t)
slow = 0.001
X = x*cos(t*slow)-sin(t*slow)*y
Y = x*sin(t*slow)+cos(t*slow)*y
return {X,Y}
end

function fold(x,y,t)
slow = 0.001
X = x*cos(t*slow)-sin(-t*slow)*y
Y = x*sin(t*slow)+cos(t*slow)*y
return {X,Y}
end
