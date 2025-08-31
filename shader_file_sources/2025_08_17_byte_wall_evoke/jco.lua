--bla


local h=135
local w=239 

function ident()
 local res={}
 
 res[1]={1,0,0,0}
 res[2]={0,1,0,0}
 res[3]={0,0,1,0}
 res[4]={0,0,0,1}
 return res
end

function makePrj(fov, near, far)
 local m = ident()
 local s = 1/math.tan(fov*math.pi/360)
 local ratio = h/w
 
 m[1][1]=s*ratio
 m[2][2]=s
 m[3][3]=-(near)/(far-near)
 m[3][4]=-(far*near)/(far-near)
 m[4][3]=-1
 return m
end

function makeTrans(x,y,z)
 local m=ident()
 m[4][1]=x
 m[4][2]=y
 m[4][3]=z
 return m
end

function makeScale(s)
 local m=ident()
 m[1][1]=s
 m[2][2]=s
 m[3][3]=s
 return m
end

function makeRotZ(r)
 local m=ident()
 local rad=r*math.pi/180
 m[1][1]=math.cos(rad)
 m[1][2]=math.sin(rad)
 m[2][1]=-math.sin(rad)
 m[2][2]=math.cos(rad)
 return m
end

function makeRotX(r)
 local m=ident()
 local rad=r*math.pi/180
 m[2][2]=math.cos(rad)
 m[2][3]=math.sin(rad)
 m[3][2]=-math.sin(rad)
 m[3][3]=math.cos(rad)
 return m
end
function mulMat(v, m)
 res={}
 res[1]=m[1][1]*v[1]+m[2][1]*v[2]+m[3][1]*v[3]+m[4][1]
 res[2]=m[1][2]*v[1]+m[2][2]*v[2]+m[3][2]*v[3]+m[4][2]
 res[3]=m[1][3]*v[1]+m[2][3]*v[2]+m[3][3]*v[3]+m[4][3]
 local w=m[1][4]*v[1]+m[2][4]*v[2]+m[3][4]*v[3]+m[4][4]
 
 res[1]=res[1]/w
 res[2]=res[2]/w
 res[3]=res[3]/w
 return res
end

function makeCube()
 return {{-1,-1,-1},{1,-1,-1}, {1,1,-1},{-1,1,-1}, {-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}
end


function doTheCube(tX, tY, tZ, rotX, rotZ, scl, col)
 local final={}

 local cb=makeCube()
 local cbs=makeScale(scl)
 local tr=makeTrans(tX, tY, tZ, 10)
 local rz=makeRotZ(rotZ)
	local rx=makeRotX(rotX)
	local prj=makePrj(80,1,100)
 
 for k=1,8 do
  local v = mulMat(cb[k], cbs)
  -- rotate
  v = mulMat(v, rz)
  v = mulMat(v, rx)
  -- translate
  v = mulMat(v, tr)
  -- project
  local v2 = mulMat(v, prj) 
  final[k]={v2[1] * w/2 + w/2, v2[2]*h/2+h/2} 
 end
 
 --draw
 
 -- draw wireframe cube
 local lines={{1,2},{2,3},{3,4},{4,1}, {5,6},{6,7},{7,8},{8,5},
 {1,5},{2,6},{3,7},{4,8}}
 for k=1,12 do
  line(
  final[lines[k][1]][1],
  final[lines[k][1]][2],
  final[lines[k][2]][1],
  final[lines[k][2]][2], col)
 end
 
 --return final
end

function TIC()
	local t=time()*.01
	
	--clear
	for y=0,w do
		for x=0,w do
		 pix(x,y,0)
	 end
 end


 local anim=math.sin(t*0.1)
 
 local designText="SPAECPIGS"
 
 print(designText,16-anim,35,14,1,4)
 print(designText,16+anim*2.0,34,15,1,4)
 
 
 local designText="4D"
 print(designText,82.0+anim,65,14,1,7)
 print(designText,82.0-anim*1.0,64,15,1,7)
 
	
	for i=1,10 do
	 for k=1,8 do
	  local off=math.sin(k + t*0.1)
	  local off2=math.cos(k + t*0.35)
		 doTheCube(-k*4 + 18, off2*4, 10 + off*4, t*2 + k*40, t*3 + k*33, math.pow(1.025,i), 13 + i/4)
	 end
 end
 
 for k=1,8 do
  local off=math.sin(k + t*0.1)
  local off2=math.cos(k + t*0.35)
	 doTheCube(-k*4 + 18, off2*4, 10 + off*4, t*2 + k*40, t*3 + k*33, 1, k+1)
 end
 
 
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>