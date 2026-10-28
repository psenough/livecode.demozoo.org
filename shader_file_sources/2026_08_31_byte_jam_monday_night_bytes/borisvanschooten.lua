-- BORIS wireframe animations

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
T = 0

xofs = 0
yofs = 0
linecol = 12
xscale = 0.4
yscale = 0.4

function drawline(x1,y1,x2,y2)
  line(
    W/2 + xscale*(x1+xofs),
    H/2 + yscale*(y1+yofs),
    W/2 + xscale*(x2+xofs),
    H/2 + yscale*(y2+yofs), linecol)
end


function draw_five_arm_spiral(t)
	local cx = 0
	local cy = 0

	local arms = 5
	local steps = 64
	local max_radius = 66

	local turns = 0.85
	local spin = t * -0.035
	local wave = math.sin(t * 0.04) * 0.18

	local function px(x)
		return math.floor(x + 0.5)
	end

	for arm = 0, arms - 1 do
		local base_angle = arm * math.pi * 2 / arms + spin

		local last_x = cx
		local last_y = cy

		for i = 1, steps do
			local p = i / steps

			local radius = p * max_radius
			local angle = base_angle + p * turns * math.pi * 2

			angle = angle + math.sin(p * 10 + t * 0.05) * wave

			local x = cx + math.cos(angle) * radius
			local y = cy + math.sin(angle) * radius * 0.72

			drawline(px(last_x), px(last_y), px(x), px(y))

			last_x = x
			last_y = y
		end
	end

	-- Wireframe cross-links between the five spiral arms
	for i = 6, steps, 5 do
		local p = i / steps
		local radius = p * max_radius

		local first_x = nil
		local first_y = nil
		local last_x = nil
		local last_y = nil

		for arm = 0, arms - 1 do
			local base_angle = arm * math.pi * 2 / arms + spin
			local angle = base_angle + p * turns * math.pi * 2

			angle = angle + math.sin(p * 10 + t * 0.05) * wave

			local x = cx + math.cos(angle) * radius
			local y = cy + math.sin(angle) * radius * 0.72

			if last_x ~= nil then
				drawline(px(last_x), px(last_y), px(x), px(y))
			else
				first_x = x
				first_y = y
			end

			last_x = x
			last_y = y
		end

		drawline(px(last_x), px(last_y), px(first_x), px(first_y))
	end
end


