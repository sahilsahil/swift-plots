-- target.lua
-- given initial conditions for asteroid and Earth, change the initial
--    conditions for Earth to cause an impact

-- usage: lua[jit] target.lua <orig.state.lua> <new.state.lua> [-t interval]
--   interval -> years after original state to check for a near miss
--               (default = 15.01)

local time_begin = os.time()

----
-- step 1: process arguments
----

if not arg[1] then
	error("no input state")
end
local in_state = dofile(arg[1])

--if not arg[2] then
--	error("no output file specified")
--end
--local out_file = arg[2]

local interval = 15.01
if arg[3] == "-t" and tonumber(arg[4]) then
	interval = tonumber(arg[4])
end

----

----
-- step 2: generate the initial values & parameters for input state
----

function format_exp(num)
	str = string.format("%.16E", num)
	if num >= 0 then
		-- insert a space in place of minus sign
		return " " .. str
	else
		return str
	end
end

-- create file
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
format_exp(in_state.earth.pos[1]), " ",
format_exp(in_state.earth.pos[2]), " ",
format_exp(in_state.earth.pos[3]), "\n",

format_exp(in_state.earth.vel[1]), " ",
format_exp(in_state.earth.vel[2]), " ",
format_exp(in_state.earth.vel[3]), "\n",

-- Asteroid (mass - assume for 325 m asteroid -> approximately zero)
" 7.1061155759812418E-19  1.9988319462085830E-07  0.0000000000000000E+00\n",

format_exp(in_state.asteroid.pos[1]), " ",
format_exp(in_state.asteroid.pos[2]), " ",
format_exp(in_state.asteroid.pos[3]), "\n",

format_exp(in_state.asteroid.vel[1]), " ",
format_exp(in_state.asteroid.vel[2]), " ",
format_exp(in_state.asteroid.vel[3]), "\n")

iv_file:close()


---- integration parameters ----

-- create file
local param_file = io.open("param.in", "w")

param_file:write(
	
-- initial value problem boundaries
"0 ", interval, " 5.0E-5\n",

-- everything else
[[0.001 0.001
F T F F T F
0.1E0   30.0   -1.0   0.1E0 T
output.bin
unknown
]])

param_file:close()

----

----
-- step 3: numerically integrate for given time
----

print "Beginning numerical integration..."

-- integrate with no force from laser
local run = io.open("run.in", "w")
run:write("param.in\npl.in\n1.0e-10\n.true.\n0\n.true.\n1\n3\n.true.\n")
run:close()
os.execute("./swift_symba5_laser_standon < run.in > /dev/null")

----

----
-- step 4: compute closest pass distance
----

local low_dist = 1e9
local low_time = -1
local aster_pos = {}
local earth_vel = {}

for line in io.lines("fort.94") do
	local dist = tonumber(line:sub(15, 25))
	
	if dist and dist < low_dist then
		low_dist = dist
		low_time = tonumber(line:sub(1, 14))
		
		aster_pos[1] = tonumber(line:sub(26, 48)) -- x
		aster_pos[2] = tonumber(line:sub(49, 71)) -- y
		aster_pos[3] = tonumber(line:sub(72, 94)) -- z
		
		earth_vel[1] = tonumber(line:sub(233, 255)) -- v_x
		earth_vel[2] = tonumber(line:sub(256, 278)) -- v_y
		earth_vel[3] = tonumber(line:sub(279, 301)) -- v_z
		
	end
end

local miss = require "miss"

print(low_dist)
os.execute("mv fort.94 fort.94_ap_0")
print(miss.find(0,"ap"))
----

----
-- step 5: reverse Earth's motion, starting at position of asteroid
----

print "Setting up backwards problem..."

-- create file
local reverse_file = io.open("pl.in", "w")
reverse_file:write(
	
-- Sun + Earth (mass)
[[           3
3.9476926421373022E+01
0.0000000000000000E+00  0.0000000000000000E+00  0.0000000000000000E+00
0.0000000000000000E+00  0.0000000000000000E+00  0.0000000000000000E+00
1.2003167407831360E-04  1.0044729156851550E-02  0.0000000000000000E+00
]],

-- Earth (state vector)
format_exp(aster_pos[1]), " ",
format_exp(aster_pos[2]), " ",
format_exp(aster_pos[3]), "\n",

format_exp(-earth_vel[1]), " ",
format_exp(-earth_vel[2]), " ",
format_exp(-earth_vel[3]), "\n",

-- Asteroid (mass - assume zero)
" 7.1061155759812418E-19  1.9988319462085830E-07  0.0000000000000000E+00\n",

format_exp(in_state.asteroid.pos[1]), " ",
format_exp(in_state.asteroid.pos[2]), " ",
format_exp(in_state.asteroid.pos[3]), "\n",

format_exp(in_state.asteroid.vel[1]), " ",
format_exp(in_state.asteroid.vel[2]), " ",
format_exp(in_state.asteroid.vel[3]), "\n")

reverse_file:close()


---- integration parameters ----

-- create file
local reverse_param = io.open("param.in", "w")

reverse_param:write(
	
-- initial value problem boundaries
"0 ", low_time, " 5.0E-5\n",

-- everything else
[[0.001 0.001
F T F F T F
0.1E0   30.0   -1.0   0.1E0 T
output.bin
unknown
]])

reverse_param:close()

-- begin backwards integration --

print "Beginning backwards numerical integration..."

-- integrate with no force from laser
local run = io.open("run.in", "w")
run:write("param.in\npl.in\n1.0e-10\n.true.\n0\n.true.\n1\n3\n.true.\n")
run:close()
os.execute("./swift_symba5_laser_standon < run.in > /dev/null")

----
-- step 6: read results
----

-- read last non-blank line
local last_line = ""
for line in io.lines("fort.94") do
	if #line > 0 then
		last_line = line
	end
end

-- final state of Earth in backwards integration
--    = initial state in forward integration
local init_pos = {
	tonumber(last_line:sub(164, 186)), -- x
	tonumber(last_line:sub(187, 209)), -- y
	tonumber(last_line:sub(210, 232))  -- z
}
local init_vel = { -- velocity is reversed for forward integration
	-tonumber(last_line:sub(233, 255)), -- v_x
	-tonumber(last_line:sub(256, 278)), -- v_y
	-tonumber(last_line:sub(279, 301))  -- v_z
}

print(init_pos[1], init_pos[2], init_pos[3])
print(init_vel[1], init_vel[2], init_vel[3])

-- remove unused files
os.remove("fort.93")
os.remove("fort.94")
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
