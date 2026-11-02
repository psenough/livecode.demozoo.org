pi = math.pi
twoPi = pi * 2
function frand(min, max)
    return min + math.random() * (max - min)
end
function lerp(min, max, alpha)
    return min + alpha * (max - min)
end

objs = {}
maxObjs = 50
for i = 0, maxObjs do
    a = i / maxObjs
    new = {}
    new.x = math.random(-50, 240 + 50)
    new.y = math.random(0, 2048)
    new.yv = frand(.5, 4)
    new.size = lerp(1, 20, a)
    new.r = frand(0, twoPi)
    new.rv = frand(-.125, .125)
    table.insert(objs, new)
end

function stars()
    for k, p in pairs(objs) do
        x = p.x
        y = (2048 - p.y) - 100
        r = p.r
        s = p.size
        drawStar(x, y, s + 10, r, 12)
        drawStar(x, y, s + 5, r, 1)
        drawStar(x, y, s, r, 3)
        p.y = (p.y + p.yv) % 2048
        p.r = p.r + p.rv
    end
end

function drawTri(x, y, size, rotation, color)
    x1 = x + math.sin(rotation + 0 / 3 * twoPi) * size
    x2 = x + math.sin(rotation + 1 / 3 * twoPi) * size
    x3 = x + math.sin(rotation + 2 / 3 * twoPi) * size
    y1 = y + math.cos(rotation + 0 / 3 * twoPi) * size
    y2 = y + math.cos(rotation + 1 / 3 * twoPi) * size
    y3 = y + math.cos(rotation + 2 / 3 * twoPi) * size
    -- tri(x1,y1,x2,y2,x3,y3,color)
    circ(x1, y1, size / 2, color)
    circ(x2, y2, size / 2, color)
    circ(x3, y3, size / 2, color)
end
function drawStar(x, y, size, rotation, color)
    drawTri(x, y, size, rotation, color)
    drawTri(x, y, size, rotation + pi, color)
end

function bg(t, color)
    for x = 0, 240, 2 do
        cx = x - 240 / 2
        sx = cx * cx
        for y = 0, 136, 2 do
            if pix(x, y) == 0 then
                cy = y - 136 / 2
                sy = cy * cy
                a = math.atan(cx, cy)
                d = math.sqrt(sx + sy) * .05
                d = d + math.sin(d * math.sin(t) * 5 + t + math.sin(t) + a * 10) * .5
                d = d - t * 2
                pix(x, y, color * (d % 2))
            end
        end
    end
end

function post()
    decay = .8
    for x = 0, 240 do
        c = 0
        for y = 0, 136 do
            cc = pix(x, y)
            if cc > c then
                c = cc
            else
                c = c * decay
            end
            pix(x, y, c)
        end
    end
end

function glitch()
    math.randomseed(time() * 0.001)
    for i = 0, math.random(0, 2) do
        x1 = math.random(0, 240)
        x2 = math.random(0, 240)
        w = math.random(5, 30)
        m = math.random(0, 1)
        if m == 0 then
            for x = 0, w do
                for y = 0, 136 do
                    c = pix(x1 + x, y)
                    pix(x2 + x, y, c)
                end
            end
        elseif m == 1 then
            for y = 0, 136 do
                c = pix(x1, y)
                for x = 0, w do
                    pix(x2 + x, y, c)
                end
            end
        elseif m == 2 then
            for y = 0, 136 do
                for x = 0, w do
                    pix(x2 + x, y, math.random(0, 1))
                end
            end
        end
    end
end

function TIC()
    cls(0)

    stars()
    post()
    glitch()
    bg(math.sin(2 + time() * 0.001) + time() * 0.001, 1)
    bg(math.sin(1 + time() * 0.001) + time() * 0.001, 3)

    math.randomseed(time() * 0.04)
    txt = "A rolling stone gathers momentum"
    x = 2 -- math.random(10,12)
    y = 128 -- math.random(10,12)
    print(txt, x - 1, y, 0)
    print(txt, x + 1, y, 0)
    print(txt, x, y - 1, 0)
    print(txt, x, y + 1, 0)
    print(txt, x - 1, y - 1, 0)
    print(txt, x - 1, y + 1, 0)
    print(txt, x + 1, y - 1, 0)
    print(txt, x + 1, y + 1, 0)
    print(txt, x, y, 12)
end