function drawFish(t)
	local sin = math.sin
	local cos = math.cos
	local pi = math.pi
	local abs = math.abs
	local floor = math.floor
	local ceil = math.ceil

	local function round(v)
		if v >= 0 then
			return floor(v + 0.5)
		else
			return ceil(v - 0.5)
		end
	end

	local function l(x1, y1, x2, y2)
		drawline(round(x1), round(y1), round(x2), round(y2))
	end

	local time = t * 0.09

	local bodyLeft = -34
	local bodyRight = 42
	local bodyLength = bodyRight - bodyLeft

	local function midline(x)
		local fade = 1 - abs(x) / 52
		if fade < 0 then fade = 0 end
		return sin(time - x * 0.16) * 4 * fade
	end

	local function bodyHalfHeight(x)
		local u = (x - bodyLeft) / bodyLength
		if u < 0 then u = 0 end
		if u > 1 then u = 1 end

		local s = sin(pi * u)
		if s < 0 then s = 0 end

		return 18 * (s ^ 0.65)
	end

	local function topY(x)
		return midline(x) - bodyHalfHeight(x)
	end

	local function bottomY(x)
		return midline(x) + bodyHalfHeight(x)
	end

	-- Body outline
	local steps = 18

	local px = bodyLeft
	local py = topY(px)

	for i = 1, steps do
		local x = bodyLeft + bodyLength * i / steps
		local y = topY(x)
		l(px, py, x, y)
		px = x
		py = y
	end

	px = bodyLeft
	py = bottomY(px)

	for i = 1, steps do
		local x = bodyLeft + bodyLength * i / steps
		local y = bottomY(x)
		l(px, py, x, y)
		px = x
		py = y
	end

	-- Spine
	px = bodyLeft
	py = midline(px)

	for i = 1, steps do
		local x = bodyLeft + bodyLength * i / steps
		local y = midline(x)
		l(px, py, x, y)
		px = x
		py = y
	end

	-- Wireframe ribs
	for i = 2, steps - 2, 2 do
		local x = bodyLeft + bodyLength * i / steps
		l(x, topY(x), x, bottomY(x))
	end

	-- Tail animation
	local rootY = midline(bodyLeft)
	local tailSwing = sin(time * 1.9) * 12

	local baseTopX = bodyLeft
	local baseTopY = rootY - 7
	local baseBottomX = bodyLeft
	local baseBottomY = rootY + 7

	local tailTipX = bodyLeft - 32
	local tailTopY = rootY - 22 + tailSwing
	local tailBottomY = rootY + 22 + tailSwing

	local tailNotchX = bodyLeft - 15
	local tailNotchY = rootY + tailSwing * 0.65

	l(baseTopX, baseTopY, tailTipX, tailTopY)
	l(tailTipX, tailTopY, tailNotchX, tailNotchY)
	l(tailNotchX, tailNotchY, tailTipX, tailBottomY)
	l(tailTipX, tailBottomY, baseBottomX, baseBottomY)
	l(baseTopX, baseTopY, baseBottomX, baseBottomY)

	l(bodyLeft, rootY, tailNotchX, tailNotchY)
	l(baseTopX, baseTopY, tailNotchX, tailNotchY)
	l(baseBottomX, baseBottomY, tailNotchX, tailNotchY)

	-- Dorsal fin
	local d1x = -7
	local d2x = 14
	local dpx = 3
	local dpy = topY(dpx) - 12 - sin(time * 0.7) * 2

	l(d1x, topY(d1x), dpx, dpy)
	l(dpx, dpy, d2x, topY(d2x))
	l(d1x, topY(d1x), d2x, topY(d2x))
	l(dpx, dpy, 2, topY(2))

	-- Bottom fin
	local b1x = -6
	local b2x = 10
	local bpx = 1
	local bpy = bottomY(bpx) + 10 + sin(time * 0.8 + 1.5) * 2

	l(b1x, bottomY(b1x), bpx, bpy)
	l(bpx, bpy, b2x, bottomY(b2x))
	l(b1x, bottomY(b1x), b2x, bottomY(b2x))

	-- Side pectoral fin
	local finRootX = 15
	local finRootY = midline(finRootX) + 5
	local finTipX = 1
	local finTipY = finRootY + 20 + sin(time * 1.3 + 0.8) * 5

	l(finRootX, finRootY, finTipX, finTipY)
	l(finTipX, finTipY, finRootX + 9, finRootY + 5)
	l(finRootX + 9, finRootY + 5, finRootX, finRootY)

	-- Gill
	local gx = 24
	l(gx, topY(gx) + 4, gx - 3, midline(gx))
	l(gx - 3, midline(gx), gx, bottomY(gx) - 4)

	-- Eye as a small diamond
	local eyeX = 31
	local eyeY = midline(eyeX) - 6

	l(eyeX, eyeY - 3, eyeX + 3, eyeY)
	l(eyeX + 3, eyeY, eyeX, eyeY + 3)
	l(eyeX, eyeY + 3, eyeX - 3, eyeY)
	l(eyeX - 3, eyeY, eyeX, eyeY - 3)

	-- Mouth
	local noseY = midline(bodyRight)
	l(bodyRight, noseY, bodyRight - 8, noseY + 4)
end

