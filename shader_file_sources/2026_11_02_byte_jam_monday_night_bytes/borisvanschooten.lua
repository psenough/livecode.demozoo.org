-- BORIS



sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi


H = 136
W = 240
T = 0


FONT1 = 0x14604*8
FONT2 = 0x14A04*8
SPR = 0x4000*2


TICPAL = {
  {  26,  28,  44}, -- #1a1c2c
  {  93,  39,  93}, -- #5d275d
  { 177,  62,  83}, -- #b13e53
  { 239, 125,  87}, -- #ef7d57
  { 255, 205, 117}, -- #ffcd75
  { 167, 240, 112}, -- #a7f070
  {  56, 183, 100}, -- #38b764
  {  37, 113, 121}, -- #257179
  {  41,  54, 111}, -- #29366f
  {  59,  93, 201}, -- #3b5dc9
  {  65, 166, 246}, -- #41a6f6
  { 115, 239, 247}, -- #73eff7
  { 244, 244, 244}, -- #f4f4f4
  { 148, 176, 194}, -- #94b0c2
  {  86, 108, 134}, -- #566c86
  {  51,  60,  87}, -- #333c57
}

bayer4x4 = {
     0,  8,  2, 10,
    12,  4, 14,  6,
     3, 11,  1,  9,
    15,  7, 13,  5
}


local function initializeDitherLUT(palette)
    if type(palette) ~= "table" or #palette ~= 16 then
        error("palette must contain exactly 16 RGB colors")
    end

    local function srgbToLinear(value)
        local normalized = value / 255

        if normalized <= 0.04045 then
            return normalized / 12.92
        end

        return ((normalized + 0.055) / 1.055) ^ 2.4
    end

    local function validateComponent(value, colorIndex, componentName)
        if type(value) ~= "number" then
            error(
                "palette color "
                    .. colorIndex
                    .. " component "
                    .. componentName
                    .. " must be a number"
            )
        end

        if value < 0 or value > 255 then
            error(
                "palette color "
                    .. colorIndex
                    .. " component "
                    .. componentName
                    .. " must be between 0 and 255"
            )
        end
    end

    -- Convert the palette to linear RGB once.
    local linearPalette = {}

    for index = 1, 16 do
        local color = palette[index]

        if type(color) ~= "table" or #color < 3 then
            error("palette color " .. index .. " must be {r, g, b}")
        end

        local red = color[1]
        local green = color[2]
        local blue = color[3]

        validateComponent(red, index, "red")
        validateComponent(green, index, "green")
        validateComponent(blue, index, "blue")

        linearPalette[index] = {
            srgbToLinear(red),
            srgbToLinear(green),
            srgbToLinear(blue)
        }
    end

    -- Precompute the 16 possible values for each 4-bit component.
    -- A 4-bit value is expanded to 8 bits by multiplying it by 17.
    local linearLevels = {}

    for value4 = 0, 15 do
        linearLevels[value4] = srgbToLinear(value4 * 17)
    end

    -- Precompute all unordered palette-color pairs.
    local pairs = {}
    local pairCount = 0

    for firstIndex = 1, 16 do
        local first = linearPalette[firstIndex]

        for secondIndex = firstIndex, 16 do
            local second = linearPalette[secondIndex]

            local deltaRed = second[1] - first[1]
            local deltaGreen = second[2] - first[2]
            local deltaBlue = second[3] - first[3]

            local lengthSquared =
                deltaRed * deltaRed
                + deltaGreen * deltaGreen
                + deltaBlue * deltaBlue

            pairCount = pairCount + 1

            pairs[pairCount] = {
                firstIndex = firstIndex,
                secondIndex = secondIndex,

                firstRed = first[1],
                firstGreen = first[2],
                firstBlue = first[3],

                deltaRed = deltaRed,
                deltaGreen = deltaGreen,
                deltaBlue = deltaBlue,

                lengthSquared = lengthSquared
            }
        end
    end

    local ditherLUT = {}

    for red4 = 0, 15 do
        local targetRed = linearLevels[red4]

        for green4 = 0, 15 do
            local targetGreen = linearLevels[green4]

            for blue4 = 0, 15 do
                local targetBlue = linearLevels[blue4]

                local bestError = math.huge
                local bestFirstIndex = 1
                local bestSecondIndex = 1
                local bestSecondCount = 0
                local bestPairDistance = math.huge

                for pairIndex = 1, pairCount do
                    local pair = pairs[pairIndex]

                    local blendAmount

                    if pair.lengthSquared > 0 then
                        -- Project the target color onto the line segment
                        -- between the two palette colors.
                        blendAmount =
                            (
                                (targetRed - pair.firstRed) * pair.deltaRed
                                + (targetGreen - pair.firstGreen) * pair.deltaGreen
                                + (targetBlue - pair.firstBlue) * pair.deltaBlue
                            )
                            / pair.lengthSquared

                        if blendAmount < 0 then
                            blendAmount = 0
                        elseif blendAmount > 1 then
                            blendAmount = 1
                        end
                    else
                        blendAmount = 0
                    end

                    -- Quantize the blend to the 16-pixel Bayer coverage.
                    -- The count can be from 0 through 16, inclusive.
                    local secondCount = math.floor(blendAmount * 16 + 0.5)

                    if secondCount < 0 then
                        secondCount = 0
                    elseif secondCount > 16 then
                        secondCount = 16
                    end

                    local quantizedBlend = secondCount / 16

                    local blendedRed =
                        pair.firstRed + pair.deltaRed * quantizedBlend

                    local blendedGreen =
                        pair.firstGreen + pair.deltaGreen * quantizedBlend

                    local blendedBlue =
                        pair.firstBlue + pair.deltaBlue * quantizedBlend

                    local redError = targetRed - blendedRed
                    local greenError = targetGreen - blendedGreen
                    local blueError = targetBlue - blendedBlue

                    local error =
                        redError * redError
                        + greenError * greenError
                        + blueError * blueError

                    -- If two pairs give effectively the same average color,
                    -- prefer the pair whose colors are closer together. This
                    -- generally produces less objectionable dithering.
                    local isBetter =
                        error < bestError - 1e-15
                        or (
                            math.abs(error - bestError) <= 1e-15
                            and pair.lengthSquared < bestPairDistance
                        )

                    if isBetter then
                        bestError = error
                        bestFirstIndex = pair.firstIndex
                        bestSecondIndex = pair.secondIndex
                        bestSecondCount = secondCount
                        bestPairDistance = pair.lengthSquared
                    end
                end

                -- Zero-based conceptual offset. Add one for Lua's arrays.
                local baseOffset =
                    (((red4 * 16) + green4) * 16 + blue4) * 16

                for phase = 0, 15 do
                    local threshold = bayer4x4[phase + 1]

                    if threshold < bestSecondCount then
                        ditherLUT[baseOffset + phase + 1] =
                            bestSecondIndex
                    else
                        ditherLUT[baseOffset + phase + 1] =
                            bestFirstIndex
                    end
                end
            end
        end
    end

    return ditherLUT
