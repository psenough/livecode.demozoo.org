-- pos: 0,0
--hello all!
--starting from scratch this week
--thanks for DJing Lynn! :D

WIDTH=240
HEIGHT=136
TAU=3.14159265358979323846264*2
TEMP_ADDR = 0x04000
TEMP_NIBL = 2 * TEMP_ADDR
PALETTE_ADDR = 0x03FC0

old_vqt = {}
bank = 0

function BOOT()
  cls()
  for bin = 1, 120 do
    old_vqt[bin] = 0
  end
  poke(PALETTE_ADDR, 0x11)
  poke(PALETTE_ADDR+1, 0x18)
  poke(PALETTE_ADDR+2, 0x24)
  for c=1,15 do
    poke(PALETTE_ADDR+3*c,math.min(0x44+0x22*c,0xFF))
    poke(PALETTE_ADDR+3*c+1,math.min(0x11+0x18*c,0xFF))
    poke(PALETTE_ADDR+3*c+2,math.min(0x11+0x11*c,0xFF))
  end
end


function TIC()
  --copy the vram bank to temporary memory
  memcpy(TEMP_ADDR, 0x00000, WIDTH*HEIGHT/2)
  
  for x = 0, WIDTH-1 do
    for y = 0, HEIGHT-1 do
      local offset_x = math.min(math.max(0,x + math.random(-2, 1)),WIDTH-1)
      local offset_y = math.min(math.max(0,y + math.random(-1, 2)),HEIGHT-1)
      local addr = y * WIDTH + x
      local offset_addr = offset_y*WIDTH+offset_x
      local oldpix = peek4(offset_addr)
      if math.random() > 0.8 then
        oldpix = oldpix - 1
      end
      poke4(addr, math.max(oldpix,0))
    end
  end
  for bin = 1,120 do
    local angle = TAU*bin/120
    local x = WIDTH/2 + HEIGHT/2.5 *(math.cos(angle))
    local y = HEIGHT/2 + 10 + HEIGHT/2.5 *(math.sin(angle))
    local v = old_vqt[bin]
    rect(x, y-v, 1, v, 12)
    local v = vqt(bin)*HEIGHT/4
    old_vqt[bin] = v
    rect(x, y-v, 1, v, 15)
  end
end