function draw_wire_sphere(t)

  -- =========================
  -- Configurable parameters
  -- =========================
  local radius = 46
  local latitude_rings = 9
  local longitude_rings = 12
  local segments = 36

  local camera_distance = 140
  local perspective_strength = 1.0

  local rotation_x_speed = 0.018
  local rotation_y_speed = 0.026
  local rotation_z_speed = 0.011

  local center_x = 0
  local center_y = 0

  -- =========================
  -- Rotation values
  -- =========================
  local ax = t * rotation_x_speed
  local ay = t * rotation_y_speed
  local az = t * rotation_z_speed

  local sinx = math.sin(ax)
  local cosx = math.cos(ax)
  local siny = math.sin(ay)
  local cosy = math.cos(ay)
  local sinz = math.sin(az)
  local cosz = math.cos(az)

  -- =========================
  -- 3D rotate + project
  -- =========================
  local function project(x, y, z)

    -- Rotate around X axis
    local y1 = y * cosx - z * sinx
    local z1 = y * sinx + z * cosx
    local x1 = x

    -- Rotate around Y axis
    local x2 = x1 * cosy + z1 * siny
    local z2 = -x1 * siny + z1 * cosy
    local y2 = y1

    -- Rotate around Z axis
    local x3 = x2 * cosz - y2 * sinz
    local y3 = x2 * sinz + y2 * cosz
    local z3 = z2

    -- Perspective projection
    local scale = camera_distance / (camera_distance + z3 * perspective_strength)

    local sx = center_x + x3 * scale
    local sy = center_y + y3 * scale

    return sx, sy
  end

  -- =========================
  -- Draw latitude rings
  -- =========================
  for i = 1, latitude_rings do
    local lat = -math.pi / 2 + i * math.pi / (latitude_rings + 1)

    local ring_radius = radius * math.cos(lat)
    local y = radius * math.sin(lat)

    local first_x = nil
    local first_y = nil
    local prev_x = nil
    local prev_y = nil

    for j = 0, segments do
      local lon = j * math.pi * 2 / segments

      local x = ring_radius * math.cos(lon)
      local z = ring_radius * math.sin(lon)

      local sx, sy = project(x, y, z)

      if j == 0 then
        first_x = sx
        first_y = sy
      else
        drawline(prev_x, prev_y, sx, sy)
      end

      prev_x = sx
      prev_y = sy
    end
  end

  -- =========================
  -- Draw longitude rings
  -- =========================
  for i = 0, longitude_rings - 1 do
    local lon = i * math.pi * 2 / longitude_rings

    local first_x = nil
    local first_y = nil
    local prev_x = nil
    local prev_y = nil

    for j = 0, segments do
      local lat = -math.pi / 2 + j * math.pi / segments

      local ring_radius = radius * math.cos(lat)

      local x = ring_radius * math.cos(lon)
      local y = radius * math.sin(lat)
      local z = ring_radius * math.sin(lon)

      local sx, sy = project(x, y, z)

      if j == 0 then
        first_x = sx
        first_y = sy
      else
        drawline(prev_x, prev_y, sx, sy)
      end

      prev_x = sx
      prev_y = sy
    end
  end
end

function drawOctopus(t)
	-- configurable parameters
	local headCx = 0
	local headCy = -24
	local headRx = 34
	local headRy = 30
	local headSegments = 28

	local eyeOffsetX = 11
	local eyeY = -28
	local eyeSize = 3

	local mouthY = -13
	local mouthW = 9
	local mouthH = 4

	local tentacleCount = 8
	local tentacleBaseY = 0
	local tentacleSpread = 48
	local tentacleLength = 48
	local tentacleSegments = 8
	local tentacleWaveAmp = 8
	local tentacleWaveSpeed = 0.08
	local tentacleWaveFreq = 1.25

	local skirtSegments = 7
	local skirtY = -2

	local bobAmount = 3
	local bobSpeed = 0.06

	local wireLines = 5

	-- helpers
	local sin = math.sin
	local cos = math.cos
	local pi = math.pi

	local bob = sin(t * bobSpeed) * bobAmount

	local function round(v)
		if v >= 0 then
			return math.floor(v + 0.5)
		else
			return math.ceil(v - 0.5)
		end
	end

	local function line(x1, y1, x2, y2)
		drawline(round(x1), round(y1 + bob), round(x2), round(y2 + bob))
	end

	local function ellipse(cx, cy, rx, ry, a1, a2, steps)
		local px = cx + cos(a1) * rx
		local py = cy + sin(a1) * ry

		for i = 1, steps do
			local a = a1 + (a2 - a1) * i / steps
			local x = cx + cos(a) * rx
			local y = cy + sin(a) * ry
			line(px, py, x, y)
			px = x
			py = y
		end
	end

	-- head outline
	ellipse(headCx, headCy, headRx, headRy, 0, pi * 2, headSegments)

	-- simple wireframe curves on head
	for i = 1, wireLines do
		local k = (i - (wireLines + 1) / 2) / ((wireLines + 1) / 2)
		local x = k * headRx * 0.75

		line(x, headCy - headRy * 0.88, x * 0.65, headCy + headRy * 0.82)
	end

	for i = 1, 3 do
		local yy = headCy - headRy * 0.45 + i * 12
		local w = headRx * cos((yy - headCy) / headRy)
		line(-w, yy, w, yy)
	end

	-- eyes
	ellipse(-eyeOffsetX, eyeY, eyeSize, eyeSize, 0, pi * 2, 8)
	ellipse( eyeOffsetX, eyeY, eyeSize, eyeSize, 0, pi * 2, 8)

	-- mouth
	ellipse(0, mouthY, mouthW, mouthH, 0.15 * pi, 0.85 * pi, 8)

	-- lower skirt / webbing
	local lastX = -tentacleSpread * 0.5
	local lastY = skirtY

	for i = 1, skirtSegments do
		local u = i / skirtSegments
		local x = -tentacleSpread * 0.5 + tentacleSpread * u
		local y = skirtY + sin(u * pi) * 6
		line(lastX, lastY, x, y)
		lastX = x
		lastY = y
	end

	-- tentacles
	for i = 1, tentacleCount do
		local u = (i - 1) / (tentacleCount - 1)
		local baseX = -tentacleSpread * 0.5 + tentacleSpread * u
		local baseY = tentacleBaseY

		local side = u * 2 - 1
		local drift = side * 16

		local px = baseX
		local py = baseY

		for j = 1, tentacleSegments do
			local v = j / tentacleSegments

			local wave =
				sin(
					t * tentacleWaveSpeed +
					i * 0.85 +
					v * pi * tentacleWaveFreq
				) * tentacleWaveAmp

			local taper = 1 - v * 0.35

			local x =
				baseX +
				drift * v +
				wave * taper

			local y =
				baseY +
				tentacleLength * v +
				sin(t * tentacleWaveSpeed + i) * 3 * v

			line(px, py, x, y)

			-- small side wire cross pieces
			if j % 2 == 0 then
				local cross = 3 * taper
				line(x - cross, y, x + cross, y)
			end

			px = x
			py = y
		end
	end
