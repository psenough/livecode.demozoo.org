lastT=0
function fps()
 local t=time()
 local d=math.floor(1000/(t-lastT))
 print(d,2,2,0)
 print(d,1,1,12)
 lastT=t
end

function prepare(obj,scale,tx,ty,tz,ry,dist,txElems)
 local sx=240/2
 local sy=136/2
 local rys=math.sin(ry)
 local ryc=math.cos(ry)
 local txVerts={}
 for k,vert in ipairs(obj[1]) do
  local x1=vert[1]*scale+tx
  local y1=vert[2]*scale+ty
  local z1=vert[3]*scale+tz

  local x2=z1*ryc+x1*rys
  local y2=y1
  local z2=z1*rys-x1*ryc

  local z3=(z2+dist)*0.01
  local x3=x2/z3+sx
  local y3=y2/z3+sy
  txVerts[k]={x3,y3,z3}
 end

 for k,elem in ipairs(obj[2]) do
  local elemVerts={}
  local totalZ=0
  local clipped=false
  for i=1,4 do
   local vi=elem[1][i]
   local vert=txVerts[vi]
   elemVerts[i]=vert
   totalZ=totalZ+vert[3]
   if vert[3]<0 then
    clipped=true
    break
   end
  end
  if clipped==false then
	  txElems[#txElems+1]={
	   elemVerts,
	   elem[2],
	   totalZ/4,
	  }
		end
 end
end

function render(txElems)
 for k,elem in ipairs(txElems) do
  local verts=elem[1]
  local x1=verts[1][1]
  local y1=verts[1][2]
  local x2=verts[2][1]
  local y2=verts[2][2]
  local x3=verts[3][1]
  local y3=verts[3][2]
  local wind=
   (x2-x1)*(y2+y1)+
   (x3-x2)*(y3+y2)+
   (x1-x3)*(y1+y3)
  if wind<0 then
	  local x4=verts[4][1]
	  local y4=verts[4][2]
	  local c=elem[2]
	  tri(x1,y1,x2,y2,x3,y3,c)
	  tri(x3,y3,x4,y4,x1,y1,c)
		end
 end
end

obj={
 {
  {-1,1,1},
  {1,1,1},
  {1,-1,1},
  {-1,-1,1},
  {-1,1,-1},
  {1,1,-1},
  {1,-1,-1},
  {-1,-1,-1},
 },
 {
 	{{1,2,3,4},1},
  {{7,6,5,8},1},
  {{2,6,7,3},5},
  {{8,5,1,4},5},
  {{6,2,1,5},0},
  {{8,4,3,7},3},
 }
}

function post()
 for y=0,135 do
  for x=0,239 do
   if pix(x,y)~=7 then
	   pix(x,y,pix(x,y)+(((x+y)>>1)%2))
			end
  end
 end
 for y=2,135 do
  for x=1,239 do
   if pix(x-1,y-2)~=7 and pix(x,y)==7 then
    pix(x,y,15)--pix(x-1,y-2)*15.2)
   end
  end
 end
end

function TIC()
 cls(7)

 local t=time()*.5

 local txElems={}
 local dist=math.sin(t*0.0023)*3+12
 local ry=t*0.0013
 local px1=math.sin(2.43+t*0.0032)*6
 local py1=math.sin(5.43-t*0.0019)*6
 local pz1=math.sin(4.92+t*0.0027)*6
 local px2=math.sin(8.34-t*0.0015)*5
 local py2=math.sin(4.89-t*0.0035)*5
 local pz2=math.sin(5.85+t*0.0068)*5
 local px3=math.sin(5.96-t*0.0004)*4
 local py3=math.sin(9.88+t*0.0032)*4
 local pz3=math.sin(6.67+t*0.0042)*4
 for x=-15,15 do
  local dx1=(x-px1)^2
  local dx2=(x-px2)^2
  local dx3=(x-px3)^2
  for y=-15,15 do
	  local dy1=(y-py1)^2
	  local dy2=(y-py2)^2
	  local dy3=(y-py3)^2
   for z=-15,15 do
	  	local dz1=(z-pz1)^2
	  	local dz2=(z-pz2)^2
	  	local dz3=(z-pz3)^2
    local d1=math.sqrt(dx1+dy1+dz1)
    local d2=math.sqrt(dx2+dy2+dz2)
    local d3=math.sqrt(dx3+dy3+dz3)
    local s1=1-(d1/3)
    local s2=1-(d2/3)
    local s3=1-(d3/3)
    local s=math.max(math.max(s1,s2),s3)
    s=math.min(0.5,math.max(s,0))
    if s>0 then
 			 prepare(obj,s,x,y,z,ry,dist,txElems)
    end
			end
		end
	end
 table.sort(txElems,function(a,b)return a[3]>b[3]end)
 render(txElems)

 
 --fps()
 local txt='We are thankful <3'
 local tx=(240-#txt*6)/2
 local ty=100
 print(txt,tx,ty,0)
 post()
 print(txt,tx-1,ty,0)
 print(txt,tx+1,ty,0)
 print(txt,tx,ty-1,0)
 print(txt,tx,ty+1,0)
 print(txt,tx-1,ty-1,0)
 print(txt,tx-1,ty+1,0)
 print(txt,tx+1,ty-1,0)
 print(txt,tx+1,ty+1,0)
 print(txt,tx,ty,(math.floor(t)>>6)%4+12)
end
