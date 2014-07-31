-- mvt.lua
-- runs model and produces miss distance vs. time graph

-- usage: lua[jit] mvt.lua <input-file.mvt.lua> [keep]
--   [keep] = keep-all    -> all files are kept
--          = keep-result -> all result files are kept
--          = keep-bin    -> keep only binary results
--          = keep-short  -> keep enough data to skip integration step
--          = [none]      -> delete everything except graph

local time_begin = os.time()

local aux = require "aux"
local integrate = require "integrate"

----
-- load the specification
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
-- loop through all given laster active times and integrate
----

print "Beginning numerical integration..."

local time_str = "" -- collect all times into string
for i, time in ipairs(inputs.times) do
	
	print("Integrating for t=".. time .." yr...")
	
	-- generate pl.in and param.in for this time
	integrate.create_pl_reuse(inputs.state.time_f, time, inputs.ast_diam)
	integrate.create_param(time, inputs.state.t_step)
	
	-- force antiparallel to velocity -> run.in
	integrate.create_run(inputs.force, 0.0005 * inputs.ast_diam, true)
	
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "ap_" .. time)
	
	-- force parallel to velocity -> run.in
	integrate.create_run(inputs.force, 0.0005 * inputs.ast_diam, false)
	
	os.execute("./swift_symba5_laser_standon < run.in > /dev/null")
	aux.save_data(arg[2], "p_" .. time)
	
	time_str = time_str .. " " .. time
end

----

----
-- step 5: find and graph minimum distance
----

print "Computing miss distances..."

-- output graph file name
local out_file = file_dir .. file_base .. ".mvt.png"

-- create string to create graph
local graph_str = string.format(
	"%s mvt-graph.lua -o %q -diam %f -t %s -f %d",
	aux.lua_bin,     -- lua binary
	out_file,        -- image file to output graph to
	inputs.ast_diam, -- diameter of asteroid (m)
	time_str,        -- list of times
	inputs.force     -- laser force (N)
)

-- execute graphing script
os.execute(graph_str)

----

----
-- step 6: clean up intermediate files
----

print "Cleaning up intermediate files..."
aux.clean(arg[2], inputs.times)

----

----
-- step 7: notify of completion
----

print()
print("Done generating miss distance vs. time graph for ".. file_name)
print("(took ".. (os.time() - time_begin) .." seconds)")
print()
