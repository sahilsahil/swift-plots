-- aux.lua
-- miscellaneous auxiliary functions that are used frequently

local aux = {}

-- check if running luajit
aux.lua_bin = "lua"
if type(jit) == "table" then
	aux.lua_bin = "luajit"
end

-- return min and max from list
function aux.min_max (list)
	local min_item, max_item = tonumber(list[1]), tonumber(list[1])
	
	for _, item in ipairs(list) do
		if tonumber(item) < min_item then
			min_item = tonumber(item)
		elseif tonumber(item) > max_item then
			max_item = tonumber(item)
		end
	end
	
	return min_item, max_item
end

-- return min and max, but prevents them from being the same
function aux.min_max_safe (list)
	local min, max = aux.min_max(list)
	if min == max then
		min = min - 0.01
		max = max + 0.01
	end
	return min, max
end

-- selection sort a set of two lists representing a list of points
function aux.sort(list_x, list_y)
	local new_x, new_y = {}, {}
	
	while #list_x > 0 do
		-- find the smallest x in the remaining list
		local i_min = 1
		local x_min = list_x[1]
		for i, x in ipairs(list_x) do
			if x < x_min then
				x_min = x
				i_min = i
			end
		end
		
		-- move smallest x and corresponding y to new list
		table.insert(new_x, x_min)
		table.insert(new_y, list_y[i_min])
		table.remove(list_x, i_min)
		table.remove(list_y, i_min)
	end
	
	-- lists are now sorted
	list_x = new_x
	list_y = new_y
	return new_x, new_y
end

-- convert asteroid diameter (m) to mass (kg)
function aux.diam_to_mass(diam)
	return 2000.0 * 4.187743 * (0.5 * diam)^3
end

-- save data by moving if needed
function aux.save_data (mode, ext)
	os.execute("mv fort.94 fort.94_" .. ext)
	
	if mode == "keep-all" or mode == "keep-result" then
		os.execute("mv fort.93 fort.93_" .. ext)
		os.execute("mv fort.95 fort.95_" .. ext)
		os.execute("mv fort.96 fort.96_" .. ext)
		os.execute("mv fort.97 fort.97_" .. ext)
		os.execute("mv fort.98 fort.98_" .. ext)
	end
end

-- clean up files
function aux.clean (mode, ext_list)
	if mode ~= "keep-all" then
		
		os.remove("pl.in")
		os.remove("param.in")
		os.remove("dump_param.dat")
		os.remove("dump_pl.dat")
		os.remove("discard_mass.out")
		os.remove("run.in")
		
		if mode ~= "keep-result" then
			
			os.remove("fort.93")
			os.remove("fort.95")
			os.remove("fort.96")
			os.remove("fort.97")
			os.remove("fort.98")
			
			if mode ~= "keep-bin" then
				os.remove("mass.output.bin")
				os.remove("output.bin")
			end
			
			if mode ~= "keep-short" then
				for i, ext in ipairs(ext_list) do
					os.remove("fort.94_ap_" .. ext)
					os.remove("fort.94_p_" .. ext)
					os.remove("fort.94_" .. ext)
				end
			end
		end
	end
end

-- write state vector file
function aux.write_state(state, out_file)
	local state_file = io.open(out_file, "w")
	
	state_file:write(
	"-- ", out_file, "\n",
	
[[-- initial condition state vectors to produce collision

state = {}

-- time properties of this set of state vectors
state.time_f = ]], state.time_f,
[[ -- time by which a collision will have occurred (years)
state.t_step = ]], state.t_step,
[[  -- time step to use for integration (years)

-- initial state vector of asteroid
state.asteroid = {}
state.asteroid.pos = { -- initial position (au)
	]], string.format("%.14e", state.asteroid.pos[1]), [[, -- x
	]], string.format("%.14e", state.asteroid.pos[2]), [[, -- y
	]], string.format("%.14e", state.asteroid.pos[3]), [[  -- z
}
state.asteroid.vel = { -- initial velocity (au/year)
	]], string.format("%.14e", state.asteroid.vel[1]), [[, -- v_x
	]], string.format("%.14e", state.asteroid.vel[2]), [[, -- v_y
	]], string.format("%.14e", state.asteroid.vel[3]), [[  -- v_z
}

-- initial state vector of Earth
state.earth = {}
state.earth.pos = { -- initial position (au)
	]], string.format("%.14e", state.earth.pos[1]), [[, -- x
	]], string.format("%.14e", state.earth.pos[2]), [[, -- y
	]], string.format("%.14e", state.earth.pos[3]), [[  -- z
}
state.earth.vel = { -- initial velocity (au/year)
	]], string.format("%.14e", state.earth.vel[1]), [[, -- v_x
	]], string.format("%.14e", state.earth.vel[2]), [[, -- v_y
	]], string.format("%.14e", state.earth.vel[3]), [[  -- v_z
}

return state
]])
	
	state_file:close()
	
end

return aux