end



function hsv_to_rgb(h, s, v, a)
    if (s < 0) then s=0 end
    if (s > 1) then s=1 end
    if (v < 0) then v=0 end
    if (v > 1) then v=1 end
    local c = v * s
    h = (h * 6.0) % 6.0
    local x = c * (1.0 - math.abs(h % 2.0 - 1.0))

    local color = { 0, 0, 0, a }

    if 0.0 <= h and h < 1.0 then
        color[1] = c
        color[2] = x
        color[3] = 0
    elseif 1.0 <= h and h < 2.0 then
        color[1] = x
        color[2] = c
        color[3] = 0
    elseif 2.0 <= h and h < 3.0 then
        color[1] = 0
        color[2] = c
        color[3] = x
    elseif 3.0 <= h and h < 4.0 then
        color[1] = 0
        color[2] = x
        color[3] = c
    elseif 4.0 <= h and h < 5.0 then
        color[1] = x
        color[2] = 0
        color[3] = c
    else
        color[1] = c
        color[2] = 0
        color[3] = x
    end

    local m = v - c
    color[1] = color[1] + m
    color[2] = color[2] + m
    color[3] = color[3] + m

    return color
end

function rgbpix(x,y,r4,g4,b4)
    if r4 < 0 then
      r4 = 0
    else
      if r4 > 15 then r4 = 15 end
    end
    if g4 < 0 then
      g4 = 0
    else 
      if g4 > 15 then g4 = 15 end
    end
    if b4 < 0 then
      b4 = 0
    else 
      if b4 > 15 then b4 = 15 end
    end
    local phase = (floor(y) % 4) * 4 + (floor(x) % 4)

    local index =
        (((floor(r4)*16) + floor(g4))*16 + floor(b4))*16
        + phase + 1
    --pix(x,y,ditherLUT[index] - 1)
    local col = ditherLUT[index] - 1
    if col > 0 then pix(x,y,col) end
    --return ditherLUT[index] - 1
end

