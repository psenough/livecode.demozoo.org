

function eye(p, t, kfft)
	circ(
		p.x, p.y, math.max(3, kfft/2), 12
	)
	
	circ(
		p.x + math.sin(t)*kfft/4,
		p.y + math.cos(t)*kfft/4,
		kfft/3,
		0
	)
end

function kisu(p, t)
	kfft = fft(0, 8) * 32
	kfft_2 = kfft/2
	
	tri(
		p.x - 35 - kfft/3, p.y + -30 - kfft,
		p.x - 30 - kfft/2, p.y + 20 - kfft/2,
		p.x - 10, p.y + 0 - kfft/2,
		2
	)
	
	tri(
		p.x + 35 + kfft/3, p.y + -30 - kfft,
		p.x + 30 + kfft/2, p.y + 20 - kfft/2,
		p.x + 10, p.y + 0 - kfft/2,
		2
	)
	
	circ(p.x, p.y + 20,
		30 + kfft / 2,
		2
	)
	
	eye({x=p.x + 15 + kfft/2, y=p.y + 20},t, kfft)
	eye({x=p.x - 15 - kfft/2, y=p.y + 20},-t, kfft) 
 
	tri(
		p.x - 5 - kfft/2, p.y + 30 + kfft/2,
		p.x + 5 + kfft/2, p.y + 30 + kfft/2,
		p.x,     p.y + 40 + kfft/2,
		1
	)
	
end

function TIC()
	t=time()//32
	cls()
	
	kisu(
		{ 
			x = 120 + math.sin(t / 3 + fft(0,8)) * 20,
			y = 64 + math.cos(t / 2 + fft(0, 12)) * 20
		}, t
	)
	
end
