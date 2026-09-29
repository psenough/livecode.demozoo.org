--[[ mt here, greets to everyone

amazing new talent compo! welcome to
you all, please make more intros!

so size coding is making as big a file as
as possible in an hour, right? --]] m = math
sin = m.sin
cos = m.cos
max = m.max
min = m.min
abs = m.abs
tau = m.pi * 2
rand = m.random

fh = {}
ps = {}
cs = {}
np = 100

for i = 0, 239 do
    fh[i] = 0
end

for i = 1, np do
    ps[i] = {
        x = rand() * 2 - 1,
        y = rand() * 2 - 1,
        z = rand() * 2 - 1
    }
end

function BDR(l)
    vbank(0)
    lm = 68 - abs(68 - l)
    for i = 0, 47 do
        poke(16320 + i, max(0, min(255, sin(i) ^ 2 * i * lm / 5.5)))
    end
    vbank(1)
    for i = 0, 47 do
        poke(16320 + i, max(0, min(255, sin(i) ^ 2 * i * lm / 5.5 + 10)))
    end
end

size = 200
mid = 0

function TIC()
    t = time() / 32
    vbank(0)
    -- cls()

    vbank(1)
    cls()

    for i = 0, 239 do
        fh[i] = fft(i) / 4 + fh[i] * 3 / 4
    end

    bass = 0
    for i = 0, 15 do
        bass = bass + fh[i]
    end
    for i = 16, 60 do
        mid = mid + fh[i]
    end
    mid = mid / 1.1
    high = 0
    for i = 61, 239 do
        high = high + fh[i]
    end
    high = high / 4

    cs = {}
    a = mid / 10 + t / 33
    a2 = bass / 2
    for i = 1, np do
        y1 = ps[i].y * cos(a) - ps[i].z * sin(a)
        z1 = ps[i].z * cos(a) + ps[i].y * sin(a)

        x = ps[i].x * cos(a2) - y1 * sin(a2)
        y = y1 * cos(a2) + ps[i].x * sin(a2)

        c = max(4, min(15, mid * (z1 + 1) / 2))
        s = 2 * (z1 + 1)
        cs[i] = {
            x = x,
            y = y,
            z = z1,
            c = c,
            s = s
        }
    end

    table.sort(cs, function(a, b)
        return a.z < b.z
    end)

    h2 = .2 + high / 2

    for i = 1, np do
        if cs[i].z < 0 then
            vbank(0)
            circ(120 + h2 * 120 * cs[i].x, 68 + 68 * cs[i].y, cs[i].s, cs[i].c)
        else
            vbank(1)
            circ(120 + h2 * 120 * cs[i].x, 68 + 68 * cs[i].y, cs[i].s, cs[i].c)
        end
    end
    vbank(0)

    -- lets do the twist again
    for i = 0, 239 do
        x = (i + t // 1) % 240
        fhx = (fh[(x - 1) % 240] + fh[(x) % 240] + fh[(x + 1) % 240]) / 3 * (.9 + x / 60)
        a = sin(t / 10) * x / 80

        d = size * fhx + 5 + 5 * bass

        cy = 68 + 10 * bass * sin(i / 110 + t / 12)

        y1 = d * sin(a)
        y2 = d * sin(a + tau / 4)
        y3 = d * sin(a + tau / 2)
        y4 = d * sin(a + tau * 3 / 4)

        d = d / 4

        if y1 < y2 then
            line(i, cy + y1, i, cy + y2, max(0, min(15, d)))
        end
        if y2 < y3 then
            line(i, cy + y2, i, cy + y3, max(0, min(15, d + 1)))
        end
        if y3 < y4 then
            line(i, cy + y3, i, cy + y4, max(0, min(15, d + 2)))
        end
        if y4 < y1 then
            line(i, cy + y4, i, cy + y1, max(0, min(15, d + 3)))
        end
    end
    vbank(0)

    for i = 0, 5000 do
        x = rand(240) - 1
        y = rand(136) - 1
        pix(x, y, max(0, min(15, pix(x, y) - 1)))
    end

    text = {"LOVEBYTE", "10-12th FEB", "Online", "lovebyte.party", "<3 alia", "<3 aldroid", "<3 evilpaul", "<3 tobach"}
    vbank(1)
    tt = t // 50
    tx = tt % #text + 1
    tl = print(text[tx], 0, -100, 15, false, 3)
    print(text[tx], 120 - tl / 2, 136 - 40 * bass, 15, false, 3)

end