end



function drawCamelWalkRight(t)
	-- Configurable parameters
	local centerX = 0
	local centerY = 0
	local scale = 1

	local walkSpeed = 0.16
	local stride = 9
	local legLift = 7
	local bodyBobAmount = 2
	local headBobAmount = 1.5

	local bodyY = 0
	local groundY = 43

	-- Animation phase
	local phase = t * walkSpeed
	local pi = math.pi

	local bodyBob = math.sin(phase * 2) * bodyBobAmount
	local headBob = math.sin(phase * 2 + 0.8) * headBobAmount

	-- Local transformed line drawer
	local function dl(x1, y1, x2, y2)
		drawline(
			centerX + x1 * scale,
			centerY + y1 * scale,
			centerX + x2 * scale,
			centerY + y2 * scale
		)
	end

	-- Animated leg drawer
	local function drawLeg(anchorX, anchorY, phaseOffset)
		local p = phase + phaseOffset
		local s = math.sin(p)
		local c = math.cos(p)

		local footX = anchorX + s * stride
		local lift = 0

		if c > 0 then
			lift = c * legLift
		end

		local footY = groundY - lift + bodyBob

		local kneeX = (anchorX + footX) * 0.5 + s * 4
		local kneeY = anchorY + (footY - anchorY) * 0.55

		if c > 0 then
			kneeY = kneeY - lift * 0.5
		end

		dl(anchorX, anchorY + bodyBob, kneeX, kneeY)
		dl(kneeX, kneeY, footX, footY)

		-- Small foot line
		dl(footX - 4, footY, footX + 5, footY)
	end

	-- Body outline
	dl(-43, 8 + bodyBob, -36, -2 + bodyBob)
	dl(-36, -2 + bodyBob, -29, -18 + bodyBob)
	dl(-29, -18 + bodyBob, -21, -24 + bodyBob)
	dl(-21, -24 + bodyBob, -13, -7 + bodyBob)

	dl(-13, -7 + bodyBob, -5, -8 + bodyBob)

	dl(-5, -8 + bodyBob, 3, -25 + bodyBob)
	dl(3, -25 + bodyBob, 13, -22 + bodyBob)
	dl(13, -22 + bodyBob, 21, -5 + bodyBob)

	dl(21, -5 + bodyBob, 34, 0 + bodyBob)
	dl(34, 0 + bodyBob, 40, 10 + bodyBob)

	-- Belly
	dl(-40, 12 + bodyBob, 38, 12 + bodyBob)

	-- Chest and rump
	dl(-43, 8 + bodyBob, -40, 12 + bodyBob)
	dl(40, 10 + bodyBob, 38, 12 + bodyBob)

	-- Wireframe body supports
	dl(-36, -2 + bodyBob, -26, 12 + bodyBob)
	dl(-13, -7 + bodyBob, -8, 12 + bodyBob)
	dl(21, -5 + bodyBob, 18, 12 + bodyBob)
	dl(34, 0 + bodyBob, 30, 12 + bodyBob)

	-- Neck
	dl(31, -1 + bodyBob, 42, -15 + bodyBob + headBob)
	dl(38, 6 + bodyBob, 49, -13 + bodyBob + headBob)

	-- Head
	dl(42, -15 + bodyBob + headBob, 55, -24 + bodyBob + headBob)
	dl(55, -24 + bodyBob + headBob, 68, -22 + bodyBob + headBob)
	dl(68, -22 + bodyBob + headBob, 74, -16 + bodyBob + headBob)
	dl(74, -16 + bodyBob + headBob, 64, -12 + bodyBob + headBob)
	dl(64, -12 + bodyBob + headBob, 49, -13 + bodyBob + headBob)

	-- Ear
	dl(57, -24 + bodyBob + headBob, 60, -32 + bodyBob + headBob)
	dl(60, -32 + bodyBob + headBob, 64, -24 + bodyBob + headBob)

	-- Face detail
	dl(66, -20 + bodyBob + headBob, 70, -18 + bodyBob + headBob)
	dl(70, -15 + bodyBob + headBob, 75, -14 + bodyBob + headBob)

	-- Tail
	local tailWave = math.sin(phase * 2.5) * 4
	dl(-43, 8 + bodyBob, -54, 2 + bodyBob + tailWave)
	dl(-54, 2 + bodyBob + tailWave, -58, 9 + bodyBob + tailWave)

	-- Legs
	drawLeg(-31, 12, 0)
	drawLeg(-15, 12, pi)
	drawLeg(13, 12, pi)
	drawLeg(31, 12, 0)

	-- Simple ground contact shadow / reference wire
	dl(-42, groundY + 2, 42, groundY + 2)
