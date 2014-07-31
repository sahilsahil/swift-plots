-- shift.lua
-- numerically integrate state vectors to convert from one epoch to another

-- usage: lua[jit] shift.lua <initial.state.lua> + \
--                           <shift-time> = <shifted.state.lua>
--   <shift-time> -> time in years to shift forward by

local time_begin = os.time()

local aux = require "aux"
local integrate = require "integrate"

----
-- step 1: load the initial state vectors
----

print "Loading input state vectors..."

if not arg[1] then
	error("expected input file (string)")
end
local in_file = arg[1]
dofile(in_file)

-- read shift time
if arg[2] ~= "+" then
	error("expected '+' after '".. file .. "'")
end

local shift_time = tonumber(arg[3])
if not shift_time then
	error("expected shift time in years (number) after '+'")
end

-- read output file
if arg[4] ~= "=" then
	error("expected '=' after '".. shift_time .. "'")
end

if not arg[5] then
	error("expected output file (string)")
end
local out_file = arg[5]

----

----
-- step 2: check if we need to shift backward in time
----

local final_time = state.time_f - shift_time

-- need to reverse initial value problem
if shift_time < 0 then
	shift_time = -shift_time
	
	-- reverse velocity vectors
	state.asteroid.vel[1] = -state.asteroid.vel[1]
	state.asteroid.vel[2] = -state.asteroid.vel[2]
	state.asteroid.vel[3] = -state.asteroid.vel[3]
	state.earth.vel[1] = -state.earth.vel[1]
	state.earth.vel[2] = -state.earth.vel[2]
	state.earth.vel[3] = -state.earth.vel[3]
end

----

----
-- step 3: generate integration input files
----

-- pl.in
aux.write_state(state, "state-temp.lua")
integrate.create_pl("state-temp.lua", 325)
os.remove("state-temp.lua")

-- param.in
-- (the -0.02 is needed to cancel the overshooting which the function does)
integrate.create_param(shift_time - 0.02, 2e-4)

----

----
-- step 4: numerically integrate for given time
----

print "Beginning numerical integration..."

-- integrate with no force from laser
local run = io.open("run.in", "w")
run:write("param.in\npl.in\n1.0e-10\n.true.\n0\n.true.\n1\n3\n.true.\n")
run:close()
os.execute("./swift_symba5_laser_standon < run.in > /dev/null")

-- remove unused files
os.remove("fort.93")
os.remove("fort.95")
os.remove("fort.96")
os.remove("fort.97")
os.remove("fort.98")
os.remove("mass.output.bin")
os.remove("output.bin")
os.remove("discard_mass.dat")
os.remove("dump_param.dat")
os.remove("dump_pl.dat")
os.remove("param.in")
os.remove("pl.in")
os.remove("run.in")

----

----
-- step 5: read final state
----

-- read last non-blank line
local last_line = ""
for line in io.lines("fort.94") do
	if #line > 0 then
		last_line = line
	end
end

-- final state of asteroid
state.asteroid.pos[1] = tonumber(last_line:sub(26, 48)) -- x
state.asteroid.pos[2] = tonumber(last_line:sub(49, 71)) -- y
state.asteroid.pos[3] = tonumber(last_line:sub(72, 94)) -- z

state.asteroid.vel[1] = tonumber(last_line:sub(95,  117)) -- v_x
state.asteroid.vel[2] = tonumber(last_line:sub(118, 140)) -- v_y
state.asteroid.vel[3] = tonumber(last_line:sub(141, 163)) -- v_z

-- final state of Earth
state.earth.pos[1] = tonumber(last_line:sub(164, 186)) -- x
state.earth.pos[2] = tonumber(last_line:sub(187, 209)) -- y
state.earth.pos[3] = tonumber(last_line:sub(210, 232)) -- z

state.earth.vel[1] = tonumber(last_line:sub(233, 255)) -- v_x
state.earth.vel[2] = tonumber(last_line:sub(256, 278)) -- v_y
state.earth.vel[3] = tonumber(last_line:sub(279, 301)) -- v_z

os.remove("fort.94")

----

----
-- step 6: write new state file
----

-- reverse velocity vector if we're integrating into the past
--   (note: time in units of years from impact, so counts down normally)
if final_time > state.time_f then
	state.asteroid.vel[1] = -state.asteroid.vel[1]
	state.asteroid.vel[2] = -state.asteroid.vel[2]
	state.asteroid.vel[3] = -state.asteroid.vel[3]
	state.earth.vel[1] = -state.earth.vel[1]
	state.earth.vel[2] = -state.earth.vel[2]
	state.earth.vel[3] = -state.earth.vel[3]
end

state.time_f = final_time
aux.write_state(state, out_file) 

----

----
-- step 7: notify of completion
----

print()
print("Done shifting ".. in_file .." by ".. shift_time .. " years")
print("(took ".. (os.time() - time_begin) .." seconds)")
print()
