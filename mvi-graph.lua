-- mvi-graph.lua
-- generate a graph of miss distance vs. impulse from precomputed data

-- usage: lua[jit] mvi-graph.lua [-o out_file] [-diam diameter (m)] \
--        [-time laser_active_time (Julian years)] \
--        [impulse_1 (N s)] [impulse 2] [...]

gp = require "gnuplot"
miss = require "miss"
aux = require "aux"

-- antiparallel
local impulse_ap_list = {} -- list of impulses
local miss_ap_list  = {} -- list of distances

-- parallel
local impulse_p_list = {} -- list of impulses
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

-- time of impulse before impact (Julian years -> s)
local dt = 15.01 * 31557600
if arg[i_0] == "-time" then
	dt = tonumber(arg[i_0 + 1]) * 31557600
	i_0 = i_0 + 2
end

-- antiparallel impulse
print("----")
print("-- Impulse: Antiparallel")
print("----")
print()
for i=i_0, #arg do
	local dist_au, time = miss.find("fort.94_ap_" .. arg[i])
	print("Impulse=" .. arg[i] .. " N s")
	
	if dist_au and dist_au > 0 then
		table.insert(impulse_ap_list, arg[i])
		table.insert(miss_ap_list, dist_au * 23481)
		
		print(string.format("Miss distance: %.4f Earth radii", dist_au * 23481))
		print(string.format("(at time t=%.4f years)", time))
	elseif dist_au then
		print(string.format("Impact at time t=%.4f years", time))
	end
	print()
end

-- parallel impulse
print("----")
print("-- Impulse: Parallel")
print("----")
print()

for i=i_0, #arg do
	local dist_au, time = miss.find("fort.94_p_" .. arg[i])
	print("F=" .. arg[i] .. " N")
	
	if dist_au and dist_au > 0 then
		table.insert(impulse_p_list, arg[i])
		table.insert(miss_p_list, dist_au * 23481)
		
		print(string.format("Miss distance: %.4f Earth radii", dist_au * 23481))
		print(string.format("(at time t=%.4f years)", time))
	elseif dist_au then
		print(string.format("Impact at time t=%.4f years", time))
	end
	print()
end

local m  = aux.diam_to_mass(diam) -- asteroid mass (kg)

-- plot graph
if i_0 > 2 and (#impulse_ap_list > 0 or #impulse_p_list > 0) then
	
	-- find domain
	local min_impulse_ap, max_impulse_ap = aux.min_max_safe(impulse_ap_list)
	local min_impulse_p, max_impulse_p = aux.min_max_safe(impulse_p_list)
	
	local min_impulse = math.min(min_impulse_ap, min_impulse_p)
	local max_impulse = math.max(max_impulse_ap, max_impulse_p)
	
	local graph = gp {
		width = 640,
		height = 480,
		
		xlabel = "Impulse (N·s)",
		ylabel = "Miss Distance (Earth radii)",
		title = tostring(diam) .. " m Asteroid w/ Impulse at T-"..
			(dt / 31557600) .." Years",
		key = "top left",
		
		logscale = false,
		grid = true,
		
		data = {
			gp.array {
				{impulse_ap_list, miss_ap_list},
				using = {1, 2},
				with = "linespoints",
				title = "Numerical (Antiparallel Impulse)",
				width = 2,
				color = 'rgb "#ff0000"'
			},
			
			gp.array {
				{impulse_p_list, miss_p_list},
				using = {1, 2},
				with = "linespoints",
				title = "Numerical (Parallel Impulse)",
				width = 2,
				color = 'rgb "#dd8844"'
			},
			
			gp.func {
				function (impulse)
					return miss.deltav_imp(impulse, dt, m)
				end,
				with = "lines",
				title = "From Delta v",
				range = {min_impulse, max_impulse, 0.001 * (max_impulse - min_impulse)},
				color = 'rgb "#1199bb"'
			},
			
			gp.func {
				function (impulse)
					return 3 * miss.deltav_imp(impulse, dt, m)
				end,
				with = "lines",
				title = "From 3X Delta v",
				range = {min_impulse, max_impulse, 0.001 * (max_impulse - min_impulse)},
				color = 'rgb "#0033ff"'
			}
		}
	}
	graph:plot(out_file)
end