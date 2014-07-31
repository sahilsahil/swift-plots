-- miss.lua
-- find final local minimum distance of asteroid to Earth

miss = {}

-- 3rd order polynomial (Lagrange) interpolation from four points
local function cube(x_1, t_1, x_2, t_2, x_3, t_3, x_4, t_4, t)
	local a_1 = x_1 / ((t_1-t_2) * (t_1-t_3) * (t_1-t_4))
	local a_2 = x_2 / ((t_2-t_1) * (t_2-t_3) * (t_2-t_4))
	local a_3 = x_3 / ((t_3-t_1) * (t_3-t_2) * (t_3-t_4))
	local a_4 = x_4 / ((t_4-t_1) * (t_4-t_2) * (t_4-t_3))
	
	return a_1 * (t-t_2) * (t-t_3) * (t-t_4)
		+ a_2 * (t-t_1) * (t-t_3) * (t-t_4)
		+ a_3 * (t-t_1) * (t-t_2) * (t-t_4)
		+ a_4 * (t-t_1) * (t-t_2) * (t-t_3)
end

-- quadratic interpolation from three points
local function quad(x_1, t_1, x_2, t_2, x_3, t_3, t)
	local a_1 = x_1 / ((t_1-t_2) * (t_1-t_3))
	local a_2 = x_2 / ((t_2-t_1) * (t_2-t_3))
	local a_3 = x_3 / ((t_3-t_1) * (t_3-t_2))
	
	return a_1 * (t-t_2) * (t-t_3)
		+ a_2 * (t-t_1) * (t-t_3)
		+ a_3 * (t-t_1) * (t-t_2)
end

-- interpolate three position vectors and find the distance
local function interpolate2(pos1, t_1, pos2, t_2, pos3, t_3, time)
	local x = quad(pos1[1], t_1, pos2[1], t_2, pos3[1], t_3, time)
	local y = quad(pos1[2], t_1, pos2[2], t_2, pos3[2], t_3, time)
	local z = quad(pos1[3], t_1, pos2[3], t_2, pos3[3], t_3, time)
	
	return math.sqrt(x*x + y*y + z*z)
end

-- interpolate four position vectors and find the distance
local function interpolate3(pos1, t_1, pos2, t_2, pos3, t_3, pos4, t_4, time)
	local x = cube(pos1[1], t_1, pos2[1], t_2, pos3[1], t_3, pos4[1], t_4, time)
	local y = cube(pos1[2], t_1, pos2[2], t_2, pos3[2], t_3, pos4[2], t_4, time)
	local z = cube(pos1[3], t_1, pos2[3], t_2, pos3[3], t_3, pos4[3], t_4, time)
	
	return math.sqrt(x*x + y*y + z*z)
end

-- compute miss distance from Delta v
function miss.deltav(force, dt, m)
	
	-- delta v
	local dv = force * dt / m
	
	-- average delta v over the whole time (assume linear change)
	local dv_eff = 0.5 * dv
	
	-- compute displacement from slowing down or speeding up
	local dx = dv_eff * dt
	
	-- return miss distance in Earth radii
	return dx / 6.371e6
	
end

-- compute miss distance from numerical results
function miss.find(force, dir, interpol_steps)
	if not interpol_steps then
		interpol_steps = 1000
	end
	
	file = io.open("fort.93_" .. tostring(dir) .."_".. tostring(force))
	
	if file then
		local prev_dist = 1e9 -- previous measured distance to check direction of change
		local prev_crd0 = {0, 0, 0}  -- asteroid coordinates three rows ago
		local prev_time0 = -1        -- time two rows ago
		local prev_crd1 = {0, 0, 0}  -- asteroid coordinates two rows ago
		local prev_time1 = -1        -- time two rows ago
		local prev_crd2 = {0, 0, 0}  -- asteroid coordinates previous row
		local prev_time2 = -1        -- time in previous row

		local decrease = true -- minimum occurs when decrease becomes increase

		-- store coordinates of asteroid near minimum to interpolate
		local aster_crd0 = {0, 0, 0} -- 2 before minimum
		local aster_time0 = -1
		
		local aster_crd1 = {0, 0, 0} -- prior to minimum
		local aster_time1 = -1

		local aster_crd2 = {0, 0, 0} -- at minimum
		local aster_time2 = -1

		local aster_crd3 = {0, 0, 0} -- after minimum
		local aster_time3 = -1

		for line in file:lines() do
			
			-- look up distance
			dist_str = line:sub(12, 22)
			if dist_str:sub(1, 1) == "*" then
				prev_time = tonumber(line:sub(1, 9))
				break -- impact detected
			end
			
			cur_dist = tonumber(dist_str)
			if cur_dist then
			
				-- was decreasing, starting to increase
				if decrease and cur_dist > prev_dist then
					decrease = false -- now increasing
					
					----
					-- found a local minimum, save coordinates --
					----
					
					-- coordinates before min distance
					aster_crd0[1], aster_crd0[2], aster_crd0[3]
					= prev_crd0[1], prev_crd0[2], prev_crd0[3]
					aster_time0 = prev_time0
					
					aster_crd1[1], aster_crd1[2], aster_crd1[3]
						= prev_crd1[1], prev_crd1[2], prev_crd1[3]
					aster_time1 = prev_time1
					
					-- coordinates at min distance
					aster_crd2[1], aster_crd2[2], aster_crd3[3]
						= prev_crd2[1], prev_crd2[2], prev_crd2[3]
					aster_time2 = prev_time2
					
					-- cordinates after min distance
					aster_crd3[1] = tonumber(line:sub(32, 45)) -- x
					aster_crd3[2] = tonumber(line:sub(46, 59)) -- y
					aster_crd3[3] = tonumber(line:sub(60, 73)) -- z
					aster_time3 = tonumber(line:sub(1, 9))
				
				-- was increasing, starting to decrease
				elseif not decrease and cur_dist < prev_dist then
					decrease = true -- now decreasing
				end
				
				-- save asteroid coordinates
				if cur_dist ~= prev_dist then
					prev_crd0[1], prev_crd0[2], prev_crd0[3]
					= prev_crd1[1], prev_crd1[2], prev_crd1[3]
					prev_crd1[1], prev_crd1[2], prev_crd1[3]
						= prev_crd2[1], prev_crd2[2], prev_crd2[3]
					prev_crd2[1] = tonumber(line:sub(32, 45)) -- x
					prev_crd2[2] = tonumber(line:sub(46, 59)) -- y
					prev_crd2[3] = tonumber(line:sub(60, 73)) -- z
					
					-- save time
					prev_time0 = prev_time1
					prev_time1 = prev_time2
					prev_time2 = tonumber(line:sub(1, 9))
					
					-- save distance for comparison next time
					prev_dist = cur_dist
				end
			end
		end

		if dist_str:sub(1, 1) == "*" then
			return 0, prev_time
			
		else -- missed - interpolate to find miss distance
			
			local dist_list = {}
			local step_size = (aster_time3 - aster_time0) / interpol_steps
			
			for i=0, interpol_steps do
				dist_list[aster_time1 + i*step_size] =
					interpolate2(
						aster_crd1, aster_time1,
						aster_crd2, aster_time2,
						aster_crd3, aster_time3,
						aster_time0 + i*step_size)
			end
			
			-- find minimum in list of distances from interpolated points
			local dist_min = 1e9
			local time_min = 0
			for time, dist in pairs(dist_list) do
				
				-- save point if lower than previous minimum
				if dist < dist_min then
					dist_min = dist
					time_min = time
				end
				
			end
			
			return dist_min, time_min
		end
	end
	
end

return miss
