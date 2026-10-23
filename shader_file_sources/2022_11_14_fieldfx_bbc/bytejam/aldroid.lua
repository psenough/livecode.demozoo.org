function TIC()
    t = time() / 32
    blumpkin = math.pow((math.sin(t / 2) + 1) / 2, 2) * 5
    for i = 0, 9 do
        poke(0x3fc0 + i * 3, (i + blumpkin) * 255 / 15)
        poke(0x3fc1 + i * 3, (i) * 255 / 15)
        poke(0x3fc2 + i * 3, i * 255 / 15)
    end
    for x = 0, 239 do
        for y = 0, 137 do
            pix(x, y, pix(x + 1, y) + 1)
        end
    end
    buls = 20 + 10 * math.sin(t / 10)
    for i = 1, 5 do
        pp = i * math.pi * 2 / 5 + t / 20
        circ(170 + buls * math.cos(pp), 68 + buls * math.sin(pp), buls / 3, 4)
    end
end
