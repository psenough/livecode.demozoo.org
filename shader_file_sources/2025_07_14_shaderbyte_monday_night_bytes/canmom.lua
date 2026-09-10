-- pos: 0,0
--hello mondaynightbytes!
--ok i think it's time to blow this thing
--get everybody and the stuff together
--ok
--3
--2
--1
--let's jam

WIDTH=240
HEIGHT=136
RADIUS=HEIGHT/3
TAU=3.14159265358979323846264*2
TEMP_ADDR = 0x04000
TEMP_NIBL = 2 * TEMP_ADDR
FLOWFIELD = 0x08000
FLOW_NIBL = 2 * FLOWFIELD
PALETTE_ADDR = 0x03FC0
DAMPING = 0.6

old_vqt = {}
bank = 0
agents = {}

function BOOT()
  cls()
  for bin = 1, 120 do
    old_vqt[bin] = 0
  end
  poke(PALETTE_ADDR, 0x11)
  poke(PALETTE_ADDR+1, 0x18)
  poke(PALETTE_ADDR+2, 0x24)
  for c=1,15 do
    poke(PALETTE_ADDR+3*c,math.min(0x22+0x11*c,0xFF))
    poke(PALETTE_ADDR+3*c+1,math.min(0x11+0x10*c,0xFF))
    poke(PALETTE_ADDR+3*c+2,math.min(0x44+0x15*c,0xFF))
  end
  for bin = 0, 120 do
    local stepangle = bin*TAU/120
    local c = math.cos(stepangle)
    local s = math.sin(stepangle)
    local x = WIDTH/2 + RADIUS*c
    local y = HEIGHT/2 + RADIUS*s
    agents[bin]=
      {
       x = x,
       y = y,
       vx = 0,
       vy = 0,
       startx = x,
       starty = y
      }
  end
end


function TIC()
  --copy the vram bank to temporary memory
  memcpy(TEMP_ADDR, 0x00000, WIDTH*HEIGHT/2)
  
  for x = 0, WIDTH-1 do
    for y = 0, HEIGHT-1 do
      local offset_x = math.min(math.max(0,x + math.random(-2, 1)),WIDTH-1)
      local offset_y = math.min(math.max(0,y + math.random(0, 2)),HEIGHT-1)
      local addr = y * WIDTH + x
      local offset_addr = TEMP_NIBL+offset_y*WIDTH+offset_x
      local oldpix = peek4(offset_addr)
      if math.random() > 0.5 then
        oldpix = oldpix - 1
      end
      poke4(addr, math.max(oldpix,0))
    end
  end

  for bin = 0, 120 do
    v = vqt(bin);
    local agent = agents[bin]
    agent.x = (agent.x + agent.vx)
    agent.y = (agent.y + agent.vy)
    local rx = agent.x - WIDTH/2
    local ry = agent.y - HEIGHT/2
    local r2 = rx * rx + ry * ry
    local r4 = r2 * r2
    local r = math.sqrt(r2)
    local rxn = rx/r
    local ryn = ry/r
    local grav = -50/r2
    agent.vx = agent.vx + grav * rxn + 10 * v * ryn
    agent.vy = agent.vy + grav * ryn - 10 * v * rxn
    agent.vx = DAMPING * agent.vx
    agent.vy = DAMPING * agent.vy
    pix(agent.x, agent.y, 15)
    if math.random() + v < 0.02 then
      agent.x = agent.startx
      agent.y = agent.starty
      agent.vx = 0
      agent.vy = 0
    end
    agents[bin] = agent
  end
end
