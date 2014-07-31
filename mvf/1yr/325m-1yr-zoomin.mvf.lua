-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*2250000e-4, 0.3*2250000e-4, 0.5*2250000e-4, 0.7*2250000e-4, 1*2250000e-4, 1.5*2250000e-4, 2*2250000e-4, 3*2250000e-4}
