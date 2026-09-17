copper_showdown_version = "0.4.0"
copper_showdown_api_version = "0.4.0"
code = '''
local logo = bobs[1]
local fl_grin = bobs[2]
local fl_you = bobs[3]
local fl_up = bobs[4]
local s0 = bobs[5]
local s90 = bobs[6]
local s180 = bobs[7]
local s270 = bobs[8]
local e_logo_64 = bobs[9]
local e_logo_128 = bobs[10]



local fl_c1_idx = 7
local fl_c2_idx = 8
local fl_c1 = logo.colors[fl_c1_idx+1]
local fl_c2 = logo.colors[fl_c2_idx+1]

flup_w = math.ceil(fl_up.width / 16 ) * 16
flup_h = fl_up.height
flower_w = math.ceil(fl_you.width / 16) * 16
flower_h = fl_you.height
flower_m = 8
num_bpls = 4
width = 320+flup_w

num_frames = flup_w
line_size = width // 8

newlist("setup")
    push({

        DDFSTOP, 0xd0,
        DIWSTRT, 0x2c81,
        DIWSTOP, 0x2cc1,

        BPLCON0, logo.num_bitplanes << 12,
    })

    for i,c in ipairs(logo.colors) do
        color(i-1, c)
    end

nextlist("frame0")

function lerp(s, e, f)
    return s + (e-s) * f
end

function yoff(f)
    return math.floor((math.sin(f/num_frames * math.pi*2) + 1) / 2 * flower_m)
end

function background(f)
    start_y = 0x11
    start_c = 0x22c
    end_c = 0xaaf
    
    floor_y = 0xb1
    color(0, start_c)
    for y=start_y, floor_y-1 do
        fac = (y - start_y) / (floor_y - start_y)
        
        
        r = math.floor(lerp(start_c >> 8 & 0xf, end_c >> 8 & 0xf, fac))
        g = math.floor(lerp(start_c >> 4 & 0xf, end_c >> 4 & 0xf, fac))
        b = math.floor(lerp(start_c >> 0 & 0xf, end_c >> 0 & 0xf, fac))
        
        c = r << 8 | g << 4 | b
        
        push(y << 8 | 0x11, 0xfffe)
        color(0, c)
        
        rcs = {0xf00, 0xf70, 0xff0, 0x0f0, 0x00f, 0x60f, 0xa0f}
        
        screen_y = y - 0x2c
        if screen_y > 0 and screen_y < flower_h + flower_m then
            push(y << 8 | 0x53, 0xfffe)
            xf = f
            for x=1, 16 do
                fy = yoff(xf)
                rfac = (screen_y-fy) / flower_h
                if rfac >= 0 and rfac < 1 then
                    rc = rcs[math.floor(rfac * #rcs) + 1]
                    color(0, rc)
                else
                    color(0, c)
                end
                xf = xf - 8
                
            end
            color(0, c)
        end
        
        
    end
    push(floor_y << 8 | 0x11, 0xfffe)
    
    floor_start_c = 0xafc
    floor_end_c = 0x1c3
    
    for y=floor_y, floor_y+80 do
        push((y & 0xff) << 8 | 0x11, 0xfffe)
        
        fac = (y - floor_y) / (floor_y+80 - floor_y) + 0.1
        r = math.floor(lerp(floor_start_c >> 8 & 0xf, floor_end_c >> 8 & 0xf, fac))
        g = math.floor(lerp(floor_start_c >> 4 & 0xf, floor_end_c >> 4 & 0xf, fac))
        b = math.floor(lerp(floor_start_c >> 0 & 0xf, floor_end_c >> 0 & 0xf, fac))
        
        c = r << 8 | g << 4 | b
        
        color(0, c)
        
    end
    

end



for f=0,num_frames-1 do
    newlist("frame"..f)
    
    if f == 0 then
        color(fl_c1_idx, fl_c1)
        color(fl_c2_idx, fl_c2)
    elseif f == num_frames//2 then
        color(fl_c1_idx, fl_c2)
        color(fl_c2_idx, fl_c1)
    end
    

    
    x = flup_w - f
    delay = f % 16
    ddf_offset = 0
    if x % 16 > 0 then
        ddf_offset = 8
    end
    
    bplmod = line_size * (logo.num_bitplanes - 1) + (width - 320) // 8
    push({
        BPLCON1, delay << 4 | delay,
        DDFSTRT, 0x38 - ddf_offset,
        BPL1MOD, bplmod - ddf_offset // 4,
        BPL2MOD, bplmod - ddf_offset // 4,
    })
    local reg_offset = BPL1PTH
    local bpl_offset = x // 8
    for b=1, logo.num_bitplanes do
        push_ptr(reg_offset, "screen+" .. bpl_offset)
        reg_offset = reg_offset + 4
        bpl_offset = bpl_offset + line_size
    end
    
    
    blit_w = flower_w + 16
    y = yoff(f)
    d = y * line_size * num_bpls + x//8
    
    blit({a="flower", ashift=x % 16, d="screen+" .. d, dmod=(width-blit_w)//8, amod=0, func="a", width_words=blit_w//16, height=flower_h*num_bpls})
    
    background(f)
    
    blit({adat=0, ashift=x % 16, d="screen+" .. d, dmod=(width-blit_w)//8, amod=0, func="a", width_words=blit_w//16, height=flower_h*num_bpls})
    nextlist("frame"..(f+1) % num_frames)
end

local border = {0x0, 0x0}
local logo_data = logo:imem16()

label("screen")

index = 1
dat = fl_up:imem16()
for y=1,256 do
    for b=1, logo.num_bitplanes do
        if y > 256 - flup_h then
            for n=1,width//flup_w do
                lindex = index
                for x=1,flup_w // 16 do
                    push(dat[lindex])
                    lindex = lindex + 1
                end
            end
            index = lindex
        else
            for x=1,width // 16 do
                push(0)
            end
        end
    end
end

label("flower")
dat = fl_you:imem16()
index = 1

for y=1, flower_h do
    for b=1,num_bpls do
        for x=1,flower_w//16 do
            push(dat[index])
            index = index + 1
        end
        push(0)
    end
end

return resolve(), DMAF_RASTER | DMAF_BLITTER'''
agnus = "ECS 1MiB"
denise = "OCS"

