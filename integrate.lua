-- integrate.lua
-- functions to setting up integration problem

local aux = require "aux"

local integrate = {}

local function format_exp(num)
	str = string.format("%.16E", num)
	if num >= 0 then
		-- insert a space in place of minus sign
		return " " .. str
	else
		return str
	end
end

-- create pl.in from state file
function integrate.create_pl (state_file, diam_m)
	
	-- load state file
	dofile(state_file)
	
	-- compute asteroid mass
	local mass_kg = aux.diam_to_mass(diam_m)
	local mass_units = mass_kg * 1.9847625149006e-29 -- units used in program
	
	-- size of asteroid's hill sphere (au)
	local hill = 1.9988319462085830e-07 * (diam_m / 325)^(1/3)
	
	-- create state vector file
	iv_file = io.open("pl.in", "w")
	iv_file:write(
		
-- Sun + Earth (mass)
[[           3
 3.9476926421373022E+01
 0.0000000000000000E+00  0.0000000000000000E+00  0.0000000000000000E+00
 0.0000000000000000E+00  0.0000000000000000E+00  0.0000000000000000E+00
 1.2003167407831360E-04  1.0044729156851550E-02  0.0000000000000000E+00
]],
	
	-- Earth (state vector)
	format_exp(state.earth.pos[1]), " ",
	format_exp(state.earth.pos[2]), " ",
	format_exp(state.earth.pos[3]), "\n",
	
	format_exp(state.earth.vel[1]), " ",
	format_exp(state.earth.vel[2]), " ",
	format_exp(state.earth.vel[3]), "\n",
	
	-- Asteroid
	format_exp(mass_units), " ",
	format_exp(hill),
	"  0.0000000000000000E+00\n",
	
	format_exp(state.asteroid.pos[1]), " ",
	format_exp(state.asteroid.pos[2]), " ",
	format_exp(state.asteroid.pos[3]), "\n",
	
	format_exp(state.asteroid.vel[1]), " ",
	format_exp(state.asteroid.vel[2]), " ",
	format_exp(state.asteroid.vel[3]), "\n")
	
	iv_file:close()
	
end

-- get a state vector file for a certain time
function integrate.get_state (time_orig, t_interval)
	
	-- integrate initial state file if necessary
	local f = io.open(t_interval .."yr.state.lua", "r")
	
	if not f then
		os.execute(aux.lua_bin .." shift.lua ".. time_orig
			.. "yr.state.lua + " .. (time_orig - t_interval)
			.. " = state-temp.lua > /dev/null")
		return "state-temp.lua"
	else
		f:close()
		return t_interval .."yr.state.lua"
	end
end

-- create pl.in file from existing state if exists or create new state if not
function integrate.create_pl_reuse (time_orig, t_interval, diam_m)
	
	local state_file = integrate.get_state(time_orig, t_interval)
	integrate.create_pl(state_file, diam_m)
	
	-- remove temporary state file
	if state_file == "state-temp.lua" then
		os.remove("state-temp.lua")
	end
	
end

-- create param.in
function integrate.create_param (t_interval, t_step)
	
	-- create file
	local param_file = io.open("param.in", "w")
	
	param_file:write(
		
	-- initial value problem boundaries
	"0 ", (t_interval + 0.02), " ", string.format("%E", t_step), "\n",
	
	-- everything else
[[0.001 0.001
F T F F T F
0.1E0   30.0   -1.0   0.1E0 T
output.bin
unknown
]])
	
	param_file:close()
	
end

-- create run.in
function integrate.create_run (force_N, radius_km, is_antiparallel)
	
	-- text of run.in
	local run_str = string.format(
		"param.in\npl.in\n1.0e-10\n.true.\n%f\n.true.\n%f\n3\n.%s.\n",
		force_N, radius_km, tostring(is_antiparallel))
	
	-- create file
	local run_file = io.open("run.in", "w")
	run_file:write(run_str)
	run_file:close()
	
end

-- create run.in with custom angles
function integrate.create_run_ang (force_N, radius_km, angle_a, angle_b)
	
	-- text of run.in
	local run_str = string.format(
		"param.in\npl.in\n1.0e-10\n.true.\n%f\n.true.\n%f\n3\n%f\n%f\n",
		force_N, radius_km, math.rad(angle_a), math.rad(angle_b))
	
	-- create file
	local run_file = io.open("run.in", "w")
	run_file:write(run_str)
	run_file:close()
	
end

return integrate
