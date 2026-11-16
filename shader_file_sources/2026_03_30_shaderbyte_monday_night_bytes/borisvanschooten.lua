-- BORIS - randomly generated space invaders
-- Nonday Night Bytes 30 mar 2026

-- Constants

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi

H = 136
W = 240

SPR_SHEET_ADDR=0x4000*2

colschemes = {
  {2,1,9}, -- red purple blue
  {4,3,2}, -- yel orange red
  {6,7,4}, -- lgreen green YEL
  {5,6,2}, -- lgreen green RED
  {11,10,2}, -- lblue blue dblue
  {9,8,3}, -- lblue blue ORANGE
}


function genspr(idx,colsch)
  local baseadr = SPR_SHEET_ADDR + 2*64*idx
  local colscheme = colschemes[1 + colsch % #colschemes]
  for y=0,7 do
    for x=0,3 do
      local col = 0
      if rand(2) == 1 then
        col = colscheme[rand(#colscheme)]
      end
      poke4(baseadr+x+8*y,col)
      poke4(baseadr+(7-x)+8*y,col)
      poke4(baseadr+64+x+8*y,col)
      poke4(baseadr+64+(7-x)+8*y,col)
      if rand(4) == 1 then
        col = colscheme[rand(#colscheme)]
        poke4(baseadr+x+8*y,col)
        poke4(baseadr+(7-x)+8*y,col)
      end
    end
  end
end

NRSPR = 50
SPRY = 16
TOTALH = NRSPR*SPRY

for i=0,NRSPR do
  genspr(i,i)
end

NRSTR = 200
str = {}
for i=0,NRSTR do
  str[i] = {
    x = rand(W),
    y = rand(H),
    yspd = 0.01*rand(50),
    col = 12+rand(4)
  }
end

T = 0
function TIC()
  T = T + 1
  cls(0)
  for i=0,NRSTR do
    local st = str[i]
    pix(st.x,st.y,st.col)
    st.y = st.y + st.yspd
    if st.y > H then
      st.y = 0
    end
  end
  for y = 0,NRSPR do
    local ysin = (y / (NRSPR-1)) * 2*pi * 10
    for x = -4,4 do
      local xofs = 30*sin(T*0.016 + ysin*0.2)
                 + 10*sin(T*0.01 + ysin*0.62 + x *0.2)
                 + 5*sin(T*0.005+ysin*0.8)
      local yofs = T/2 + 4*sin(T*0.07 + ysin*0.32 + x*0.8)
                 + 8*sin(x*0.3 + ysin*0.22)
      local xpos = xofs+W/2 + 16*x
      local ypos = yofs+ SPRY*y
      ypos = ypos % (TOTALH-2*SPRY)
      spr(6+2*y+floor(T/10)%2, xpos, ypos-8, 0)
    end
  end
end

