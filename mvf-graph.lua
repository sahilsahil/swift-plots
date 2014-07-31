-- mvf-graph.lua
-- generate a graph of miss distance vs. force from precomputed data

-- usage: lua[jit] mvf-graph.lua [-o out_file] [-diam diameter (m)] \
--        [-time laser_active_time (Julian years)] \
--        [force_1 (N)] [force_2 (N)] [... (N)]

gp = require "gnuplot"
miss = require "miss"
aux = require "aux"

-- antiparallel
local force_ap_list = {} -- list of forces
local miss_ap_list  = {} -- list of distances

-- parallel
local force_p_list = {} -- list of forces
local miss_p_list  = {} -- list of distances

i_0 = 1

-- output file
if arg[i_0] == "-o" then
	out_file = arg[2]
	i_0 = i_0 + 2
end

-- load parameters

-- asteroid diameter (m)
local diam = 325
if arg[i_0] == "-diam" then
	diam = tonumber(arg[i_0 + 1])
	i_0 = i_0 + 2
end

-- laser on time (Julian years -> s)
local dt = 15.01 * 31557600
if arg[i_0] == "-time" then
	dt = tonumber(arg[i_0 + 1]) * 31557600
	i_0 = i_0 + 2
end

-- antiparallel thrust
print("----")
print("-- Thrust: Antiparallel")
print("----")
print()
for i=i_0, #arg do
	local dist_au, time = miss.find("fort.94_ap_" .. arg[i])
	print("F=" .. arg[i] .. " N")
	
	if dist_au and dist_au > 0 then
		table.insert(force_ap_list, arg[i])
		table.insert(miss_ap_list, dist_au * 23481)
		
		print(string.format("Miss distance: %.4f Earth radii", dist_au * 23481))
		print(string.format("(at time t=%.4f years)", time))
	elseif dist_au then
		print(string.format("Impact at time t=%.4f years", time))
	end
	print()
end

-- parallel thrust
print("----")
print("-- Thrust: Parallel")
print("----")
print()


local m  = aux.diam_to_mass(diam) -- asteroid mass (kg)

for i=i_0, #arg do
	local dist_au, time = miss.find("fort.94_p_" .. arg[i])
	print("F=" .. arg[i] .. " N")
	
	if dist_au and dist_au > 0 then
		table.insert(force_p_list, arg[i])
		table.insert(miss_p_list, dist_au * 23481)
		
		print(string.format("Miss distance: %.4f Earth radii", dist_au * 23481))
		print(string.format("(at time t=%.4f years)", time))
	elseif dist_au then
		print(string.format("Impact at time t=%.4f years", time))
	end
	print()
end

-- plot graph
if i_0 > 2 and (#force_ap_list > 0 or #force_p_list > 0) then
	
	-- find domain
	local min_force_ap, max_force_ap = aux.min_max_safe(force_ap_list)
	local min_force_p, max_force_p = aux.min_max_safe(force_p_list)
	
	local min_force = math.min(min_force_ap, min_force_p)
	local max_force = math.max(max_force_ap, max_force_p)
	
	local graph = gp {
		width = 640,
		height = 480,
		
		xlabel = "Force (N)",
		ylabel = "Miss Distance (Earth radii)",
		title = tostring(diam) .. " m Asteroid w/ Laser On for "..
			math.floor(10 * dt / 31557600) / 10 .." Years",
		key = "top left",
		
		logscale = false,
		grid = true,
		
		data = {
			gp.array {
				{force_ap_list, miss_ap_list},
				using = {1, 2},
				with = "linespoints",
				title = "Numerical (Antiparallel Thrust)",
				width = 2,
				color = 'rgb "#ff0000"'
			},
			
			gp.array {
				{force_p_list, miss_p_list},
				using = {1, 2},
				with = "linespoints",
				title = "Numerical (Parallel Thrust)",
				width = 2,
				color = 'rgb "#dd8844"'
			},
			
			gp.func {
				function (force)
					return miss.deltav(force, dt, m)
				end,
				with = "lines",
				title = "From Delta v",
				range = {min_force, max_force, 0.001 * (max_force - min_force)},
				color = 'rgb "#1199bb"'
			},
			
			gp.func {
				function (force)
					return 3 * miss.deltav(force, dt, m)
				end,
				with = "lines",
				title = "From 3X Delta v",
				range = {min_force, max_force, 0.001 * (max_force - min_force)},
				color = 'rgb "#0033ff"'
			}
		}
	}
	graph:plot(out_file)
end