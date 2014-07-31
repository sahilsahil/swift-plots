-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 250

-- list of laser thrust forces to run (N)
inputs.forces = {0*2250000e-4, 0.4*2250000e-4, 0.8*2250000e-4, 1.5*2250000e-4, 3*2250000e-4, 6*2250000e-4}
