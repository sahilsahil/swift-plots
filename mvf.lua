-- mvf.lua
-- runs model and produces miss distance vs. force graph

-- usage: lua[jit] mvf.lua <input-file.mvf.lua> [keep]
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

integrate.create_pl(inputs.state.time_f .. "yr.state.lua", inputs.ast_diam)
integrate.create_param(inputs.state.time_f, inputs.state.t_step)

----

----
-- step 3: loop through all given thrust forces and integrate
----

print "Beginning numerical integration..."

local force_str = "" -- collect all forces into string
for i, force in ipairs(inputs.forces) do
	
	print("Integrating for F=".. force .." N...")
	
	-- force antiparallel to velocity -> run.in
	integrate.create_run(force, 0.0005 * inputs.ast_diam, true)
	
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "ap_" .. force)
	
	-- force parallel to velocity -> run.in
	integrate.create_run(force, 0.0005 * inputs.ast_diam, false)
	
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "p_" .. force)
	
	force_str = force_str .. " " .. force
end

----

----
-- step 4: find and graph minimum distance
----

print "Computing miss distances..."

-- output graph file name
local out_file = file_dir .. file_base .. ".mvf.png"

-- create string to create graph
local graph_str = string.format(
	"%s mvf-graph.lua -o %q -diam %f -time %f %s",
	aux.lua_bin,         -- lua binary
	out_file,        -- image file to output graph to
	inputs.ast_diam, -- diameter of asteroid (m)
	-- interval for which laser is on (Julian years)
	inputs.state.time_f,
	force_str
)

-- execute graphing script
os.execute(graph_str)

----

----
-- step 5: clean up intermediate files
----

print "Cleaning up intermediate files..."

aux.clean(arg[2], inputs.forces)

----

----
-- step 6: notify of completion
----

print()
print("Done generating miss distance vs. force graph for ".. file_name)
print("(took ".. (os.time() - time_begin) .." seconds)")
print()