[[images]]
name = "Peace with flowers-final.png"
data = "data:image/png;base64,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"

[[images]]
name = "Flower closed eyes-final.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEMAAABaCAMAAADUzRsSAAAAAXNSR0IArs4c6QAAACdQTFRF7t0iERER/+4i3QARAGbMd4j/zO4A/5m77lWZRERE7jMid7sz/5kAQOJxRgAAAA10Uk5TAP///////////////y0EQa0AAAJJSURBVFiFtdjbkqwgDAVQM9rVPPj/3zvKNSQbCGhTdZ7aWScJEsBtGw4iGj80AJxzTxQP+LGsFGIZ4cSFrBnOLSFEeRoEYTWIvvcIjDRsSBCCogmTUQivQIPisBAXAgyiEmenFj2DPwEVQWhD/h8LhvwdIQNDEQj5vQGIWUNOmtGoEEQgAwUSXkqzAQIh+vODcCpjIwGJGYfhY24TAJFhhO7NsxaCV7ph5HVOHUIgIgxScygT4enADgJeJkj4QErInJHr4lIaxB2JeBQb/rf8WkhDPdkyXPhTiv88RtCISJMoRsEA0jdKBh3DwZ2Ip6KLCg1UU2Q0CtIKJBVywtB1AjPbmphWMql+e1by3LaMDrLHtbEPwgBIfk/3ONib2zLqmhDxHLyQiK86D/CFx9djtW55adMJB4VRumHqeN0exBBJ9LppiOgrENVSe129JuL2pU5DoG23idAQNznQtl4YvUmh/QlvZGWo34ABiP6mbUrlFUM08TXDPTYG5zFTUV8wRsdTwxF3dEqGRoWgS4Mg+od+wpcXQxhBSScLtJGTheCaNg6m2G5lalqOa4TFZ767Q+OgzwV8rJdU2b6PaNzDftGtC8qNJeQKai2Qje04q8mUu6yqyMQ3CKLzHsRLMh/I2UBmvmPEQHg2s8l0kBlDI0TTgXAklGQ6kFxXgcx9HdIIvYJMG6AmbyB3NrMf3TAyZyTkLMh8IHUoCZk1RD6LSB1KaNArCPF87B2+pawjtbL8qbko60Zo1llZRWLPPx9kw53HX9+9tP0D1PdK3vQe828AAAAASUVORK5CYII="