-- rgb not clamped for speed
function rgbpixraw(x,y,r4,g4,b4)
    local phase = (floor(y) % 4) * 4 + (floor(x) % 4)

    local index =
        (((floor(r4)*16) + floor(g4))*16 + floor(b4))*16
        + phase + 1
    local col = ditherLUT[index] - 1
    if col > 0 then pix(x,y,col) end
    --pix(x,y,ditherLUT[index] - 1)
    --return ditherLUT[index] - 1
end


---------------------------------------------------
-- pix buffer functions

rgbpx = {}

function clearrgbpixbuf()
  for y=0,H do
    for x=0,W do
      rgbpx[x+W*y] = {0,0,0}
    end
  end
end


function getrgbpixbuf(x,y)
  if x<0 or y<0 or x>=W or y>=H then return {0,0,0} end
  return rgbpx[floor(x)+W*floor(y)]
end

function setrgbpixbuf(x,y,r,g,b)
  if x<0 or y<0 or x>=W or y>=H then return end
  rgbpx[floor(x)+W*floor(y)] = {r,g,b}
end
-- set pixel with transparency
function setrgbpixbuf_tr(x,y,r,g,b,mask)
  if x<0 or y<0 or x>=W or y>=H then return end
  if r==mask[1] and g==mask[2] and b==mask[3] then return end
  rgbpx[floor(x)+W*floor(y)] = {r,g,b}
end
-- blend pixels using add
function addrgbpixbuf(x,y,r,g,b)
  if x<0 or y<0 or x>=W or y>=H then return end
  local pixidx = floor(x) + W*floor(y)
  local oldpix = rgbpx[pixidx]
  rgbpx[pixidx] = {oldpix[1]+r, oldpix[2]+g, oldpix[3]+b}
end


function renderrgbpixbuf()
  for y=0,H do
    local phasey = floor(y)%4*4
    for x=0,W do
      local phase = phasey + (floor(x) % 4)
      local px = rgbpx[x + W*y]
      -- assuming rgb values are never < 0
      if px[1] > 15 then px[1] = 15 end
      if px[2] > 15 then px[2] = 15 end
      if px[3] > 15 then px[3] = 15 end
      local index =
        (((floor(px[1])*16)
          + floor(px[2]))*16
          + floor(px[3]))*16
        + phase + 1
      -- skip black, assumes cls(0) is called before drawing
      if index==0 then return end
      local col = ditherLUT[index] - 1
      pix(x,y,col)
    end
  end
end



ditherLUT = initializeDitherLUT(TICPAL)



---------------------------------------------------
-- demo specific code

function drawSphere(cenx,ceny,size,r,g,b)
  for x=-size,size do
    for y=-size,size do
      d = (size-sqrt(x*x + y*y))/size
      if d > 0 then
        if d > 0.8 then
          addrgbpixbuf(cenx+x, ceny+y, 15*d*r, 15*d*g,15*d*b)
        else
          d = 2+5*d
          addrgbpixbuf(cenx+x, ceny+y, r*d, g*d,b*d)
        end
      end
    end
  end
end


text = "Hello world - Monday night bytes - 012345678901234567890"
text = "Jammin' the Monday night away - Keep hacking - Monday night lights "
tzoom = 4
nrchars = 11




