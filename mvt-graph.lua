-- mvt-graph.lua
-- generate a graph of miss distance vs. time laser is active from precomputed data

-- usage: lua[jit] mvt-graph.lua -o out_file \
--        [-diam diameter (m)] \
--        -t time_1 (yr) [time_2] [time_3] [...] \
--        -f force (N)

-- input data files:
--   fort.94_[a]p_[time]

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
while arg[i] and arg[i] ~= "-f" do
	if tonumber(arg[i]) then
		table.insert(time_list, tonumber(arg[i]))
	else
		error("expected a number near '".. arg[i] .."'")
	end
	i = i + 1
end

-- read input force
if arg[i] ~= "-f" then
	error("expected '-f force'")
end

i = i + 1
local force
if tonumber(arg[i]) then
	force = tonumber(arg[i])
else
	error("expected a number near '".. arg[i] .."'")
end

----

----
-- build data structure of miss distances
----

-- data structure:
--  miss_(a)p[index] = miss distance
--   

local miss_ap = {}
local miss_p = {}

local miss = require "miss"


-- load miss distance indexed by time
for _, time in ipairs(time_list) do
	print("Laser active for ".. time .." yr at ".. force .." N:")
	local ap = miss.find("fort.94_ap_" .. time) * 23481
	table.insert(miss_ap, ap)
	print(" miss = ".. string.format("%.4f", ap)
		.." Earth radii (antiparallel thrust)")
	
	local p = miss.find("fort.94_p_" .. time) * 23481
	table.insert(miss_p, p)
	print(" miss = ".. string.format("%.4f", p)
		.. " Earth radii (parallel thrust)")
	print()
end

----

----
-- create graph
----

local aux = require "aux"

-- find min and max time
local min_time, max_time = aux.min_max_safe(time_list)

local m  = aux.diam_to_mass(diam) -- asteroid mass (kg)

local gp = require "gnuplot"

-- create graph
local graph = gp {
	width = 640,
	height = 480,
	
	xlabel = "Laser Active Time (years)",
	ylabel = "Miss Distance (Earth radii)",
	title = diam .. " m Asteroid with " .. force .. " N Thrust",
	key = "top left",
	
	logscale = false,
	grid = true,
	
	data = {
		gp.array {
			{time_list, miss_ap},
			using = {1, 2},
			with = "linespoints",
			title = "Numerical (Antiparallel Thrust)",
			width = 2,
			color = 'rgb "#ff0000"'
		},
		
		gp.array {
			{time_list, miss_p},
			using = {1, 2},
			with = "linespoints",
			title = "Numerical (Parallel Thrust)",
			width = 2,
			color = 'rgb "#dd8844"'
		},
		
		gp.func {
			function (dt)
				return miss.deltav(force, dt * 31557600, m)
			end,
			with = "lines",
			title = "From Delta v",
			range = {min_time, max_time, 0.001 * (max_time - min_time)},
			color = 'rgb "#1199bb"'
		},
		
		gp.func {
			function (dt)
				return 3 * miss.deltav(force, dt * 31557600, m)
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