[[images]]
name = "Flower looking at u-final.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAE4AAABoCAMAAABogTYEAAAAAXNSR0IArs4c6QAAACdQTFRF7t0iERER/+4i3QARAGbMd4j/zO4A/5m77lWZRERE7jMid7sz/5kAQOJxRgAAAA10Uk5TAP///////////////y0EQa0AAALpSURBVGiBtdnblqsgDAZg44Xa93/h2YAckvwhgGwvOl2r8DVASNE5jqGLaKzdmEXPQ7vEgIVrj5e1PWDFgrcxtg2e0L4OV2jT4VG+YHCFY6162p2u1FRpyaPczAGL9jaFXNvo7nmsYQQBpxrZ3H2LpoiTjQaDwx5oMxhcaOtzZniA095HTnrfOBXeXk4v1yRHTnA2NxAeCM5OPJebCG6AQ/F3OCfz5jQzkVNtw0PFNYrqBTqc/y7wUfpQ11Fiv368np3Npb+rdGKakasci97PnFcDq57SeIC8Y/ZAjUyzXjQqL+HvD2rZQyU3eQUILlX8XQPdxQwurkjVGPd70wb0sblHc3W4Vhdbe8oyKO60++zmzLk7O5zVp7MUmmuSr8MZidJm7jnEUSdTwIZwud62mObKLkOf1qxrlB5XiwqxypCSnpIkCtTrw6OQrnfUvDl5crSrfKpNJktyDIhFyYfHxhuKlKi4qLzrydPlM77ywo5/LdBaqMGelWt/AVztrShkBsc8V4OzV2bO8exMboZLeKh6uEZxJaZ0NBGeWeBLspUMxMcsHp79ewHSGHI3+WNNycUweFCRnKndLFtjuzVOnFTaLeVNHko60dj6ojFOdvFOtM5SWAcvO7xeoji3ju42k9WwFxwE5fGz39ibXFWiuqng3HXDAmqfthEXHwp0qnELj3GD19BN/LiH7h/+O/dhsJ84cGtmndO3cROP3sAW0k8shjUVHpE6cvymOBLaIeObGSrpDUnyFDiuXddVQMo3bkdbJSa16xWpnndz4HOLemQtgs2X1Hdzi3Ahb/UBb6s13h7u2sxlb/VhtuRejz/X8Ot5bSs5YlyQxKrPh1fTj/jXfOIIJ+UcR2WPwRxaCE9r1+haAy4FqOdgyYuc0uZrSsPp/BnVwEYjHfFUWRFdVXBzW1imxDdNVb2PGvNUcCvFqt2cS7vB8uTAl7Tq8XEvYtWjLVj2apAb/puauQ1Y8miXlbx91sL1BzRBaCHc8v03AAAAAElFTkSuQmCC"

[[images]]
name = "Flower looking up-final.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAD8AAABrCAMAAAD3nqoMAAAAAXNSR0IArs4c6QAAACdQTFRF7t0iERER/+4i3QARAGbMd4j/zO4A/5m77lWZRERE7jMid7sz/5kAQOJxRgAAAA10Uk5TAP///////////////y0EQa0AAAJJSURBVFiF1dnJbsQgDABQ3EyUHPL/31vCamNDwE6lKYeqGuXZYJZJqXOaBgAqlyyc5wmqGNGmthqA4BjBpFe8pOe9rKd9R0/yru5zwE3WA+7NT22dkT8kZx5oGw2X+fjRgVs3xE1p/1taIvR4UukXyfYjVP7sD8mXAD/PXghAhh7irHoaAM5e/cQK3JOFB1Anf8pDfDjIVMa64IQQLD3gpRaKR86rNgT3UJ7Ntcfrv1mHrHwQZz4VMT1JN9BwE5Dal0xtgNhTvnaIh3vmcpWndz7m/sFjMQBgXf3BzpDe5k2TfjR+MgCUg6L1LIBUfITSr6gDj19dgE1e94MOyPwkaw6v13EAwmXfTqLI+/6gXyWkgNCAumupx5uRpG8eF/0B+47OA4E/+xJA5nzHCQHY1uXZRp6vO5Ze66W1wirY5XOeBZBq/U0exr5dum39tw0IZ17qKPUw9CD1E/sSIPBd/M706xmfVdTHAP7Tfe8NwH+GPNqQVwrg2+cDood4Foz85vGn4/3D8Sfi5U3gyh4GPofJo0/durX3qANjHwOg8gZ/zXvXngyw6Fm8VzyoPerA//QhQOOX/mqFXECDvyweuF/gtQDf4Nen7w/84qUF90vc7B1Qv3xpE712+Nwv8pf9+p1V8br01CuuzIIv3V/mVv9K94tf5qT7qgvH5JXpsVfdmfoXmPDmI705T3pLeuw1PPVfzYO3pd+s6c3d95OnvS6PXjl3Lt9IqNO7OHrbZb/FX/b0Bs5eqBXekt4Z05v+T/OCt6Z3z/wXDG48il8TdlUAAAAASUVORK5CYII="