function texturepix(x, y, t)
    local function clamp(value, minimum, maximum)
        if value < minimum then
            return minimum
        elseif value > maximum then
            return maximum
        end
        return value
    end

    local function mix(a, b, amount)
        return a + (b - a) * amount
    end

    local function random(px, py, pt)
        local value = math.sin(
            px * 12.9898 +
            py * 78.233 +
            pt * 19.137
        ) * 43758.5453

        return value - math.floor(value)
    end

    -- Coordinates centered horizontally, with height measured from the bottom.
    local nx = (x - 12) / 12
    local height = (24 - y) / 24

    -- A dim blue-purple background that slowly changes over time.
    local backgroundNoise = random(x, y, math.floor(t / 5))
    local bgR = 2 + backgroundNoise
    local bgG = 4 + backgroundNoise * 2
    local bgB = 8 + backgroundNoise * 3

    -- Make the flame sway, especially near its tip.
    local sway =
        math.sin(t * 0.13 + height * 5.5) * 0.09 * height +
        math.sin(t * 0.07 + height * 10.0) * 0.035

    local turbulence =
        math.sin(x * 1.7 + y * 0.8 + t * 0.31) * 0.6 +
        math.sin(x * 0.7 - y * 1.3 + t * 0.19) * 0.4

    -- The flame becomes narrower toward the top.
    local width =
        0.72 * math.pow(clamp(1 - height, 0, 1), 0.62) +
        0.035 +
        turbulence * 0.035 * (0.3 + height)

    local distance = math.abs(nx - sway)

    -- Vary the maximum flame height to make the tip dance.
    local flameTop =
        0.90 +
        math.sin(t * 0.17) * 0.055 +
        math.sin(t * 0.09 + x * 0.8) * 0.025

    if height > flameTop or distance > width then
        return {
            math.floor(clamp(bgR + 0.5, 0, 15)),
            math.floor(clamp(bgG + 0.5, 0, 15)),
            math.floor(clamp(bgB + 0.5, 0, 15))
        }
    end

    -- Higher heat values occur near the center and base of the flame.
    local radialHeat = clamp(1 - distance / width, 0, 1)
    local heat = clamp(
        radialHeat * 0.72 +
        (1 - height) * 0.28 +
        turbulence * 0.035,
        0,
        1
    )

    -- Slowly cycle between orange, pink and violet flame colors.
    local colourCycle = (math.sin(t * 0.08) + 1) * 0.5
    local fastCycle = (math.sin(t * 0.15 + height * 4) + 1) * 0.5

    local outerR = mix(10, 14, colourCycle)
    local outerG = mix(4, 2, colourCycle)
    local outerB = mix(2, 7, colourCycle)

    local middleR = 15
    local middleG = mix(8, 5, colourCycle)
    local middleB = mix(2, 9, fastCycle * colourCycle)

    local coreR = 15
    local coreG = mix(13, 10, colourCycle)
    local coreB = mix(5, 12, colourCycle)

    local flameR
    local flameG
    local flameB

    if heat < 0.5 then
        local amount = heat * 2
        flameR = mix(outerR, middleR, amount)
        flameG = mix(outerG, middleG, amount)
        flameB = mix(outerB, middleB, amount)
    else
        local amount = (heat - 0.5) * 2
        flameR = mix(middleR, coreR, amount)
        flameG = mix(middleG, coreG, amount)
        flameB = mix(middleB, coreB, amount)
    end

    -- Soften the flame edge by blending it into the background.
    local edge = clamp((width - distance) * 18, 0, 1)

    local r = mix(bgR, flameR, edge)
    local g = mix(bgG, flameG, edge)
    local b = mix(bgB, flameB, edge)

    return {
        math.floor(clamp(r + 0.5, 0, 15)),
        math.floor(clamp(g + 0.5, 0, 15)),
        math.floor(clamp(b + 0.5, 0, 15))
    }
end





function TIC()
  cls(0)
  clearrgbpixbuf()
  local scale1 = 0.8 + 0.4*sin(T*0.04)
  local scale2 = 0.8 + 0.4*sin(T*0.012)
  local bright = 0.7 + 0.2*sin(T*0.03)
  for x=0,W do
      --local f = fft(100)
      local hue = hsv_to_rgb(
       -0.1+0.25*sin(0.01*(T+x)),--0.02*T+0.005*x,
        1,--0.5+0.5*sin(-0.05*T+0.05*x),
        1,1)
        --0.5+0.5*sin(0.034*T+0.3*x),
        --0.6-0.4*sin(0.024*T+0.23*x),
        --1)
      for y=0,H do
        local lum = 0.25+0.25*sin(T*0.12 - 0.0532*scale1*x + 0.02*scale1*y)
                + 0.25+0.25*sin(T*0.07 + 0.08*scale2*x + 0.042*scale2*y)
        lum = lum*bright
        setrgbpixbuf(x,y,
          lum*15*hue[1],
          lum*15*hue[2],
          lum*15*hue[3])
    end
  end

  local totalofsraw = 2*T
  local totalofs = (totalofsraw) %  (tzoom*6*#text)
  local charofs = floor(totalofs/(tzoom*6))
  local pixofs = totalofs % (tzoom*6) 
  for ii=0,#text-1 do
    local i = (ii + charofs) % #text
    local c = string.byte(text,i+1,i+2)
    local dx = ii%nrchars
    local dy = floor(ii/nrchars)
    for yy=0,7*tzoom do
      local y = floor(yy / tzoom)
      for xx=0,5*tzoom do
        local x = floor(xx / tzoom)
        local fontpix = peek1(FONT1+64*c+x+8*y)
        if fontpix == 1 then
          col = texturepix((T+xx)%(6*tzoom),yy,T+20*i)
          setrgbpixbuf(
              -pixofs + xx + tzoom*6*dx,
              yy + tzoom*7*dy,
              col[1],col[2],col[3])
        end
      end
    end
  end



  renderrgbpixbuf()
  --pix(T,T,12)
  T = T + 1
end


