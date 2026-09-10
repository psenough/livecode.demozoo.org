-- hello, aldroid here!
-- <3 to violet and fellow coders!
-- and <3 to the chat (And You!)
-- got an idea for an idea that
-- might be a bit ambitious in an
-- hour!

C=math.cos
S=math.sin

pxs={
-- back
{-5,0,-3},{0,-3,-1},{5,0,-3},
{0,3,-1},
-- nose,
{0,1,9},
-- rocket
{-1,0,-3},
{1,0,-3},
{1,-3,-8},

}
trs={
-- back
{1,2,3,3},{1,3,4,4},
-- nose
{1,2,5,4},{2,3,5,4},
{1,4,5,3},{4,3,5,3},
-- rocket
{6,7,8,2}
}

function rotx(pt,a)
  return {
   pt[1],
   pt[2]*C(a)-pt[3]*S(a),
   pt[3]*C(a)+pt[2]*S(a)
  }
end
function roty(pt,a)
  return {
   pt[1]*C(a)-pt[3]*S(a),
   pt[2],
   pt[3]*C(a)+pt[1]*S(a)
  }
end
function rotz(pt,a)
  return {
   pt[1]*C(a)-pt[2]*S(a),
   pt[2]*C(a)+pt[1]*S(a),
   pt[3]
  }
end

function scale(pt,s)
  return {pt[1]*s,pt[2]*s,pt[3]*s}
end

function depth(p1,p2,p3)
  return (p1[3]+p2[3]+p3[3])/3
end

function depthfirst(t1,t2)
return t1[7]<t2[7]
end

function TIC()t=time()/32
cls(11)
rect(0,70,240,66,7)

tris = {}

for tr = 1,#trs do
  plist = trs[tr]
  p1 = pxs[plist[1]]
  p2 = pxs[plist[2]]
  p3 = pxs[plist[3]]

		p1=		scale(p1,6)
		p2=		scale(p2,6)
		p3=		scale(p3,6)
		
		zr=S(t/20)/10
		
		p1=		rotz(p1,zr)
		p2=		rotz(p2,zr)
		p3=		rotz(p3,zr)
  
  trx = -S(t/20-1)*20
  p1[1]=p1[1]+trx
  p2[1]=p2[1]+trx
  p3[1]=p3[1]+trx
		
		
		p1=		rotx(p1,.42)
		p2=		rotx(p2,.42)
		p3=		rotx(p3,.42)
		
		trn=30
		p1[2]=p1[2]+trn
		p2[2]=p2[2]+trn
		p3[2]=p3[2]+trn

		d = depth(p1,p2,p3)

  table.insert(tris,{
    120+p1[1],68+p1[2],
    120+p2[1],68+p2[2],
    120+p3[1],68+p3[2],
  		-d,  
    plist[4]
  })
end

table.sort(tris,depthfirst)

for ti=1,#tris do
  tr=tris[ti]
  tri(tr[1],tr[2],tr[3],tr[4],tr[5],tr[6],tr[8])
end


msg="so i tried to make a 3d engine in an hour, and it's not bad but it's not great! hope you enjoyed the fun, have a lovely evening. byte jam byte jam byte jam!"
-- 826+240
print(msg,240-t%(826+240),20)

end
