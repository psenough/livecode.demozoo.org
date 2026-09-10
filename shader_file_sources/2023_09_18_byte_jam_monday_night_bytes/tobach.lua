carpetarr={}
for i=1,16 do
 carpetarr[i]={}
end

sin=math.sin
cos=math.cos
function TIC()
 t=time()/100
 cls(4)
 rect(0,0,240,80,12)
 for i=0,26 do
  for j=0,8 do
   rect(i*9,j*9,8,8,10)
  end
 end
 
 --checkout
 rect(0,90,200,80,15)
 rectb(0,91,200,45,0)
 rect(0,75,240,20,14)
 rectb(0,75,240,20,13)
 rectb(1,76,238,18,13)


 print("NOT TESCO",30,10,8,true,3)
 print("NOT TESCO",32,12,9,true,3)
 
 for i=1,3 do
  rect(16+i*18,28,10,4,1)
  rect(17+i*18,29,10,4,2)
 end

 for i=1,5 do
  rect(88+i*18,28,10,4,1)
  rect(89+i*18,29,10,4,2)
 end

 milk(220-t*8%300,15)
 jam(270-t*8%360,2)
 ciggies(220-t*8%310,34)
 pop(320-t*8%540,13)
 cereal(320-t*8%500,0)
 
end

function pop(x,y)
 rect(120+x,20+y,25,50,4)
 rect(122+x,17+y,21,3,4)
 rect(124+x,15+y,17,3,4)
 rect(122+x,70+y,21,3,4)
 rect(124+x,72+y,17,3,4)
 rect(124+x,70+y,17,3,3)
 rect(122+x,20+y,21,50,3)
 rectb(120+x,35+y,25,20,1)
 rect(121+x,36+y,23,18,2)
 rect(130+x,11+y,5,4,1)
end

function cereal(x,y)
 rect(80+x,40+y,40,50,4)
 rectb(80+x,40+y,40,50,3)
 tri(85+x,60+y,115+x,60+y,100+x,80+y,2)
 tri(87+x,60+y,113+x,60+y,100+x,78+y,3)
 circ(93+x,60+y,7,2)
 circ(106+x,60+y,7,2)
 circ(96+x,62+y,7,3)
 circ(103+x,62+y,7,3)
end

function jam(x,y)
 rect(60+x,50+y,25,35,2)
 rectb(60+x,50+y,25,35,12)
 rectb(61+x,51+y,23,33,13)
 rect(58+x,45+y,29,5,1)
 rect(62+x,60+y,21,8,13)
end

function milk(x,y)
 rect(20+x,20+y,20,50,12)
 rect(40+x,40+y,10,30,12)
 rect(40+x,22+y,8,5,12)
 rect(45+x,25+y,5,16,12)
 rect(30+x,16+y,8,4,6)
 rect(20+x,46+y,30,12,7)
 rect(22+x,48+y,26,8,6)
end

function ciggies(x,y)
 rect(70+x,20+y,20,30,12)
 rect(70+x,30+y,20,2,4)
 for i=0,20 do
  line(70+x,32+i+y,89+x,32+i+y,7+i%2)
 end
end