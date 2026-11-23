t = 1314

w = 240
h = 136

line_rnd1 = 0
line_end2 = 0

rnd = math.random
mod = math.fmod
ceil = math.ceil
max = math.max
sin = math.sin
cos = math.cos

function TIC()
    
    for y = 0, h-1 do
        line_rnd1 = rnd()
        line_rnd2 = rnd()
        for x = 0, w-1 do
        
            xnorm = x / w
            ynorm = y / h
            
            ynorm = 1 - ynorm
            
            xnorm = xnorm + t * 0.01
            ynorm = ynorm + t * 0.007
            
            xnorm = -0.5 + xnorm * 2
            ynorm = -0.25 + ynorm * 1.5
            
            xnorm = mod(xnorm, 1)
            ynorm = mod(ynorm, 1)
            
            xnorm = -0.5 + xnorm * 2
            ynorm = -0.25 + ynorm * 1.5
            
            xnorm, ynorm = permute(xnorm, ynorm)
            
            local b = is_factory(xnorm, ynorm)
            
            if b then
             pix(x, y, 12)
            else
            local c = 15 + 1.6 * line_rnd2
                pix(x, y, c)
            end
        end
    end
    
    t=t+1
end

function is_factory(x, y)
    -- x and y are normalized (0..1)
    if x < 0 or x >= 1 then return false end
    if y < 0 or y >= 1 then return false end
    
    local k = mod(x, 0.25) + 0.5
    local p = ceil(1 - (4 * x))
    
    local m = max(k, p)
    
    return y < m
end

function permute(x, y)
    -- x and y are normalized (0..1)
    local tt = t * 0.1
    
    result_x = x + cos(y * 4 + tt) * 0.025
    result_y = y + sin(x * 8 + tt) * 0.015
    
    if math.abs(line_rnd1 - y) < 0.01 then
        result_x = result_x + 0.2 * (line_rnd2 - 0.5)
    end
    
    return result_x, result_y
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>