end



function drawRunningMan(t)
	-- Configurable parameters
	local cx = 0
	local cy = 0

	local scale = 1
	local speed = 0.18

	local body_len = 28 * scale
	local body_lean = 7 * scale

	local head_radius = 6 * scale
	local neck_to_head = 8 * scale

	local shoulder_width = 6 * scale
	local hip_width = 5 * scale

	local upper_arm_len = 12 * scale
	local lower_arm_len = 10 * scale
	local arm_swing = 0.95

	local thigh_len = 15 * scale
	local shin_len = 16 * scale
	local leg_swing = 0.9
	local knee_lift = 3 * scale

	local pi = math.pi
	local phase = t * speed

	-- Helpers
	local function iround(v)
		if v >= 0 then
			return math.floor(v + 0.5)
		else
			return math.ceil(v - 0.5)
		end
	end

	local function dl(x1, y1, x2, y2)
		drawline(
			iround(cx + x1),
			iround(cy + y1),
			iround(cx + x2),
			iround(cy + y2)
		)
	end

	local function draw_circle(x, y, r, segments)
		local last_x = x + r
		local last_y = y

		for i = 1, segments do
			local a = i * pi * 2 / segments
			local nx = x + math.cos(a) * r
			local ny = y + math.sin(a) * r

			dl(last_x, last_y, nx, ny)

			last_x = nx
			last_y = ny
		end
	end

	local function draw_leg(leg_phase, side_offset)
		local hip_x = side_offset
		local hip_y = 0

		local thigh_angle = pi / 2 - math.sin(leg_phase) * leg_swing
		local shin_angle = pi / 2 + math.sin(leg_phase + 1.15) * 1.05

		local knee_x = hip_x + math.cos(thigh_angle) * thigh_len
		local knee_y = hip_y + math.sin(thigh_angle) * thigh_len - math.max(0, math.sin(leg_phase)) * knee_lift

		local foot_x = knee_x + math.cos(shin_angle) * shin_len
		local foot_y = knee_y + math.sin(shin_angle) * shin_len

		local toe_x = foot_x + 6 * scale
		local toe_y = foot_y + 1 * scale

		dl(hip_x, hip_y, knee_x, knee_y)
		dl(knee_x, knee_y, foot_x, foot_y)
		dl(foot_x, foot_y, toe_x, toe_y)
	end

	local function draw_arm(arm_phase, side_offset)
		local shoulder_x = body_lean + side_offset
		local shoulder_y = -body_len + 4 * scale

		local swing = math.sin(arm_phase) * arm_swing

		local upper_angle = pi / 2 - swing
		local lower_angle = upper_angle + math.sin(arm_phase + pi / 2) * 0.8 - 0.25

		local elbow_x = shoulder_x + math.cos(upper_angle) * upper_arm_len
		local elbow_y = shoulder_y + math.sin(upper_angle) * upper_arm_len

		local hand_x = elbow_x + math.cos(lower_angle) * lower_arm_len
		local hand_y = elbow_y + math.sin(lower_angle) * lower_arm_len

		dl(shoulder_x, shoulder_y, elbow_x, elbow_y)
		dl(elbow_x, elbow_y, hand_x, hand_y)
	end

	-- Main body points
	local hip_x = 0
	local hip_y = 0

	local neck_x = body_lean
	local neck_y = -body_len

	local head_x = neck_x + 4 * scale
	local head_y = neck_y - neck_to_head

	local shoulder_left_x = neck_x - shoulder_width / 2
	local shoulder_left_y = neck_y + 4 * scale

	local shoulder_right_x = neck_x + shoulder_width / 2
	local shoulder_right_y = neck_y + 4 * scale

	local hip_left_x = hip_x - hip_width / 2
	local hip_left_y = hip_y

	local hip_right_x = hip_x + hip_width / 2
	local hip_right_y = hip_y

	-- Far limbs first
	draw_arm(phase, -2 * scale)
	draw_leg(phase + pi, -2 * scale)

	-- Torso
	dl(hip_x, hip_y, neck_x, neck_y)
	dl(shoulder_left_x, shoulder_left_y, shoulder_right_x, shoulder_right_y)
	dl(hip_left_x, hip_left_y, hip_right_x, hip_right_y)

	-- Head
	draw_circle(head_x, head_y, head_radius, 10)

	-- Small face direction line, pointing right
	dl(head_x + head_radius * 0.4, head_y, head_x + head_radius + 3 * scale, head_y + 1 * scale)

	-- Near limbs
	draw_arm(phase + pi, 2 * scale)
	draw_leg(phase, 2 * scale)
