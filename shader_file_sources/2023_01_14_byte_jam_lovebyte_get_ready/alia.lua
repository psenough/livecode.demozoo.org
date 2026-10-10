t = 0
pt = 0
sin = math.sin

cls()

function path(t)
    return 100 + (40 * (sin(t) ^ 3 + sin(t * 1.34) ^ 3 + sin(t * 1.55) ^ 3))
end

function TIC()
    poke(0x3ffb, 255)

    vbank(1)
    cls()

    for y = 40, 20, -2 do
        tt = t - y * .03
        x = path(tt)
        ty = 136 - y - 20 + sin(tt * 8) * 8
        circ(x, ty, 8, y / 2 % 2 + 3)
        line(x - 8, ty - 1, x - 8, ty + 1, 1)
        line(x + 8, ty - 1, x + 8, ty + 1, 1)
        elli(x - 5, ty + 6 + sin(tt * 8 + 1.5) * 3, 1, 5, 3)
        elli(x + 5, ty + 6 + sin(tt * 8 + 1.5) * 3, 1, 5, 3)
    end

    tt = t - 40 * .03
    x = path(tt)
    ty = 136 - 40 - 28 + sin(tt * 8) * 8

    for y = 0, 10 do
        circ(x + sin(y / 4 + pt * 4) * y, ty - y * 2, 2, y % 2 + 3)
    end
    tt = t - 18 * .03
    x = path(tt)
    ty = 136 - 25 - 14 + sin(tt * 8) * 8
    -- ears
    elli(x - 4, ty - 7, 2, 3, 4)
    elli(x + 4, ty - 7, 2, 3, 4)
    -- face
    elli(x, ty, 8, 7, 3)

    elli(x, ty + 2, 5, 2, 12)
    elli(x, ty - 1, 6, 2, 3)
    circ(x - 3, ty - 2, 1, 12)
    circ(x - 3, ty - 2, 0, 1)
    circ(x + 3, ty - 2, 1, 12)
    circ(x + 3, ty - 2, 0, 1)

    vbank(0)

    r = path(t)
    line(r - 13, 135, r + 13, 135, (t * 4) % 10 + 1)
    line(r - 8, 135, r + 8, 135, (t * 4) % 3 + 13)

    x = math.random(0, 239)
    if fft(1) > .5 and math.abs(x - r) > 17 then
        circ(x, 135, 8, 5)
        circ(x + 1, 135, 7, 6)
        circ(x + 2, 135, 6, 7)
    end

    t = t + .03
    pt = pt + fft(1) / 20
end

function SCN(y)
    if y < 135 then
        for x = 0, 239 do
            p = pix(x, y - 1)
            q = pix(x, y + 1)
            if q > 0 and p ~= q then
                p = q
            end
            pix(x, y, p)
        end
    else
        line(0, 135, 239, 135, 0)
    end
end
