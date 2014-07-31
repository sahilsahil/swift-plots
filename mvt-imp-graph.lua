-- mvt-imp-graph.lua
-- apply single impulse some time before would-be collision

-- usage: lua[jit] imp-graph.lua -o out_file \
--        [-diam diameter (m)] \
--        -t time_1 (yr) [time_2] [time_3] [...] \
--        -i impulse (N s)

-- input data files:
--   fort.94_[a]p_[time]

local aux = require "aux"
local miss = require "miss"

----
-- read arguments
----

if arg[1] ~= "-o" then
	error("expected '-o out_file'")
end

local out_file = arg[2]
if not out_file then
	error("expected '-o out_file'")
end

local i = 3

-- check if diameter is specified
local diam = 325
if arg[i] == "-diam" then
	i = i + 1
	if tonumber(arg[i]) then
		diam = tonumber(arg[i])
		i = i + 1
	else
		error("expected number (diameter) after '-d'")
	end
end

-- read input times
if arg[i] ~= "-t" then
	error("expected '-t time_1 [time_2 ...]")
end

i = i + 1
local time_list = {}
while arg[i] and arg[i] ~= "-i" do
	if tonumber(arg[i]) then
		table.insert(time_list, tonumber(arg[i]))
	else
		error("expected a number near '".. arg[i] .."'")
	end
	i = i + 1
end

-- read impulse
if arg[i] ~= "-i" then
	error("expected '-i impulse'")
end

i = i + 1
local impulse
if tonumber(arg[i]) then
	impulse = tonumber(arg[i])
else
	error("expected a number near '".. arg[i] .."'")
end

----

----
-- build data structure of miss distances
----

-- data structure:
--  miss_(a)p[index] = miss distance

local miss_ap = {}
local miss_p = {}

-- load miss distance indexed by time
for _, time in ipairs(time_list) do
	print("Impulse at T-".. time .." yr at ".. impulse .." N s:")
	local ap = miss.find("fort.94_ap_" .. time) * 23481
	table.insert(miss_ap, ap)
	print(" miss = ".. string.format("%.4f", ap)
	.." Earth radii (antiparallel impulse)")
	
	local p = miss.find("fort.94_p_" .. time) * 23481
	table.insert(miss_p, p)
	print(" miss = ".. string.format("%.4f", p)
	.. " Earth radii (parallel impulse)")
	print()
end

----

----
-- create graph
----

-- find min and max time
local min_time, max_time = aux.min_max_safe(time_list)

local m  = 2000.0 * 4.187743 * (0.5 * diam)^3   -- asteroid mass (kg)

local gp = require "gnuplot"

-- create graph
local graph = gp {
	width = 640,
	height = 480,
	
	xlabel = "Time of Impulse Before Would-be Impact (years)",
	ylabel = "Miss Distance (Earth radii)",
	title = diam .. " m Asteroid with " .. (impulse * 1e-9) .. " GN·s Impulse",
	key = "top left",
	
	logscale = false,
	grid = true,
	
	data = {
		gp.array {
			{time_list, miss_ap},
			using = {1, 2},
			with = "linespoints",
			title = "Numerical (Antiparallel Impulse)",
			width = 2,
			color = 'rgb "#ff0000"'
		},
		
		gp.array {
			{time_list, miss_p},
			using = {1, 2},
			with = "linespoints",
			title = "Numerical (Parallel Impulse)",
			width = 2,
			color = 'rgb "#dd8844"'
		},
		
		gp.func {
			function (dt)
				return miss.deltav_imp(impulse, dt * 31557600, m)
			end,
			with = "lines",
			title = "From Delta v",
			range = {min_time, max_time, 0.001 * (max_time - min_time)},
			color = 'rgb "#1199bb"'
		},
		
		gp.func {
			function (dt)
				return 3 * miss.deltav_imp(impulse, dt * 31557600, m)
			end,
			with = "lines",
			title = "From 3X Delta v",
			range = {min_time, max_time, 0.001 * (max_time - min_time)},
			color = 'rgb "#0033ff"'
		}
	}
}

-- output graph
graph:plot(out_file)