end






function draw_galaxy(t)
	-- configurable parameters
	local max_radius = 62
	local core_radius = 8
	local arm_count = 5
	local arm_segments = 42
	local arm_turns = 0.65
	local ring_count = 2
	local ring_segments = 56
	local tilt = 0.42
	local spin_speed = 0.025
	local ripple_amount = 0.08
	local ripple_speed = 0.035

	local pi = math.pi
	local sin = math.sin
	local cos = math.cos
	local floor = math.floor

	local spin = t * spin_speed

	local function iround(v)
		if v >= 0 then
			return floor(v + 0.5)
		else
			return -floor(-v + 0.5)
		end
	end

	local function project(r, a)
		local x = cos(a) * r
		local y = sin(a) * r * tilt
		return iround(x), iround(y)
	end

	-- wireframe rings
	for ring = 1, ring_count do
		local u = ring / ring_count
		local r = core_radius + u * (max_radius - core_radius)

		local px = nil
		local py = nil
		local first_x = nil
		local first_y = nil

		for i = 0, ring_segments do
			local a = (i / ring_segments) * pi * 2
			local wobble = sin(a * 3 + t * ripple_speed + r * 0.05) * ripple_amount
			local x, y = project(r, a + spin + wobble)

			if px ~= nil then
				drawline(px, py, x, y)
			else
				first_x = x
				first_y = y
			end

			px = x
			py = y
		end

		drawline(px, py, first_x, first_y)
	end

	-- spiral arms
	for arm = 0, arm_count - 1 do
		local base = spin + arm * pi * 2 / arm_count

		local px = nil
		local py = nil

		for i = 0, arm_segments do
			local u = i / arm_segments
			local r = core_radius + (u ^ 0.82) * (max_radius - core_radius)

			local spiral = u * arm_turns * pi * 2
			local ripple = sin(t * ripple_speed + u * 8 + arm) * ripple_amount
			local a = base + spiral + ripple

			local x, y = project(r, a)

			if px ~= nil then
				drawline(px, py, x, y)
			end

			px = x
			py = y
		end
	end

	-- small wireframe core
	local core_segments = 16
	local px = nil
	local py = nil
	local first_x = nil
	local first_y = nil

	for i = 0, core_segments do
		local a = (i / core_segments) * pi * 2 + spin * 1.8
		local r = core_radius + sin(a * 4 + t * 0.05) * 2
		local x, y = project(r, a)

		if px ~= nil then
			drawline(px, py, x, y)
		else
			first_x = x
			first_y = y
		end

		px = x
		py = y
	end

	drawline(px, py, first_x, first_y)
end



