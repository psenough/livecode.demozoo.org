-- tobach testttiiinnnggggg
-- hello lovebyte!!!!!
-- greetz to evilpaul, mantra,
-- alia, ferris and aldroid <3
sin = math.sin
cos = math.cos
function TIC()
    t = time() // 32
    cls()
    for i = 0, 4 do
        rect(0, -40 + i * 36, 240, 50, i)
    end

    -- clouds innit
    elli(290 - t % 340, 20, 40, 5, 13)
    elli(340 - t / 1.3 % 480, 60, 40, 5, 13)

    building(250 - t % 400, 60, 14)
    building(320 - t * 1.4 % 400, 70, 13)
    building(310 - t * 1.7 % 400, 80, 14)
    building(300 - t * 1.9 % 400, 85, 15)

    pval = t * 3 % 480
    lines(240 - pval)
    lines(-240 - pval)
    pole(250 - pval)

    rect(0, 120, 240, 40, 15)
    rect(0, 120, 240, 3, 14)

    birb(140 - t * 3 % 480, -2, 0)
    birb(210 - t * 3 % 480, 20, 3)
    birb(370 - t * 3 % 480 - 80, 20, 5)

    for i = 0, 1 do
        print("LOVEBYTE 2023    10-12 FEB", 240 - t * 4 % 560 + i, 124 + i, 3 - i, true, 2)
    end

end

function lines(x)
    for i = 0, 480 do
        pix(x + i, 40 + sin(i / 128) * 8, 0)
        pix(x + i, 41 + sin(i / 128) * 8, 15)
        pix(x + i, 60 + sin(i / 128) * 8, 0)
        pix(x + i, 61 + sin(i / 128) * 8, 15)
    end
end

function building(x, y, col)
    rect(x + 0, y + 0, 41, 120, col)
    for j = 0, 16 do
        for i = 0, 4 do
            rect(x + i * 8 + 2, y + j * 8 + 2, 5, 5, 4)
        end
    end
end

function pole(x)
    rect(-12 + x, 35, 30, 6, 14)
    rect(-12 + x, 55, 30, 6, 14)
    rect(0 + x, 30, 5, 150, 15)
end

function birb(x, y, offset)

    t2 = sin(t / 2 + offset) / 2

    for i = 0, 2 do
        line(x + 175, y + 44, x + 165 + i * 3, y + 47, 3)
    end

    elli(x + 170, y + 35 + sin(t2), 15, 10, 15)
    elli(x + 183, y + 35 + sin(t2 + 0.3), 10, 2, 15)
    elli(x + 175, y + 33 + sin(t2 + 0.6) * 1.15, 10, 4, 14)

    for i = 0, 3 do
        circ(x + 158 - i * sin(t2 + 0.75) * 2, y + 30 - i * 2 * cos(t2 + 0.75), 3, 14)
    end
    circ(x + 151 + sin(t2 + 3) * 3, y + 26 - sin(t2 + 3) * 4, 1, 3)
end
