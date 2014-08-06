-- miss.lua
-- find final local minimum distance of asteroid to Earth

ivp = require "ivp"

miss = {}

-- compute miss distance from Delta v from active laser
function miss.deltav (force, dt, m)
	
	-- delta v
	local dv = force * dt / m
	
	-- average delta v over the whole time (assume linear change)
	local dv_eff = 0.5 * dv
	
	-- compute displacement from slowing down or speeding up
	local dx = dv_eff * dt
	
	-- return miss distance in Earth radii
	return dx / 6.371e6
	
end

-- compute miss distance from Delta v from single impulse
function miss.deltav_imp (impulse, dt, m)
	
	-- delta v
	local dv = impulse / m
	
	-- compute displacement from slowing down or speeding up
	local dx = dv * dt
	
	-- return miss distance in Earth radii
	return dx / 6.371e6
	
end

-- compute miss distance from numerical results
function miss.find (data_file, substeps)
	if not substeps then
		substeps = 1000000
	end
	
	local file = io.open(data_file, "r")
	
	if file then
		
		----
		-- keep track of previous rows in case we detect a minimum
		----
		local prev_dist = 1e9 -- previous measured distance to check direction of change
		
		-- previous row
		local aster_pos1 = {0, 0, 0} -- asteroid hel. position (au)
		local aster_vel1 = {0, 0, 0} -- asteroid velocity (au/year)
		
		local earth_pos1 = {0, 0, 0} -- Earth hel. position (au)
		local earth_vel1 = {0, 0, 0} -- Earth velocity (au/year)
		
		local prev_time1 = -1        -- time (years)
		
		-- two rows ago
		local aster_pos2 = {0, 0, 0} -- asteroid hel. position (au)
		local aster_vel2 = {0, 0, 0} -- asteroid velocity (au/year)
		
		local earth_pos2 = {0, 0, 0} -- Earth hel. position (au)
		local earth_vel2 = {0, 0, 0} -- Earth velocity (au/year)
		
		local prev_time2 = -1        -- time (years)

		local decrease = true -- minimum occurs when decrease becomes increase

		-- row before minimum point to start small-step integration
		local aster_pos = {0, 0, 0} -- asteroid hel. position (au)
		local aster_vel = {0, 0, 0} -- velocity (au/year)
		
		local earth_pos = {0, 0, 0} -- Earth hel. position (au)
		local earth_vel = {0, 0, 0} -- Earth velocity (au/year)
		
		local start_time = -1       -- time (years)
		local interval = -1         -- time from row before to row after (years)

		local dist_str
		for line in file:lines() do
			
			-- look up time
			local cur_time = tonumber(line:sub(1, 14))
			
			-- look up distance
			dist_str = line:sub(15, 25)
			if dist_str:sub(1, 1) == "*" then
				prev_time1 = cur_time
				break -- too close to Earth to integrate
			end
			
			local cur_dist = tonumber(dist_str)
			if cur_dist and cur_time then
			
				-- was decreasing, starting to increase
				if decrease and cur_dist > prev_dist then
					decrease = false -- now increasing
					
					----
					-- found a local minimum:
					--  save state vectors of row right before minimum
					--  (two rows ago, since we're now on row after minimum)
					----
					
					-- asteroid state vector
					aster_pos[1], aster_pos[2], aster_pos[3]
						= aster_pos2[1], aster_pos2[2], aster_pos2[3]
					aster_vel[1], aster_vel[2], aster_vel[3]
						= aster_vel2[1], aster_vel2[2], aster_vel2[3]
					
					-- Earth state vector
					earth_pos[1], earth_pos[2], earth_pos[3]
						= earth_pos2[1], earth_pos2[2], earth_pos2[3]
					earth_vel[1], earth_vel[2], earth_vel[3]
						= earth_vel2[1], earth_vel2[2], earth_vel2[3]
					
					-- time to start small-step integration if this is last min
					start_time = prev_time1
					interval = cur_time - start_time
				
				-- was increasing, starting to decrease
				elseif not decrease and cur_dist < prev_dist then
					decrease = true -- now decreasing
				end
				
				-- save current state vectors in case we're before a mininum
				if cur_dist ~= prev_dist then
					
					-- asteroid heliocentric position (au)
					aster_pos2[1], aster_pos2[2], aster_pos2[3]
						= aster_pos1[1], aster_pos1[2], aster_pos1[3]
					aster_pos1[1] = tonumber(line:sub(26, 48)) -- x
					aster_pos1[2] = tonumber(line:sub(49, 71)) -- y
					aster_pos1[3] = tonumber(line:sub(72, 94)) -- z
					
					-- asteroid velocity (au/year)
					aster_vel2[1], aster_vel2[2], aster_vel2[3]
						= aster_vel1[1], aster_vel1[2], aster_vel1[3]
					aster_vel1[1] = tonumber(line:sub(95,  117)) -- v_x
					aster_vel1[2] = tonumber(line:sub(118, 140)) -- v_y
					aster_vel1[3] = tonumber(line:sub(141, 163)) -- v_z
					
					-- Earth heliocentric position (au)
					earth_pos2[1], earth_pos2[2], earth_pos2[3]
						= earth_pos1[1], earth_pos1[2], earth_pos1[3]
					earth_pos1[1] = tonumber(line:sub(164, 186)) -- x
					earth_pos1[2] = tonumber(line:sub(187, 209)) -- y
					earth_pos1[3] = tonumber(line:sub(210, 232)) -- z
					
					-- Earth velocity (au/year)
					earth_vel2[1], earth_vel2[2], earth_vel2[3]
						= earth_vel1[1], earth_vel1[2], earth_vel1[3]
					earth_vel1[1] = tonumber(line:sub(233, 255)) -- v_x
					earth_vel1[2] = tonumber(line:sub(256, 278)) -- v_y
					earth_vel1[3] = tonumber(line:sub(279, 301)) -- v_z
					
					-- starting time (years)
					prev_time2 = prev_time1
					prev_time1 = cur_time
					
					-- save distance for comparison next time
					prev_dist = cur_dist
				end
			end
		end

		if dist_str:sub(1, 1) == "*" then
			return 0, prev_time1
		
		else -- able to integrate - use smaller time step and use RK4
			
			local mu   = 1.327e20 -- heliocentric grav constant (m^3/s^2)
			local mu_e = 3.986e14 -- geocentric grav constant (m^3/s^2)
			
			----
			-- setup initial value problem
			----
			
			-- step size for integration
			local t_step = interval / substeps
			
			-- convert position and velocity to SI units
			local au_to_m = 149597870700
			local yr_to_s = 31557600
			local aupyr_to_mps = au_to_m / yr_to_s -- au/yr to m/s
			
			-- asteroid
			local ast_pos = {
				aster_pos[1] * au_to_m,
				aster_pos[2] * au_to_m,
				aster_pos[3] * au_to_m
			}
			local ast_vel = {
				aster_vel[1] * aupyr_to_mps,
				aster_vel[2] * aupyr_to_mps,
				aster_vel[3] * aupyr_to_mps
			}
			
			-- Earth
			local ear_pos = {
				earth_pos[1] * au_to_m,
				earth_pos[2] * au_to_m,
				earth_pos[3] * au_to_m
			}
			local ear_vel = {
				earth_vel[1] * aupyr_to_mps,
				earth_vel[2] * aupyr_to_mps,
				earth_vel[3] * aupyr_to_mps
			}
			
			-- acceleration of asteroid
			local function aster_acc (x, y, z)
				
				-- distance from Sun
				local r = math.sqrt(x*x + y*y + z*z)
				
				-- compute solar acceleration vector
				local a_over_r = -mu / (r * r * r)
				local as_x, as_y, as_z
					= x * a_over_r, y * a_over_r, z * a_over_r
				
				-- geocentric position
				local x_g = x - ear_pos[1]
				local y_g = y - ear_pos[2]
				local z_g = z - ear_pos[3]
				
				-- distance from Earth
				local d = math.sqrt(x_g*x_g + y_g*y_g + z_g*z_g)
				
				-- compute Earth acceleration vector
				local a_over_d = -mu_e / (d * d * d)
				local ae_x, ae_y, ae_z
					= x_g * a_over_d, y_g * a_over_d, z_g * a_over_d
				
				-- compute net acceleration vector
				return as_x + ae_x, as_y + ae_y, as_z + ae_z
				
			end
			
			-- acceleration of Earth (use simple 2 body problem)
			local function earth_acc (x, y, z)
				
				-- distance from Sun
				local r = math.sqrt(x*x + y*y + z*z)
				
				-- compute magnitude of acceleration over r (ignore asteroid)
				local a_over_r = -mu / (r * r * r)
				
				-- compute acceleration vector
				return x * a_over_r, y * a_over_r, z * a_over_r
				
			end
			
			-- initialize initial value problems
			local ivp_ast =
				ivp.create(aster_acc, ast_pos, ast_vel,
					start_time * yr_to_s, t_step * yr_to_s)
			local ivp_ear =
				ivp.create(earth_acc, ear_pos, ear_vel,
					start_time * yr_to_s, t_step * yr_to_s)
			
			-- comparison variables to check sign of radial velocity component
			local dist = -1
			local next_dist = math.sqrt (
				(ast_pos[1] - ear_pos[1])^2 +
				(ast_pos[2] - ear_pos[2])^2 +
				(ast_pos[3] - ear_pos[3])^2
			)
			
			local time_min
			
			-- continue looping until distance increases
			repeat
				-- newly computed distance becomes old distance
				dist = next_dist
				time_min = ivp_ast.time -- save time in case it's a min
				
				-- run RK4 step on asteroid and Earth
				ivp_ast:step()
				ivp_ear:step()
				
				-- look at new distance
				next_dist = math.sqrt (
					(ast_pos[1] - ear_pos[1])^2 +
					(ast_pos[2] - ear_pos[2])^2 +
					(ast_pos[3] - ear_pos[3])^2
				)
			until next_dist > dist -- once satisfied, we start increasing again
			
			-- return minimum distance + time at minimum distance
			return dist / au_to_m, time_min / yr_to_s
		end
	end
	
end

return miss