function drawButterfly(t)
	-- =========================
	-- Configurable parameters
	-- =========================
	local centerX = 0
	local centerY = 0

	local scale = 1

	local flapSpeed = 0.23
	local minWingSpan = 6
	local maxWingSpan = 25
	local wingFoldX = 6

	local leanSpeed = 0.045
	local maxLean = 0.10

	local showMotionLines = false
	local motionSpeed = 0.55
	local motionLineGap = 9

	local antennaWiggleSpeed = 0.13
	local antennaWiggleAmount = 1.5

	-- =========================
	-- Animation values
	-- =========================
	local phase = t * flapSpeed
	local beat = math.sin(phase)

	local open = 0.22 + 0.78 * math.abs(beat)
	local span = minWingSpan + maxWingSpan * open
	local foldX = beat * wingFoldX

	local lean = math.sin(t * leanSpeed) * maxLean
	local cr = math.cos(lean)
	local sr = math.sin(lean)

	local function round(n)
		if n >= 0 then
			return math.floor(n + 0.5)
		else
			return math.ceil(n - 0.5)
		end
	end

	local function lineLocal(x1, y1, x2, y2)
		local ax = centerX + ((x1 * cr - y1 * sr) * scale)
		local ay = centerY + ((x1 * sr + y1 * cr) * scale)

		local bx = centerX + ((x2 * cr - y2 * sr) * scale)
		local by = centerY + ((x2 * sr + y2 * cr) * scale)

		drawline(round(ax), round(ay), round(bx), round(by))
	end

	-- =========================
	-- Motion streaks
	-- Shows that the butterfly is flying right
	-- =========================
	if showMotionLines then
		local m = (t * motionSpeed) % motionLineGap

		lineLocal(-28 - m, -9, -19 - m, -9)
		lineLocal(-34 - m, 0, -23 - m, 0)
		lineLocal(-28 - m, 9, -19 - m, 9)
	end

	-- =========================
	-- Wing points
	-- Butterfly faces right, centered on (0,0)
	-- =========================
	local upperHingeX = 0
	local upperHingeY = -2

	local upperFrontX = 12 + foldX * 0.3
	local upperFrontY = -span * 0.50

	local upperTipX = 2 + foldX
	local upperTipY = -span

	local upperBackX = -12 + foldX * 0.4
	local upperBackY = -span * 0.62

	local upperRootX = -7
	local upperRootY = -3

	local lowerHingeX = 0
	local lowerHingeY = 2

	local lowerFrontX = upperFrontX
	local lowerFrontY = -upperFrontY

	local lowerTipX = upperTipX
	local lowerTipY = -upperTipY

	local lowerBackX = upperBackX
	local lowerBackY = -upperBackY

	local lowerRootX = upperRootX
	local lowerRootY = -upperRootY

	-- =========================
	-- Upper wing outline
	-- =========================
	lineLocal(upperHingeX, upperHingeY, upperFrontX, upperFrontY)
	lineLocal(upperFrontX, upperFrontY, upperTipX, upperTipY)
	lineLocal(upperTipX, upperTipY, upperBackX, upperBackY)
	lineLocal(upperBackX, upperBackY, upperRootX, upperRootY)
	lineLocal(upperRootX, upperRootY, upperHingeX, upperHingeY)

	-- Upper wing veins
	lineLocal(upperHingeX, upperHingeY, upperTipX, upperTipY)
	lineLocal(upperHingeX, upperHingeY, upperFrontX, upperFrontY)
	lineLocal(-3, -2, upperBackX, upperBackY)

	-- =========================
	-- Lower wing outline
	-- =========================
	lineLocal(lowerHingeX, lowerHingeY, lowerFrontX, lowerFrontY)
	lineLocal(lowerFrontX, lowerFrontY, lowerTipX, lowerTipY)
	lineLocal(lowerTipX, lowerTipY, lowerBackX, lowerBackY)
	lineLocal(lowerBackX, lowerBackY, lowerRootX, lowerRootY)
	lineLocal(lowerRootX, lowerRootY, lowerHingeX, lowerHingeY)

	-- Lower wing veins
	lineLocal(lowerHingeX, lowerHingeY, lowerTipX, lowerTipY)
	lineLocal(lowerHingeX, lowerHingeY, lowerFrontX, lowerFrontY)
	lineLocal(-3, 2, lowerBackX, lowerBackY)

	-- =========================
	-- Body
	-- =========================
	lineLocal(-14, 0, -6, -3)
	lineLocal(-6, -3, 7, -3)
	lineLocal(7, -3, 14, 0)
	lineLocal(14, 0, 7, 3)
	lineLocal(7, 3, -6, 3)
	lineLocal(-6, 3, -14, 0)

	-- Body center line
	lineLocal(-14, 0, 17, 0)

	-- Head / nose facing right
	lineLocal(11, -2, 16, 0)
	lineLocal(11, 2, 16, 0)

	-- =========================
	-- Antennae
	-- =========================
	local ant = math.sin(t * antennaWiggleSpeed) * antennaWiggleAmount

	lineLocal(14, -1, 20, -6 + ant)
	lineLocal(20, -6 + ant, 23, -8 + ant)

	lineLocal(14, 1, 20, 6 - ant)
	lineLocal(20, 6 - ant, 23, 8 - ant)

	-- =========================
	-- Small legs
	-- =========================
	lineLocal(-4, 3, -9, 7)
	lineLocal(1, 3, -2, 8)
	lineLocal(6, 3, 5, 8)

	lineLocal(-4, -3, -9, -7)
	lineLocal(1, -3, -2, -8)
	lineLocal(6, -3, 5, -8)