[[images]]
name = "smiley-0.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAAlQTFRFAAAAAAAA/+4iKGZCqwAAAAN0Uk5TAP//RFDWIQAAAIhJREFUOI21k9sOwCAIQ8X//+glTm6lypNNtiz2pJAJY7jENJhEpokg0WYI2Atp/ERQPxAH34jUvb4ikQBZTwKyn4FFQEABMKAQGHADSIlXwDwCRBvAafAzTajEPrESFdASGsEBv4sLsNs8+9am/SH/xJHCy6xDGWKijxnV7xenX71+eX+ErP8Hw44FsBS9bAMAAAAASUVORK5CYII="

[[images]]
name = "smiley-90.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAAlQTFRFAAAAAAAA/+4iKGZCqwAAAAN0Uk5TAP//RFDWIQAAAIZJREFUOI2lk1EOwDAIQsvuf+hlXWpVaFgyf3mhWHWMXYgaqoArSiBZVkiTJ2L0QlQdRNDzjSD/p9FM6AAIQOorCT4A5f+4FywgxtBoBlAtArimxBY4ZVwW2YEAUIbyhAJEGylDA3qbFGOP6/csTsQet16YZOBXzi+tX3t/OP70/PG+iDj/G753BbC2c7TlAAAAAElFTkSuQmCC"

[[images]]
name = "smiley-180.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAAlQTFRFAAAAAAAA/+4iKGZCqwAAAAN0Uk5TAP//RFDWIQAAAIZJREFUOI2100sOwCAIBFCH+x+6XwWGoa7Kquk8CTEyhhdWDVWArRIkxopQfJMm91ZQ+T1iEQix6gE+65+IgGdcQOfmLXYA9gVOMUcsABHUfP6DuuTEMrhOIbXLAL+DN0pCABAognMGpQG9p9ogA8vXDn6SVPVRNnkjusWQ+X719sv7ELH+B7fcBbDWV66MAAAAAElFTkSuQmCC"

[[images]]
name = "smiley-270.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAAlQTFRFAAAAAAAA/+4iKGZCqwAAAAN0Uk5TAP//RFDWIQAAAIRJREFUOI2lk8EOwCAIQ+n+/6OX4IKAlR7GwYN9wYJgtgMRxgJ4IgiSZYY02RGhFyJ0cGLr3UjWvTz+Cs7kBQB5vRAKwOm/9DQshohi9wPSBSqygJTTpQnoNjB14erBz17FbJKWUYGhUf//wnodhx4urgMjR04PrR57vTh69fTyLoSs/wu88wWwqBisigAAAABJRU5ErkJggg=="

[[images]]
name = "elogo-64.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAAAQCAMAAACROYkbAAAAAXNSR0IArs4c6QAAAAZQTFRFAAAA////pdmf3QAAAAJ0Uk5TAP9bkSK1AAAAlUlEQVQ4jZ2TQRLAIAgDyf8/3UOFJMhYpx4sFrKCYsT1AO5jTVf6EwBIf1k5c42wICPKkgqPFAA4qAmodwFeswAQK2X8ThloYAG02jgAmNQOUL1WnKKMsi3tMNr+mkOdBzcdAX7oDgjNvfxeQruBNNeEGeCXoh1wCei30HLh36mErz5gGtWB3nKnTuyA2H2tlYe38H88mY0B5yD55vEAAAAASUVORK5CYII="

[[images]]
name = "elogo-128.png"
data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAAAhCAMAAAAmoFOyAAAAAXNSR0IArs4c6QAAAAZQTFRFAAAA////pdmf3QAAAAJ0Uk5TAP9bkSK1AAABNElEQVRYhcWUQXbDMAhE4f6X7iLti2A+FshxysoCwXyNEpk9EO7+xNiJ/v8ifBXA/4IAFMNpP1R13JJK39ryu1YhDzEFeCfXL+opAFziHMBx5DWA6qM9pp6XFkjLlS+kTwd9CoD17wGsybDh9akpGPotgEo/+bOslCxuyDNwUZTr9Q4g1gcAO/0ZAE5tAbA+H0+djhfcBigOeL28AJBT1ZtEg/3uA6S9zpFKAJD0aVDggMFVH7EJQNYv3nNqoKEVgOVEbpsCiP5NABsC2BQAE/JzKDxhgMx4CJBfmQMAdi7r4T/GKDoAcAMjB+Dm35MVIGYOHUAAuPsKAMy4AyD4y7QtgDn6uAPobe8CtC3Qyp5Xq5YjEhwBFARNgDbBWpA3p5RvAPROFdP66JX6N2I67rPqH4kf2kcIIrYFJi0AAAAASUVORK5CYII="
