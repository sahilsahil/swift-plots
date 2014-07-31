-- mvi.lua
-- runs model and produces miss distance vs. force graph

-- usage: lua[jit] mvi.lua <input-file.mvi.lua> [keep]
--   [keep] = keep-all    -> all files are kept
--          = keep-result -> all result files are kept
--          = keep-bin    -> keep only binary results
--          = keep-short  -> keep enough data to skip integration step
--          = [none]      -> delete everything except graph

local time_begin = os.time()

local aux = require "aux"
local integrate = require "integrate"

----
-- step 1: load the specification
----

print "Loading input file..."

if not arg[1] then
	error("no input file specified")
end
local file = arg[1]
dofile(file)

-- output in same directory as input
local file_dir = ""
local file_name = file
if file:find("/") then
	file_dir = file:sub(1, file:find("/[^/]+$", 1))
	file_name = file:sub(file:find("/[^/]+$") + 1)
end

-- get base name
local file_base = file_name:sub(1, file_name:find("%.", 1) - 1)

----

----
-- step 2: generate inputs into integration
----

local state = inputs.state
integrate.create_param(state.time_f, state.t_step)

----

----
-- step 3: loop through all given impulses and integrate
----

print "Beginning numerical integration..."

local mps_to_aupyr = 31557600 / 149597870700

local imp_str = "" -- collect all impulses into string
for i, impulse in ipairs(inputs.impulses) do
	
	print("Integrating for Impulse=".. impulse .." N s...")
	
	-- compute speed and Delta v
	local v = math.sqrt(
		state.asteroid.vel[1] ^ 2 +
		state.asteroid.vel[2] ^ 2 +
		state.asteroid.vel[3] ^ 2)
	local dv = impulse / aux.diam_to_mass(inputs.ast_diam)
	local dv_aupyr = dv * mps_to_aupyr
	local dv_prop = dv_aupyr / v
	
	-- apply Delta v vector for antiparallel
	state.asteroid.vel[1] = (1 - dv_prop) * state.asteroid.vel[1]
	state.asteroid.vel[2] = (1 - dv_prop) * state.asteroid.vel[2]
	state.asteroid.vel[3] = (1 - dv_prop) * state.asteroid.vel[3]
	aux.write_state(state, "state-temp.lua")
	integrate.create_pl("state-temp.lua", inputs.ast_diam)
	
	-- continue integration with new velocity and no force
	integrate.create_run(0, 0.0005 * inputs.ast_diam, true)
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "ap_" .. impulse)
	
	-- apply Delta v vector for parallel
	state.asteroid.vel[1] = (1 + dv_prop) * state.asteroid.vel[1] /(1 - dv_prop)
	state.asteroid.vel[2] = (1 + dv_prop) * state.asteroid.vel[2] /(1 - dv_prop)
	state.asteroid.vel[3] = (1 + dv_prop) * state.asteroid.vel[3] /(1 - dv_prop)
	aux.write_state(state, "state-temp.lua")
	integrate.create_pl("state-temp.lua", inputs.ast_diam)
	
	-- continue integration with new velocity and no force
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "p_" .. impulse)
	
	imp_str = imp_str .. " " .. impulse
	
	-- restore initial state vector for next step
	state.asteroid.vel[1] = state.asteroid.vel[1] /(1 + dv_prop)
	state.asteroid.vel[2] = state.asteroid.vel[2] /(1 + dv_prop)
	state.asteroid.vel[3] = state.asteroid.vel[3] /(1 + dv_prop)
end

os.remove("state-temp.lua")

----

----
-- step 4: find and graph minimum distance
----

print "Computing miss distances..."

-- output graph file name
local out_file = file_dir .. file_base .. ".mvi.png"

-- create string to create graph
local graph_str = string.format(
	"%s mvi-graph.lua -o %q -diam %f -time %f %s",
	aux.lua_bin,         -- lua binary
	out_file,        -- image file to output graph to
	inputs.ast_diam, -- diameter of asteroid (m)
	-- interval for which laser is on (Julian years)
	state.time_f,
	imp_str
)

-- execute graphing script
os.execute(graph_str)

----

----
-- step 5: clean up intermediate files
----

print "Cleaning up intermediate files..."

aux.clean(arg[2], inputs.impulses)

----

----
-- step 6: notify of completion
----

print()
print("Done generating miss distance vs. impulse graph for ".. file_name)
print("(took ".. (os.time() - time_begin) .." seconds)")
print()
