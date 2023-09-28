cols = {}
for i = 0, 44 do
    cols[i] = peek(0x3fc0 + i)
end

function SCN(l)
    if l < 68 then
        for i = 0, 44 do
            poke(0x3fc0 + i, cols[i])
        end
    else
        for i = 0, 14 do
            poke(0x3fc0 + i * 3, cols[i * 3])
            poke(0x3fc1 + i * 3, cols[i * 3])
            poke(0x3fc2 + i * 3, cols[i * 3])
        end
    end
end

function TIC()
    t = time() // 32
    mucky = {}
    for i = 0, 9 do
        mucky[i] = 0
        for j = 0, 14 do
            mucky[i] = mucky[i] + fft(i * 15 + j)
        end
        mucky[i] = mucky[i] * 10
    end

    for y = 0, 136 do
        for x = t % 2, 240, 2 do
            cl = mucky[(math.sin((x) / 12 + (y + x * (y + t * 2.1) / 74 / mucky[0]) / 33) * 11 + math.sin(y / 21) * 10 +
                     math.sin(mucky[1] * 54 + y / 255 + x / 231) * 23) // 5 % 10] // 1 >> 2
            if cl > 0 then
                pix(x, y, cl)
            else
                pix(x, y, pix(x + 1, y))
            end
        end
    end

end
