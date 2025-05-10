t=0
pos=0
rows=40
items=10
steps=100
row_data={}
m=math

for i=1,rows do
	row_data[i]={}
	for j=1,items do
		row_data[i][j]=m.random()*6.28
	end
end


function TIC()
	cls()
	
	speed=(m.sin(t/100))*20+(m.sin(t/60))*10+2+fft(10)*50
	pos=pos+speed
	
	if pos>=steps then
		pos=pos-steps
		local removed=row_data[1]
		table.remove(row_data,1)
		row_data[rows]=removed
	end
	
	
	if pos<0 then
		pos=pos+steps
		local removed=row_data[rows]
		table.remove(row_data,rows)
		table.insert(row_data,1,removed)
	end
	
	prev_row={}
		
	for i=rows,1,-1 do
		curr_row={}
		for j=1,items do
			local a=row_data[i][j]+t/j/20
			local x=m.sin(a)*120
			local y=m.cos(a)*120
			local z=(i-(pos/steps))/3
			
			local oa=(i+t*2)/200
			local ox=m.sin(oa)*z*10
			local oy=m.cos(oa/2)*z*6
			
			local X=x/z+120+ox
			local Y=y/z+68+oy
			
			curr_row[j]={X,Y,0}
			
			closest={0}
			for k=1,#prev_row do
				local dx=X-prev_row[k][1]
				local dy=Y-prev_row[k][2]
				local d=m.sqrt(dx^2+dy^2)
				if closest[1]==0 or closest[2]>d then
					closest={k,d}
				end
			end
			
			if closest[1]>0 then
				local p=prev_row[closest[1]]
				line(X,Y,p[1],p[2],12+z/4)
			end
			
			circ(X,Y,(fft(10)*35+j+1)/z,j%4+(t//100)%6)
			if z<5 then
			circ(X-1,Y-1,1,12)
			end
			
		end
		prev_row=curr_row
	end
	
	t=t+1
end
