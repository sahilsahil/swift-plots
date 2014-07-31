-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*2250000e-4, 4*2250000e-4, 8*2250000e-4, 15*2250000e-4, 30*2250000e-4, 60*2250000e-4, 100*2250000e-4}