end



function draw_bouncing_wobbly_cube(t)
	-- configurable parameters
	local cx = 0              -- animation center X
	local cy = 0              -- animation center Y
	local size = 54           -- cube size
	local bounce_amp = 18     -- bounce height
	local bounce_speed = 0.09
	local wobble_amp = 0.16
	local wobble_speed = 0.13
	local rot_x_speed = 0.021
	local rot_y_speed = 0.033
	local rot_z_speed = 0.017
	local camera_dist = 115
	local perspective = 95

	local sin = math.sin
	local cos = math.cos
	local abs = math.abs
	local floor = math.floor

	local phase = t * bounce_speed

	-- bouncing motion, using Y as vertical axis
	local bounce = -abs(sin(phase)) * bounce_amp

	-- squash/stretch at impact
	local impact = 1.0 - abs(sin(phase))
	local squash_xz = 1.0 + impact * 0.18
	local squash_y = 1.0 - impact * 0.28

	local rx = t * rot_x_speed
	local ry = t * rot_y_speed
	local rz = t * rot_z_speed

	local sx = sin(rx)
	local cxr = cos(rx)
	local sy = sin(ry)
	local cyr = cos(ry)
	local sz = sin(rz)
	local czr = cos(rz)

	local h = size * 0.5

	local vertices = {
		{-1, -1, -1},
		{ 1, -1, -1},
		{ 1,  1, -1},
		{-1,  1, -1},
		{-1, -1,  1},
		{ 1, -1,  1},
		{ 1,  1,  1},
		{-1,  1,  1}
	}

	local edges = {
		{1,2}, {2,3}, {3,4}, {4,1},
		{5,6}, {6,7}, {7,8}, {8,5},
		{1,5}, {2,6}, {3,7}, {4,8}
	}

	local pts = {}

	for i = 1, 8 do
		local v = vertices[i]

		local x = v[1] * h
		local y = v[2] * h
		local z = v[3] * h

		-- per-corner wobble
		local w1 = sin(t * wobble_speed + i * 1.37)
		local w2 = sin(t * wobble_speed * 1.23 + i * 2.11)

		x = x * squash_xz + w1 * wobble_amp * size
		y = y * squash_y + w2 * wobble_amp * size + bounce
		z = z * squash_xz + w1 * wobble_amp * size * 0.7

		-- rotate around X
		local y1 = y * cxr - z * sx
		local z1 = y * sx + z * cxr
		y = y1
		z = z1

		-- rotate around Y
		local x1 = x * cyr + z * sy
		local z2 = -x * sy + z * cyr
		x = x1
		z = z2

		-- rotate around Z
		local x2 = x * czr - y * sz
		local y2 = x * sz + y * czr
		x = x2
		y = y2

		-- perspective projection
		local p = perspective / (z + camera_dist)

		local px = cx + x * p
		local py = cy + y * p

		pts[i] = {
			floor(px + 0.5),
			floor(py + 0.5)
		}
	end

	for i = 1, #edges do
		local a = edges[i][1]
		local b = edges[i][2]

		drawline(
			pts[a][1], pts[a][2],
			pts[b][1], pts[b][2]
		)
	end
end



funcs = {
  draw_five_arm_spiral,
  drawFish,
  draw_wire_sphere,
  drawOctopus,
  drawCamelWalkRight,
  drawRunningMan,
  draw_galaxy,
  drawButterfly,
  draw_bouncing_wobbly_cube,
}

function drawWireframe(func,t)
  func(t)
end

function TIC()
  T = T + 1
  cls(0)
  for i=0,2 do
    for f=1,#funcs do
      idx = 3*f + i
      linecol = 1 + f%12
      xofs = -2*W + (2.5*( T*(0.8+0.4*sin(idx)))
             + 210*(idx))%(4*W)
      yofs = -H+(idx*29)%(2*H)
      xscale = 0.35 + 0.05*i
      yscale = 0.35 + 0.05*i
      --xofs = 50*sin(0.05*T + 2.5*f)
      --yofs = 50*cos(0.05*T + 2.5*f)
      drawWireframe(funcs[f], T + 10.2*i)
      --draw_five_arm_spiral(T)
    end
  end
end


